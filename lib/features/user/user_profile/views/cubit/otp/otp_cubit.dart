// features/otp/otp_cubit.dart
import 'dart:async';
import 'package:tayseer/my_import.dart';
part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  OtpCubit({required String phoneNumber, required bool isPhoneUpdate})
    : super(
        OtpInitial(phoneNumber: phoneNumber, isPhoneUpdate: isPhoneUpdate),
      ) {
    _startResendTimer();
  }

  final ApiService _apiService = ApiService(Dio());
  Timer? _resendTimer;
  int _resendSeconds = 120;

  void updateOtpCode(String code) {
    emit(state.copyWith(otpCode: code));
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendSeconds = 120;

    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        _resendSeconds--;
        emit(state.copyWith(resendSeconds: _resendSeconds));
      } else {
        timer.cancel();
        emit(state.copyWith(canResend: true));
      }
    });
  }

  // ✅ دالة إعادة إرسال OTP - نفس endpoint تحديث الهاتف
  Future<void> resendCode() async {
    if (!state.canResend || state.otpStatus == OtpStatus.loading) return;

    emit(state.copyWith(otpStatus: OtpStatus.loading));

    try {
      // استخراج رمز الدولة والرقم من رقم الهاتف الكامل
      final phoneParts = _extractPhoneParts(state.phoneNumber);
      if (phoneParts == null) {
        throw Exception('تنسيق رقم الهاتف غير صحيح');
      }

      final String countryCode = phoneParts['countryCode']!;
      final String phone = phoneParts['phone']!;

      // ✅ استدعاء نفس endpoint تحديث الهاتف
      final response = await _apiService.post(
        isFromData: false,
        endPoint: '/user/update-phone-number',
        data: {'countryCode': countryCode, 'phone': phone},
      );

      if (response['success'] == true) {
        _startResendTimer();
        emit(state.copyWith(otpStatus: OtpStatus.initial, errorMessage: ''));
      } else {
        emit(
          state.copyWith(
            otpStatus: OtpStatus.failure,
            errorMessage: response['message'] ?? 'فشل إعادة إرسال الرمز',
          ),
        );
      }
    } catch (error) {
      emit(
        state.copyWith(
          otpStatus: OtpStatus.failure,
          errorMessage: 'خطأ في الاتصال: $error',
        ),
      );
    }
  }

  // ✅ دالة التحقق من OTP - endpoint جديد
  Future<void> verifyOtp() async {
    if (state.otpCode.length != 6 || state.otpStatus == OtpStatus.loading) {
      return;
    }

    emit(state.copyWith(otpStatus: OtpStatus.loading));

    try {
      // استخراج رمز الدولة والرقم من رقم الهاتف الكامل
      final phoneParts = _extractPhoneParts(state.phoneNumber);
      if (phoneParts == null) {
        throw Exception('تنسيق رقم الهاتف غير صحيح');
      }

      final String countryCode = phoneParts['countryCode']!;
      final String phone = phoneParts['phone']!;

      // ✅ استدعاء endpoint التحقق من الهاتف الجديد
      final response = await _apiService.post(
        isFromData: false,
        endPoint: '/user/verify-phone',
        data: {
          'countryCode': countryCode,
          'phone': phone,
          'code': state.otpCode,
        },
      );

      if (response['success'] == true) {
        emit(state.copyWith(otpStatus: OtpStatus.success, errorMessage: ''));
      } else {
        emit(
          state.copyWith(
            otpStatus: OtpStatus.failure,
            errorMessage: response['message'] ?? 'رمز التحقق غير صحيح',
          ),
        );
      }
    } catch (error) {
      emit(
        state.copyWith(
          otpStatus: OtpStatus.failure,
          errorMessage: 'خطأ في الاتصال: $error',
        ),
      );
    }
  }

  // ✅ دالة لاستخراج رمز الدولة والرقم من الرقم الكامل
  Map<String, String>? _extractPhoneParts(String fullPhone) {
    try {
      // البحث عن رمز الدولة في بداية الرقم
      for (var country in [
        {"code": "+966"},
        {"code": "+20"},
        {"code": "+971"},
        {"code": "+965"},
        {"code": "+974"},
        {"code": "+968"},
        {"code": "+973"},
        {"code": "+962"},
        {"code": "+961"},
        {"code": "+964"},
        {"code": "+212"},
        {"code": "+213"},
        {"code": "+216"},
      ]) {
        final code = country['code']!;
        if (fullPhone.startsWith(code)) {
          return {
            'countryCode': code,
            'phone': fullPhone.substring(code.length),
          };
        }
      }

      // إذا لم يتم العثور على رمز دولة معروف، استخدم الرقم كما هو
      return {
        'countryCode': '', // أو يمكن استخدام رمز افتراضي
        'phone': fullPhone,
      };
    } catch (e) {
      return null;
    }
  }

  void resetError() {
    emit(state.copyWith(otpStatus: OtpStatus.initial, errorMessage: ''));
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}
