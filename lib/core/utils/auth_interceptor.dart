import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/services/secure_token_storage.dart';

/// Dio interceptor that:
/// 1. Attaches the accessToken to every request automatically.
/// 2. On 401 with "Token expired" message → calls /auth/refresh-token.
/// 3. Retries the original failed request with the new accessToken.
/// 4. Queues concurrent requests while a refresh is in progress.
/// 5. Forces logout if the refresh token is also expired/invalid.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required Dio dio, required this.onForceLogout}) : _dio = dio;

  final Dio _dio;

  /// Called when both tokens are expired — clear storage and go to login.
  final Future<void> Function() onForceLogout;

  bool _isRefreshing = false;
  final List<_PendingRequest> _queue = [];

  // ─── Endpoints that must never trigger the refresh flow ─────────────────

  // ─── Endpoints that must never trigger the refresh-token flow ───────────
  // Note: logout endpoints are NOT here — they need the Authorization header.
  // They are only excluded from the refresh-on-401 logic below.

  static const _skipRefreshPaths = [
    '/auth/refresh-token',
    '/auth/login',
    '/advisor/login',
    '/auth/register',
    '/auth/verify-account',
    '/advisor/verifyOtp',
    '/auth/guest-login',
  ];

  // Endpoints that should never trigger a token refresh on 401
  // (includes logout — if logout gets 401 we just proceed, not refresh)
  static const _skipRefreshOn401Paths = [
    '/auth/refresh-token',
    '/auth/logout',
    '/advisor/logout',
    '/auth/login',
    '/advisor/login',
    '/auth/register',
    '/auth/verify-account',
    '/advisor/verifyOtp',
    '/auth/guest-login',
  ];

  /// Skip injecting the Authorization header for these paths
  bool _shouldSkipTokenInjection(String path) =>
      _skipRefreshPaths.any((p) => path.contains(p));

  /// Skip the refresh-on-401 flow for these paths
  bool _shouldSkipRefreshOn401(String path) =>
      _skipRefreshOn401Paths.any((p) => path.contains(p));

  // ─── Request ────────────────────────────────────────────────────────────

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token injection for pure auth endpoints (login, register, etc.)
    // Logout is NOT skipped — it needs the Authorization header
    if (_shouldSkipTokenInjection(options.path)) {
      return handler.next(options);
    }

    // If the caller already set an explicit Authorization header
    // (e.g. OTP/partial-token flows), respect it and don't override.
    final existingAuth = options.headers['Authorization']?.toString() ?? '';
    if (existingAuth.isNotEmpty) {
      return handler.next(options);
    }

    final accessToken = await SecureTokenStorage.getAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  // ─── Response Error ──────────────────────────────────────────────────────

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;

    // Only handle 401 with exact "Token expired" message
    if (response?.statusCode == 401 && _isTokenExpiredMessage(response?.data)) {
      // Skip refresh for auth/logout endpoints
      if (_shouldSkipRefreshOn401(err.requestOptions.path)) {
        debugPrint(
          '⚠️ AuthInterceptor: 401 on skip-path ${err.requestOptions.path}, not refreshing',
        );
        return handler.next(err);
      }

      if (_isRefreshing) {
        // Queue this request — it will be retried after refresh completes
        final completer = Completer<Response>();
        _queue.add(_PendingRequest(err.requestOptions, completer));
        try {
          final retryResponse = await completer.future;
          return handler.resolve(retryResponse);
        } catch (e) {
          return handler.next(err);
        }
      }

      _isRefreshing = true;
      debugPrint('🔄 AuthInterceptor: access token expired, refreshing...');

      try {
        final newTokens = await _refreshTokens();

        if (newTokens == null) {
          // Refresh failed → force logout
          _rejectQueue();
          await _handleForceLogout();
          return handler.next(err);
        }

        // Retry the original failed request with the new token
        final retryResponse = await _retryRequest(
          err.requestOptions,
          newTokens.accessToken,
        );

        // Resolve all queued requests
        _resolveQueue(newTokens.accessToken);

        return handler.resolve(retryResponse);
      } catch (e) {
        _rejectQueue();
        await _handleForceLogout();
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }

    handler.next(err);
  }

  // ─── Private Helpers ────────────────────────────────────────────────────

  /// Matches ONLY the exact "Token expired" message from the backend.
  /// Avoids false positives on other messages that contain the word "expired".
  bool _isTokenExpiredMessage(dynamic data) {
    if (data is Map) {
      final message = data['message']?.toString() ?? '';
      return message == 'Token expired' ||
          message.toLowerCase() == 'token expired' ||
          message.toLowerCase() == 'jwt expired' ||
          message.toLowerCase() == 'access token expired';
    }
    return false;
  }

  Future<_TokenPair?> _refreshTokens() async {
    // Snapshot the refresh token BEFORE the async call so we can detect
    // if another layer (e.g. SocketHelper) already refreshed while we waited.
    final refreshTokenBefore = await SecureTokenStorage.getRefreshToken();
    if (refreshTokenBefore == null || refreshTokenBefore.isEmpty) {
      debugPrint('❌ AuthInterceptor: no refresh token stored, cannot refresh');
      return null;
    }

    debugPrint('🔄 AuthInterceptor: calling /auth/refresh-token...');

    try {
      final response = await _dio.post(
        '$kbaseUrl/auth/refresh-token',
        data: {'refreshToken': refreshTokenBefore},
        options: Options(
          headers: {'lang': selectedLanguage ?? 'ar'},
          // Use default validateStatus so 4xx throws DioException
          // but we catch it below anyway
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String;
        final newRefreshToken = data['refreshToken'] as String;

        await SecureTokenStorage.saveBothTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        debugPrint('✅ AuthInterceptor: tokens refreshed successfully');
        return _TokenPair(newAccessToken, newRefreshToken);
      }

      debugPrint(
        '❌ AuthInterceptor: refresh failed — ${response.statusCode} ${response.data}',
      );
      return _checkForRaceRefresh(refreshTokenBefore);
    } on DioException catch (e) {
      debugPrint(
        '❌ AuthInterceptor: refresh DioException — ${e.response?.statusCode} ${e.response?.data}',
      );
      // Another layer (e.g. SocketHelper) may have already refreshed the
      // token while our request was in-flight. If the stored refresh token
      // has changed it means a fresh pair was saved — use it instead of
      // forcing a logout.
      return _checkForRaceRefresh(refreshTokenBefore);
    } catch (e) {
      debugPrint('❌ AuthInterceptor: refresh error — $e');
      return _checkForRaceRefresh(refreshTokenBefore);
    }
  }

  /// Returns a valid [_TokenPair] if another concurrent refresh (e.g. from
  /// [SocketHelper]) already stored new tokens while this interceptor's own
  /// refresh request was in-flight, otherwise returns null.
  Future<_TokenPair?> _checkForRaceRefresh(String? refreshTokenBefore) async {
    final currentAccess = await SecureTokenStorage.getAccessToken();
    final currentRefresh = await SecureTokenStorage.getRefreshToken();

    // A different refresh succeeded if the stored refresh token changed AND
    // we now have a non-empty access token.
    if (currentAccess != null &&
        currentAccess.isNotEmpty &&
        currentRefresh != null &&
        currentRefresh != refreshTokenBefore) {
      debugPrint(
        '✅ AuthInterceptor: detected race-refresh by another layer — reusing new tokens',
      );
      return _TokenPair(currentAccess, currentRefresh);
    }
    return null;
  }

  Future<Response> _retryRequest(
    RequestOptions options,
    String newAccessToken,
  ) async {
    options.headers['Authorization'] = 'Bearer $newAccessToken';
    return _dio.fetch(options);
  }

  void _resolveQueue(String newAccessToken) {
    for (final pending in _queue) {
      pending.options.headers['Authorization'] = 'Bearer $newAccessToken';
      _dio
          .fetch(pending.options)
          .then(
            pending.completer.complete,
            onError: pending.completer.completeError,
          );
    }
    _queue.clear();
  }

  void _rejectQueue() {
    for (final pending in _queue) {
      pending.completer.completeError(
        DioException(
          requestOptions: pending.options,
          message: 'Session expired',
        ),
      );
    }
    _queue.clear();
  }

  Future<void> _handleForceLogout() async {
    debugPrint('🚪 AuthInterceptor: force logout — clearing tokens');
    await SecureTokenStorage.clearTokens();
    try {
      await onForceLogout();
    } catch (e) {
      debugPrint('AuthInterceptor: force logout callback error — $e');
    }
  }
}

class _TokenPair {
  const _TokenPair(this.accessToken, this.refreshToken);
  final String accessToken;
  final String refreshToken;
}

class _PendingRequest {
  const _PendingRequest(this.options, this.completer);
  final RequestOptions options;
  final Completer<Response> completer;
}
