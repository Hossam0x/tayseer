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

  OtpRepositoryImpl(this._dio) {
    // ⭐⭐ إلغاء رمي exception عند status codes 400, 401, 404, etc.
    _dio.options.validateStatus = (status) {
      return status! < 500; // قبول كل الـ status codes أقل من 500
    };
  }

  @override
  Future<Either<Failure, bool>> verifyOtp(String otpCode) async {
    try {
      final token = CachNetwork.getStringData(key: 'token');
      print('🔐 محاولة التحقق من OTP: $otpCode');
      print('🔑 Token: ${token.isNotEmpty ? "موجود" : "غير موجود"}');

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

      print('📡 Status Code: ${response.statusCode}');
      print('✅ Success: ${responseData['success']}');
      print('📝 Message: ${responseData['message']}');
      print('📦 Full Response: $responseData');

      if (responseData['success'] == true) {
        return Right(true);
      } else {
        // ⭐⭐ إرجاع رسالة الخطأ من الـ backend مباشرة
        final errorMessage =
            responseData['message']?.toString() ?? 'فشل التحقق من الرمز';
        return Left(ServerFailure(errorMessage));
      }
    } on DioException catch (e) {
      print('❌ خطأ Dio في التحقق: ${e.message}');

      // ⭐⭐ إذا كان هناك response، استخدم رسالته
      if (e.response != null && e.response!.data != null) {
        final responseData = e.response!.data as Map<String, dynamic>;
        final errorMessage =
            responseData['message']?.toString() ?? e.message ?? 'حدث خطأ';
        print('📝 رسالة الخطأ من السيرفر: $errorMessage');
        return Left(ServerFailure(errorMessage));
      }

      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      print('❌ خطأ غير متوقع في التحقق: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> resendOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {
    try {
      final token = CachNetwork.getStringData(key: 'token');
      print('🔄 محاولة إعادة إرسال OTP');
      print('📞 countryCode: $countryCode');
      print('📞 phone: $phoneNumber');

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
        final errorMessage =
            responseData['message']?.toString() ?? 'فشل إعادة إرسال الرمز';
        return Left(ServerFailure(errorMessage));
      }
    } on DioException catch (e) {
      print('❌ خطأ Dio في إعادة الإرسال: ${e.message}');

      if (e.response != null && e.response!.data != null) {
        final responseData = e.response!.data as Map<String, dynamic>;
        final errorMessage =
            responseData['message']?.toString() ?? e.message ?? 'حدث خطأ';
        return Left(ServerFailure(errorMessage));
      }

      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      print('❌ خطأ غير متوقع في إعادة الإرسال: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع: $e'));
    }
  }
}
