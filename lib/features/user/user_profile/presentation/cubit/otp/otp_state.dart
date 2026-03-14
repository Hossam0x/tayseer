part of 'otp_cubit.dart';

enum OtpStatus { initial, loading, success, failure }

class OtpState {
  final OtpStatus otpStatus;
  final String otpCode;
  final String phoneNumber;
  final bool isPhoneUpdate;
  final bool isEmailUpdate;
  final int resendSeconds;
  final bool canResend;
  final String errorMessage;
  final String successMessage;

  OtpState({
    required this.otpStatus,
    required this.otpCode,
    required this.phoneNumber,
    required this.isPhoneUpdate,
    required this.isEmailUpdate,
    required this.resendSeconds,
    required this.canResend,
    required this.errorMessage,
    required this.successMessage,
  });

  bool get isLoading => otpStatus == OtpStatus.loading;

  OtpState copyWith({
    OtpStatus? otpStatus,
    String? otpCode,
    String? phoneNumber,
    bool? isPhoneUpdate,
    bool? isEmailUpdate,
    int? resendSeconds,
    bool? canResend,
    String? errorMessage,
    String? successMessage,
  }) {
    return OtpState(
      otpStatus: otpStatus ?? this.otpStatus,
      otpCode: otpCode ?? this.otpCode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneUpdate: isPhoneUpdate ?? this.isPhoneUpdate,
      isEmailUpdate: isEmailUpdate ?? this.isEmailUpdate,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      canResend: canResend ?? this.canResend,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

class OtpInitial extends OtpState {
  OtpInitial({
    required super.phoneNumber,
    required super.isPhoneUpdate,
    required super.isEmailUpdate,
    required super.resendSeconds,
  }) : super(
          otpStatus: OtpStatus.initial,
          otpCode: '',
          canResend: false,
          errorMessage: '',
          successMessage: '',
        );
}
