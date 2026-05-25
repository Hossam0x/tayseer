import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tayseer/core/constant/constans_keys.dart';

/// Handles secure storage of access and refresh tokens.
/// Uses flutter_secure_storage (Keychain on iOS, Keystore on Android).
///
/// Migration note: Users who logged in before the dual-token migration will
/// have their old single `token` in SharedPreferences (ktoken key).
/// [getAccessToken] falls back to that value so existing sessions keep working
/// until the next login. [getRefreshToken] returns null for legacy users —
/// they will be forced to re-login when their token expires.
class SecureTokenStorage {
  SecureTokenStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ─── Access Token ───────────────────────────────────────────────────────

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: kAccessToken, value: token);
  }

  /// Returns the stored accessToken.
  /// Falls back to the legacy SharedPreferences `ktoken` key for users who
  /// haven't re-logged-in since the dual-token migration.
  static Future<String?> getAccessToken() async {
    final token = await _storage.read(key: kAccessToken);
    if (token != null && token.isNotEmpty) return token;

    // Legacy fallback — old single token stored in SharedPrefs
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(ktoken) ?? '';
    if (legacy.isNotEmpty) {
      debugPrint(
        '⚠️ SecureTokenStorage: using legacy SharedPrefs token as accessToken',
      );
    }
    return legacy.isEmpty ? null : legacy;
  }

  // ─── Refresh Token ──────────────────────────────────────────────────────

  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: kRefreshToken, value: token);
  }

  /// Returns the stored refreshToken, or null if not available.
  /// Legacy users (pre-migration) will get null here — they will be
  /// force-logged-out when their accessToken expires (no refresh possible).
  static Future<String?> getRefreshToken() async {
    final token = await _storage.read(key: kRefreshToken);
    if (token != null && token.isNotEmpty) return token;
    return null;
  }

  // ─── Save Both ──────────────────────────────────────────────────────────

  static Future<void> saveBothTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
    debugPrint('✅ SecureTokenStorage: both tokens saved');
  }

  // ─── Clear ──────────────────────────────────────────────────────────────

  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: kAccessToken),
      _storage.delete(key: kRefreshToken),
    ]);
    debugPrint('🗑️ SecureTokenStorage: tokens cleared');
  }

  // ─── Legacy single token (partial/OTP flows) ────────────────────────────

  static Future<void> savePartialToken(String token) async {
    await _storage.write(key: ktoken, value: token);
  }

  static Future<String?> getPartialToken() async {
    return _storage.read(key: ktoken);
  }

  static Future<void> clearPartialToken() async {
    await _storage.delete(key: ktoken);
  }
}
