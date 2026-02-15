part of 'otp_cubit.dart';

enum OtpStatus { initial, loading, success, failure }

class OtpState {
  final OtpStatus otpStatus;
  final String phoneNumber;
  final bool isPhoneUpdate;
  final bool isEmailUpdate;
  final String otpCode;
  final String errorMessage;
  final String successMessage;
  final int resendSeconds;
  final bool canResend;

  const OtpState({
    this.otpStatus = OtpStatus.initial,
    required this.phoneNumber,
    this.isPhoneUpdate = false,
    this.isEmailUpdate = false,
    this.otpCode = '',
    this.errorMessage = '',
    this.successMessage = '',
    this.resendSeconds = 300,
    this.canResend = false,
  });

  bool get isLoading => otpStatus == OtpStatus.loading;
  bool get canSubmit => otpCode.length == 6 && !isLoading;

  OtpState copyWith({
    OtpStatus? otpStatus,
    String? phoneNumber,
    bool? isPhoneUpdate,
    bool? isEmailUpdate,
    String? otpCode,
    String? errorMessage,
    String? successMessage,
    int? resendSeconds,
    bool? canResend,
  }) {
    return OtpState(
      otpStatus: otpStatus ?? this.otpStatus,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneUpdate: isPhoneUpdate ?? this.isPhoneUpdate,
      isEmailUpdate: isEmailUpdate ?? this.isEmailUpdate,
      otpCode: otpCode ?? this.otpCode,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      canResend: canResend ?? this.canResend,
    );
  }
}

class OtpInitial extends OtpState {
  OtpInitial({
    required super.phoneNumber,
    required super.isPhoneUpdate,
    super.isEmailUpdate = false,
    super.resendSeconds = 300,
  });
}
