// features/otp/data/repositories/otp_repository.dart
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:tayseer/my_import.dart';

abstract class OtpRepository {
  // ⭐⭐ إعادة تسمية الدوال لتكون أكثر وضوحاً
  Future<Either<Failure, bool>> verifyEditPhoneOtp(String otpCode);
  Future<Either<Failure, bool>> resendEditPhoneOtp({
    required String countryCode,
    required String phoneNumber,
  });

  // ── للإيميل ──
  Future<Either<Failure, bool>> verifyEmailOtp(String otpCode);
  Future<Either<Failure, bool>> resendEmailOtp({required String email});

  // ⭐⭐ إضافة دوال للـ OTP العادي (إذا كان هناك endpoints مختلفة)
  Future<Either<Failure, bool>> verifyPhoneOtp(String otpCode);
  Future<Either<Failure, bool>> resendPhoneOtp(String phoneNumber);
}

class OtpRepositoryImpl implements OtpRepository {
  final Dio _dio;

  OtpRepositoryImpl(this._dio) {
    _dio.options.validateStatus = (status) {
      return status! < 500;
    };
  }

  @override
  Future<Either<Failure, bool>> verifyEditPhoneOtp(String otpCode) async {
    try {
      final token = CachNetwork.getStringData(key: 'token');
      print('🔐 محاولة التحقق من OTP لتعديل الهاتف: $otpCode');
      print('🔑 Token: ${token.isNotEmpty ? "موجود" : "غير موجود"}');

      final response = await _dio.request(
        '$kbaseUrl/user/verfiy-phone', // ⭐⭐ endpoint تعديل الهاتف
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
        final errorMessage =
            responseData['message']?.toString() ?? 'فشل التحقق من الرمز';
        return Left(ServerFailure(errorMessage));
      }
    } on DioException catch (e) {
      print('❌ خطأ Dio في التحقق: ${e.message}');

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
  Future<Either<Failure, bool>> resendEditPhoneOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {
    try {
      final token = CachNetwork.getStringData(key: 'token');
      print('🔄 محاولة إعادة إرسال OTP لتعديل الهاتف');
      print('📞 countryCode: $countryCode');
      print('📞 phone: $phoneNumber');

      final response = await _dio.request(
        '$kbaseUrl/user/update-phone-number', // ⭐⭐ endpoint تعديل الهاتف
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

  @override
  Future<Either<Failure, bool>> verifyEmailOtp(String otpCode) async {
    try {
      final token = CachNetwork.getStringData(key: 'token');
      print('🔐 محاولة التحقق من OTP الإيميل: $otpCode');

      final response = await _dio.request(
        '$kbaseUrl/user/verfiy-email', // ⭐⭐ endpoint تعديل الإيميل
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

      final data = response.data as Map<String, dynamic>;
      print(
        '📡 verify-email → ${response.statusCode} | success: ${data['success']}',
      );

      if (data['success'] == true) {
        return const Right(true);
      }

      final msg = data['message']?.toString() ?? 'فشل التحقق من رمز الإيميل';
      return Left(ServerFailure(msg));
    } on DioException catch (e) {
      print('❌ DioException verify-email: ${e.message}');
      if (e.response?.data != null) {
        final msg =
            (e.response!.data as Map)['message']?.toString() ??
            e.message ??
            'خطأ';
        return Left(ServerFailure(msg));
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      print('❌ unexpected verify-email: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, bool>> resendEmailOtp({required String email}) async {
    try {
      final token = CachNetwork.getStringData(key: 'token');
      print('🔄 إعادة إرسال OTP للإيميل: $email');

      final response = await _dio.request(
        '$kbaseUrl/user/update-email', // ⭐⭐ endpoint تعديل الإيميل
        options: Options(
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
        data: json.encode({'email': email}),
      );

      final data = response.data as Map<String, dynamic>;
      print(
        '📡 resend-email → Status: ${response.statusCode} | success: ${data['success']}',
      );

      if (data['success'] == true) {
        print('✅ تم إرسال رمز التحقق للإيميل بنجاح');
        return const Right(true);
      }

      final msg = data['message']?.toString() ?? 'فشل إعادة إرسال الرمز';
      print('❌ فشل إرسال الرمز: $msg');
      return Left(ServerFailure(msg));
    } on DioException catch (e) {
      print('❌ DioException resend-email: ${e.message}');
      if (e.response?.data != null) {
        final msg =
            (e.response!.data as Map)['message']?.toString() ??
            e.message ??
            'خطأ';
        print('   رسالة الخطأ من السيرفر: $msg');
        return Left(ServerFailure(msg));
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      print('❌ unexpected resend-email: $e');
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }

  // ⭐⭐ الدوال للـ OTP العادي (يمكنك إضافتها لاحقاً)
  @override
  Future<Either<Failure, bool>> verifyPhoneOtp(String otpCode) async {
    // endpoint مختلف للـ OTP العادي
    throw UnimplementedError('verifyPhoneOtp not implemented yet');
  }

  @override
  Future<Either<Failure, bool>> resendPhoneOtp(String phoneNumber) async {
    // endpoint مختلف للـ OTP العادي
    throw UnimplementedError('resendPhoneOtp not implemented yet');
  }
}
