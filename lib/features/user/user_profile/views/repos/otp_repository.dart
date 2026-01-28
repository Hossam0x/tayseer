// features/otp/data/repositories/otp_repository.dart
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';

abstract class OtpRepository {
  Future<Either<Failure, bool>> verifyOtp(String otpCode);
  Future<Either<Failure, bool>> resendOtp({
    required String countryCode,
    required String phoneNumber,
  });
}

class OtpRepositoryImpl implements OtpRepository {
  final Dio _dio;
  final String _baseUrl = 'https://tayser-app.net/api/v1';

  OtpRepositoryImpl(this._dio);

  @override
  Future<Either<Failure, bool>> verifyOtp(String otpCode) async {
    try {
      // ⭐⭐ الحصول على الـ token بنفس الطريقة في ApiService
      final token = CachNetwork.getStringData(key: 'token');

      final response = await _dio.request(
        '$_baseUrl/user/verfiy-phone',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
        data: json.encode({'otp': otpCode}),
      );

      final responseData = response.data as Map<String, dynamic>;

      print('✅ استجابة التحقق: ${responseData['success']}');
      print('📝 الرسالة: ${responseData['message']}');

      if (responseData['success'] == true) {
        return Right(true);
      } else {
        return Left(
          ServerFailure(responseData['message'] ?? 'فشل التحقق من الرمز'),
        );
      }
    } on DioException catch (e) {
      print('❌ خطأ Dio في التحقق: ${e.message}');
      print('❌ الـ URL: ${e.requestOptions.path}');
      print('❌ status code: ${e.response?.statusCode}');
      print('❌ response data: ${e.response?.data}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      print('❌ خطأ غير متوقع في التحقق: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resendOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {
    try {
      // ⭐⭐ الحصول على الـ token بنفس الطريقة
      final token = CachNetwork.getStringData(key: 'token');

      print('🔄 محاولة إعادة إرسال OTP');
      print('📞 countryCode: $countryCode');
      print('📞 phone: $phoneNumber');
      print('🔑 token موجود: ${token.isNotEmpty}');

      final response = await _dio.request(
        '$_baseUrl/user/update-phone-number',
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
        data: json.encode({'countryCode': countryCode, 'phone': phoneNumber}),
      );

      final responseData = response.data as Map<String, dynamic>;

      print('✅ استجابة إعادة الإرسال: ${responseData['success']}');
      print('📝 الرسالة: ${responseData['message']}');

      if (responseData['success'] == true) {
        return Right(true);
      } else {
        return Left(
          ServerFailure(responseData['message'] ?? 'فشل إعادة إرسال الرمز'),
        );
      }
    } on DioException catch (e) {
      print('❌ خطأ Dio في إعادة الإرسال: ${e.message}');
      print('❌ الـ URL: ${e.requestOptions.path}');
      print('❌ status code: ${e.response?.statusCode}');
      print('❌ response data: ${e.response?.data}');
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      print('❌ خطأ غير متوقع في إعادة الإرسال: $e');
      return Left(ServerFailure(e.toString()));
    }
  }
}
