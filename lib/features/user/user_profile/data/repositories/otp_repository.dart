import 'package:dartz/dartz.dart';
import 'package:tayseer/core/utils/api_service.dart';
import 'package:tayseer/my_import.dart';

abstract class OtpRepository {
  Future<Either<Failure, bool>> verifyEditPhoneOtp(String otpCode);
  Future<Either<Failure, bool>> resendEditPhoneOtp({
    required String countryCode,
    required String phoneNumber,
  });

  Future<Either<Failure, bool>> verifyEmailOtp(String otpCode);
  Future<Either<Failure, bool>> resendEmailOtp({required String email});

  Future<Either<Failure, bool>> verifyPhoneOtp(String otpCode);
  Future<Either<Failure, bool>> resendPhoneOtp(String phoneNumber);
}

class OtpRepositoryImpl implements OtpRepository {
  final ApiService _apiService;

  OtpRepositoryImpl(this._apiService);

  // ─── Verify phone OTP (edit phone flow) ─────────────────────────────────

  @override
  Future<Either<Failure, bool>> verifyEditPhoneOtp(String otpCode) async {
    return _safeCall(() async {
      final data = await _apiService.post(
        endPoint: '/user/verfiy-phone',
        data: {'otp': otpCode},
      );
      return _parseSuccess(data);
    });
  }

  // ─── Resend phone OTP (edit phone flow) ─────────────────────────────────

  @override
  Future<Either<Failure, bool>> resendEditPhoneOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {
    return _safeCall(() async {
      final data = await _apiService.post(
        endPoint: '/user/update-phone-number',
        data: {'countryCode': countryCode, 'phone': phoneNumber},
      );
      return _parseSuccess(data);
    });
  }

  // ─── Verify email OTP ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> verifyEmailOtp(String otpCode) async {
    return _safeCall(() async {
      final data = await _apiService.post(
        endPoint: '/user/verfiy-email',
        data: {'otp': otpCode},
      );
      return _parseSuccess(data);
    });
  }

  // ─── Resend email OTP ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, bool>> resendEmailOtp({required String email}) async {
    return _safeCall(() async {
      final data = await _apiService.post(
        endPoint: '/user/update-email',
        data: {'email': email},
      );
      return _parseSuccess(data);
    });
  }

  // ─── Generic phone OTP (not yet implemented) ─────────────────────────────

  @override
  Future<Either<Failure, bool>> verifyPhoneOtp(String otpCode) async {
    return Left(ServerFailure('verifyPhoneOtp not implemented'));
  }

  @override
  Future<Either<Failure, bool>> resendPhoneOtp(String phoneNumber) async {
    return Left(ServerFailure('resendPhoneOtp not implemented'));
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  Either<Failure, bool> _parseSuccess(Map<String, dynamic> data) {
    if (data['success'] == true) return const Right(true);
    final msg = data['message']?.toString() ?? 'حدث خطأ';
    return Left(ServerFailure(msg));
  }

  Future<Either<Failure, bool>> _safeCall(
    Future<Either<Failure, bool>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final msg =
            (e.response!.data as Map)['message']?.toString() ??
            e.message ??
            'حدث خطأ';
        return Left(ServerFailure(msg));
      }
      return Left(ServerFailure.fromDioError(e));
    } catch (e) {
      return Left(ServerFailure('حدث خطأ غير متوقع'));
    }
  }
}
