import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/user/user_profile/views/repos/otp_repository.dart';
import 'package:tayseer/my_import.dart';
part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepository _otpRepository;
  final SnackBarService _snackBarService = SnackBarService();
  Timer? _resendTimer;

  // ⭐⭐ إضافة متغير لتحديد مصدر الـ OTP
  final OtpSource _otpSource;

  OtpCubit({
    required String phoneNumber,
    required bool isPhoneUpdate,
    bool isEmailUpdate = false,
    required OtpRepository otpRepository,
    OtpSource otpSource = OtpSource.phone, // ⭐⭐ القيمة الافتراضية للتوافق
  }) : _otpRepository = otpRepository,
       _otpSource = otpSource,
       super(
         OtpInitial(
           phoneNumber: phoneNumber,
           isPhoneUpdate: isPhoneUpdate,
           isEmailUpdate: isEmailUpdate,
           resendSeconds: 300,
         ),
       ) {
    _startResendTimer();
  }

  void updateOtpCode(String code) {
    emit(state.copyWith(otpCode: code));
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendSeconds > 0) {
        emit(state.copyWith(resendSeconds: state.resendSeconds - 1));
      } else {
        timer.cancel();
        emit(state.copyWith(canResend: true));
      }
    });
  }

  // استخراج رمز الدولة + الرقم (يُستخدم فقط في حالة isPhoneUpdate)
  ({String countryCode, String phoneNumber})? _extractPhoneParts(
    String fullPhone,
  ) {
    try {
      final countries = [
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
      ];

      for (var country in countries) {
        final code = country['code']!;
        if (fullPhone.startsWith(code)) {
          return (
            countryCode: code,
            phoneNumber: fullPhone.substring(code.length),
          );
        }
      }

      // لو مفيش كود معروف → نرجع الرقم كامل كـ phoneNumber
      return (countryCode: '', phoneNumber: fullPhone);
    } catch (e) {
      return null;
    }
  }

  Future<void> resendCode(BuildContext context) async {
    if (!state.canResend || state.otpStatus == OtpStatus.loading) return;

    emit(state.copyWith(otpStatus: OtpStatus.loading, canResend: false));

    // ⭐⭐ تحديد الـ endpoint بناءً على المصدر
    if (_otpSource == OtpSource.email) {
      // ── حالة إعادة إرسال للإيميل ──
      final result = await _otpRepository.resendEmailOtp(
        email: state.phoneNumber,
      );

      result.fold(
        (failure) {
          _showError(context, failure.message);
          emit(
            state.copyWith(
              otpStatus: OtpStatus.failure,
              errorMessage: failure.message,
              canResend: true,
            ),
          );
        },
        (_) {
          emit(
            state.copyWith(
              resendSeconds: 300,
              otpStatus: OtpStatus.initial,
              errorMessage: '',
              canResend: false,
            ),
          );
          _startResendTimer();
          _showSuccess(
            context,
            'تم إعادة إرسال رمز التحقق على البريد الإلكتروني',
          );
        },
      );
    } else if (_otpSource == OtpSource.editPhone) {
      // ⭐⭐ حالة إعادة إرسال لتعديل رقم الهاتف
      final phoneParts = _extractPhoneParts(state.phoneNumber);
      if (phoneParts == null || phoneParts.countryCode.isEmpty) {
        _showError(context, 'تنسيق رقم الهاتف غير صحيح');
        emit(state.copyWith(otpStatus: OtpStatus.initial, canResend: true));
        return;
      }

      final result = await _otpRepository.resendEditPhoneOtp(
        countryCode: phoneParts.countryCode,
        phoneNumber: phoneParts.phoneNumber,
      );

      result.fold(
        (failure) {
          _showError(context, failure.message);
          emit(
            state.copyWith(
              otpStatus: OtpStatus.failure,
              errorMessage: failure.message,
              canResend: true,
            ),
          );
        },
        (_) {
          emit(
            state.copyWith(
              resendSeconds: 300,
              otpStatus: OtpStatus.initial,
              errorMessage: '',
              canResend: false,
            ),
          );
          _startResendTimer();
          _showSuccess(context, 'تم إعادة إرسال رمز التحقق');
        },
      );
    } else {
      // ── حالة إعادة إرسال للجوال العادي (التسجيل/تسجيل الدخول) ──
      // ⭐⭐ هنا يمكنك إضافة الـ endpoint الخاص بالتسجيل إذا كان مختلفاً
      // أو استخدام نفس الـ endpoint مع معاملات مختلفة
      _showError(context, 'هذه العملية غير مدعومة حالياً');
      emit(state.copyWith(otpStatus: OtpStatus.initial, canResend: true));
    }
  }

  Future<void> verifyOtp(BuildContext context) async {
    // ... التحقق من الطول والحالة ...

    emit(state.copyWith(otpStatus: OtpStatus.loading));

    switch (_otpSource) {
      case OtpSource.email:
        final result = await _otpRepository.verifyEmailOtp(state.otpCode);
        _handleVerificationResult(
          context,
          result,
          'تم تأكيد البريد الإلكتروني بنجاح',
        );
        break;

      case OtpSource.editPhone:
        final result = await _otpRepository.verifyEditPhoneOtp(state.otpCode);
        _handleVerificationResult(context, result, 'تم تأكيد رقم الهاتف بنجاح');
        break;

      case OtpSource.phone:
        // ⭐⭐ استخدام الـ endpoint العادي
        // final result = await _otpRepository.verifyPhoneOtp(state.otpCode);
        // أو استخدام تعديل الهاتف إذا كان نفس الـ endpoint
        final result = await _otpRepository.verifyEditPhoneOtp(state.otpCode);
        _handleVerificationResult(context, result, 'تم التحقق بنجاح');
        break;
    }
  }

  void _handleVerificationResult(
    BuildContext context,
    Either<Failure, bool> result,
    String successMessage,
  ) {
    result.fold(
      (failure) {
        _showError(context, failure.message);
        emit(
          state.copyWith(
            otpStatus: OtpStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(otpStatus: OtpStatus.success, errorMessage: ''));
        _showSuccess(context, successMessage);
      },
    );
  }

  void _showError(BuildContext context, String message) {
    if (context.mounted) {
      _snackBarService.showSnackBar(
        context: context,
        text: message,
        isError: true,
      );
    }
  }

  void _showSuccess(BuildContext context, String message) {
    if (context.mounted) {
      _snackBarService.showSnackBar(
        context: context,
        text: message,
        isSuccess: true,
      );
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

// ⭐⭐ إضافة enum لتحديد مصدر الـ OTP
enum OtpSource {
  phone, // للـ OTP العادي (التسجيل/تسجيل الدخول)
  editPhone, // لتعديل رقم الهاتف
  email, // لتعديل البريد الإلكتروني
}
