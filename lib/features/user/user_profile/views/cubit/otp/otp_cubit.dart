// features/otp/otp_cubit.dart
import 'dart:async';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/user/user_profile/views/repos/otp_repository.dart';
import 'package:tayseer/my_import.dart';
part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepository _otpRepository;
  final SnackBarService _snackBarService = SnackBarService();
  Timer? _resendTimer;

  OtpCubit({
    required String phoneNumber,
    required bool isPhoneUpdate,
    required OtpRepository otpRepository,
  }) : _otpRepository = otpRepository,
       super(
         OtpInitial(
           phoneNumber: phoneNumber,
           isPhoneUpdate: isPhoneUpdate,
           resendSeconds: 300,
         ),
       ) {
    _startResendTimer();
  }

  // باقي الدوال كما هي بدون تغيير...
  void updateOtpCode(String code) {
    emit(state.copyWith(otpCode: code));
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (state.resendSeconds > 0) {
        emit(state.copyWith(resendSeconds: state.resendSeconds - 1));
      } else {
        timer.cancel();
        emit(state.copyWith(canResend: true));
      }
    });
  }

  // ✅ استخراج رمز الدولة والرقم من الرقم الكامل
  ({String countryCode, String phoneNumber})? _extractPhoneParts(
    String fullPhone,
  ) {
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
          return (
            countryCode: code,
            phoneNumber: fullPhone.substring(code.length),
          );
        }
      }

      // إذا لم يتم العثور على رمز دولة معروف
      return (countryCode: '', phoneNumber: fullPhone);
    } catch (e) {
      return null;
    }
  }

  Future<void> resendCode(BuildContext context) async {
    if (!state.canResend || state.otpStatus == OtpStatus.loading) return;

    emit(state.copyWith(otpStatus: OtpStatus.loading, canResend: false));

    // استخراج رمز الدولة والرقم
    final phoneParts = _extractPhoneParts(state.phoneNumber);
    if (phoneParts == null) {
      _showError(context, 'تنسيق رقم الهاتف غير صحيح');
      emit(state.copyWith(otpStatus: OtpStatus.initial, canResend: true));
      return;
    }

    final result = await _otpRepository.resendOtp(
      countryCode: phoneParts.countryCode,
      phoneNumber: phoneParts.phoneNumber,
    );

    if (isClosed) return;

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
      (success) {
        emit(
          state.copyWith(
            resendSeconds: 300,
            otpStatus: OtpStatus.initial,
            errorMessage: '',
            canResend: false,
          ),
        );
        _startResendTimer();
        _showSuccess(context, 'تم إعادة إرسال رمز التحقق بنجاح');
      },
    );
  }

  Future<void> verifyOtp(BuildContext context) async {
    if (state.otpCode.length != 6 || state.otpStatus == OtpStatus.loading) {
      if (state.otpCode.length != 6) {
        _showError(context, 'يجب إدخال الرمز المكون من 6 أرقام');
      }
      return;
    }

    emit(state.copyWith(otpStatus: OtpStatus.loading));

    final result = await _otpRepository.verifyOtp(state.otpCode);

    if (isClosed) return;

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
      (success) {
        emit(state.copyWith(otpStatus: OtpStatus.success, errorMessage: ''));
        _showSuccess(
          context,
          state.isPhoneUpdate ? 'تم تأكيد رقم الهاتف بنجاح' : 'تم التحقق بنجاح',
        );
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
