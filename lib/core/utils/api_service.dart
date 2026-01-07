import 'package:tayseer/core/shared/network/local_network.dart';
import 'package:dio/dio.dart';
import '../constant/constans.dart';

class ApiService {
  final Dio _dio;
  ApiService(this._dio);

  Future<Map<String, dynamic>> get({
    required String endPoint,
    Map<String, dynamic>? query,
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = <String, dynamic>{
        'Accept-Language': selectedLanguage ?? 'ar',
      };
      headers['Authorization'] =
          'Bearer ${CachNetwork.getStringData(key: 'token')}';
      headers["Accept"] = "application/json";
      final response = await _dio.get(
        "$kbaseUrl$endPoint",
        queryParameters: query,
        options: Options(headers: headers),
        data: data,
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      } else {
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> post({
    bool isFromData = false,
    required String endPoint,
    dynamic data,
    bool? isAuth,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final mergedHeaders = {
        // 'Accept-Language': selectedLanguage ?? 'ar',
        // 'Accept': 'application/json',
        'Authorization': "Bearer ${CachNetwork.getStringData(key: 'token')}",
        ...?headers,
      };

      var response = await _dio.post(
        "$kbaseUrl$endPoint",
        data: isFromData ? FormData.fromMap(data) : data,
        options: Options(
          headers: mergedHeaders,
          validateStatus: (status) => status! >= 200 && status < 300,
        ),
      );
      return response.data;
    } on DioException {
      rethrow; // ✅ Re-throw للـ repository يقدر يـ handle الـ error
    }
  }

  Future<Map<String, dynamic>> patch({
    bool isFromData = false,
    required String endPoint,
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final mergedHeaders = <String, dynamic>{
        'Accept-Language': selectedLanguage ?? 'ar',
      };
      mergedHeaders['Authorization'] =
          'Bearer ${CachNetwork.getStringData(key: 'token')}';
      mergedHeaders["Accept"] = "application/json";

      if (headers != null) {
        mergedHeaders.addAll(headers);
      }

      var response = await _dio.patch(
        "$kbaseUrl$endPoint",
        data: isFromData ? FormData.fromMap(data) : data,
        options: Options(
          headers: mergedHeaders,
          validateStatus: (status) => status! >= 200 && status < 300,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      } else {
        rethrow;
      }
    }
  }

  Future<Map<String, dynamic>> delete({
    required String endPoint,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final mergedHeaders = {
        'Accept-Language': selectedLanguage ?? 'ar',
        ...?headers,
      };

      var response = await _dio.delete(
        "$kbaseUrl$endPoint",
        options: Options(
          headers: mergedHeaders,
          validateStatus: (status) => status! >= 200 && status < 300,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data;
      } else {
        rethrow;
      }
    }
  }
}
