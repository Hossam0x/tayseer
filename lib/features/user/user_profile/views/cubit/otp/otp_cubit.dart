import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/otp_repository.dart';
import 'package:tayseer/my_import.dart';
part 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepository _otpRepository;
  Timer? _resendTimer;
  final OtpSource _otpSource;

  OtpCubit({
    required String phoneNumber,
    required bool isPhoneUpdate,
    bool isEmailUpdate = false,
    required OtpRepository otpRepository,
    OtpSource otpSource = OtpSource.phone,
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
    // No auto-verify on 6 digits here to avoid context/dialog complexity
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
      return (countryCode: '', phoneNumber: fullPhone);
    } catch (e) {
      return null;
    }
  }

  Future<void> resendCode() async {
    if (!state.canResend || state.otpStatus == OtpStatus.loading) return;

    emit(
      state.copyWith(
        otpStatus: OtpStatus.loading,
        canResend: false,
        errorMessage: '',
        successMessage: '',
      ),
    );

    if (_otpSource == OtpSource.email) {
      final result = await _otpRepository.resendEmailOtp(
        email: state.phoneNumber,
      );
      result.fold(
        (failure) {
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
              successMessage: 'otp_sent_success',
              canResend: false,
            ),
          );
          _startResendTimer();
        },
      );
    } else if (_otpSource == OtpSource.editPhone) {
      final phoneParts = _extractPhoneParts(state.phoneNumber);
      if (phoneParts == null || phoneParts.countryCode.isEmpty) {
        emit(
          state.copyWith(
            otpStatus: OtpStatus.failure,
            errorMessage: 'invalid_phone',
            canResend: true,
          ),
        );
        return;
      }

      final result = await _otpRepository.resendEditPhoneOtp(
        countryCode: phoneParts.countryCode,
        phoneNumber: phoneParts.phoneNumber,
      );

      result.fold(
        (failure) {
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
              successMessage: 'otp_sent_success',
              canResend: false,
            ),
          );
          _startResendTimer();
        },
      );
    } else {
      emit(
        state.copyWith(
          otpStatus: OtpStatus.failure,
          errorMessage: 'operation_not_supported',
          canResend: true,
        ),
      );
    }
  }

  Future<void> verifyOtp() async {
    if (state.otpCode.length != 6 || state.otpStatus == OtpStatus.loading)
      return;

    emit(
      state.copyWith(
        otpStatus: OtpStatus.loading,
        errorMessage: '',
        successMessage: '',
      ),
    );

    switch (_otpSource) {
      case OtpSource.email:
        final result = await _otpRepository.verifyEmailOtp(state.otpCode);
        _handleVerificationResult(result, 'otp_verify_success');
        break;

      case OtpSource.editPhone:
        final result = await _otpRepository.verifyEditPhoneOtp(state.otpCode);
        _handleVerificationResult(result, 'otp_verify_success');
        break;

      case OtpSource.phone:
        final result = await _otpRepository.verifyEditPhoneOtp(state.otpCode);
        _handleVerificationResult(result, 'otp_verify_success');
        break;
    }
  }

  void _handleVerificationResult(
    Either<Failure, bool> result,
    String successMsg,
  ) {
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            otpStatus: OtpStatus.failure,
            errorMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            otpStatus: OtpStatus.success,
            successMessage: successMsg,
          ),
        );
      },
    );
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: '', successMessage: ''));
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

enum OtpSource { phone, editPhone, email }
