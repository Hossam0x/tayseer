import 'package:dio/dio.dart';
import '../constant/constans.dart';

/// HTTP client wrapper.
///
/// The [AuthInterceptor] (registered on the [Dio] instance in get_it.dart)
/// automatically attaches `Authorization: Bearer <accessToken>` to every
/// request and handles 401 token-refresh transparently.
///
/// IMPORTANT: We do NOT set a custom validateStatus here.
/// Dio's default behaviour (2xx = success, else = DioException) is required
/// so that the AuthInterceptor's onError hook fires on 401 responses and can
/// trigger the refresh-token flow.
class ApiService {
  final Dio _dio;
  ApiService(this._dio);

  // ─── GET ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get({
    required String endPoint,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.get(
        "$kbaseUrl$endPoint",
        queryParameters: query,
        options: Options(
          headers: {
            'lang': selectedLanguage ?? 'ar',
            'Accept': 'application/json',
          },
        ),
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      rethrow;
    }
  }

  // ─── POST ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> post({
    bool isFromData = false,
    required String endPoint,
    dynamic data,
    bool? isAuth,
    Map<String, dynamic>? headers,
    void Function(int, int)? onSendProgress,
    Map<String, dynamic>? query,
  }) async {
    try {
      final mergedHeaders = <String, dynamic>{
        'lang': selectedLanguage ?? 'ar',
        ...?headers,
      };

      final response = await _dio.post(
        "$kbaseUrl$endPoint",
        data: isFromData ? FormData.fromMap(data) : data,
        queryParameters: query,
        options: Options(headers: mergedHeaders),
        onSendProgress: onSendProgress,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      rethrow;
    }
  }

  // ─── PATCH ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> patch({
    bool isFromData = false,
    required String endPoint,
    dynamic data,
    Map<String, dynamic>? headers,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final mergedHeaders = <String, dynamic>{
        'lang': selectedLanguage ?? 'ar',
        'Accept': 'application/json',
        ...?headers,
      };

      final response = await _dio.patch(
        "$kbaseUrl$endPoint",
        data: isFromData
            ? (data is FormData ? data : FormData.fromMap(data))
            : data,
        options: Options(headers: mergedHeaders),
        onSendProgress: onSendProgress,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      rethrow;
    }
  }

  // ─── DELETE ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> delete({
    required String endPoint,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? data,
  }) async {
    try {
      final mergedHeaders = <String, dynamic>{
        'lang': selectedLanguage ?? 'ar',
        'Accept': 'application/json',
        ...?headers,
      };

      final response = await _dio.delete(
        "$kbaseUrl$endPoint",
        data: data,
        options: Options(headers: mergedHeaders),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) return e.response!.data;
      rethrow;
    }
  }
}
