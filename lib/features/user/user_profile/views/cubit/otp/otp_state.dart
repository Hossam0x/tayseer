// features/otp/otp_state.dart
part of 'otp_cubit.dart';

enum OtpStatus { initial, loading, success, failure }

class OtpState {
  final OtpStatus otpStatus;
  final String phoneNumber;
  final bool isPhoneUpdate;
  final String otpCode;
  final String errorMessage;
  final int resendSeconds;
  final bool canResend;

  const OtpState({
    this.otpStatus = OtpStatus.initial,
    required this.phoneNumber,
    required this.isPhoneUpdate,
    this.otpCode = '',
    this.errorMessage = '',
    this.resendSeconds = 120,
    this.canResend = false,
  });

  bool get isLoading => otpStatus == OtpStatus.loading;
  bool get canSubmit => otpCode.length == 6 && !isLoading;

  OtpState copyWith({
    OtpStatus? otpStatus,
    String? phoneNumber,
    bool? isPhoneUpdate,
    String? otpCode,
    String? errorMessage,
    int? resendSeconds,
    bool? canResend,
  }) {
    return OtpState(
      otpStatus: otpStatus ?? this.otpStatus,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneUpdate: isPhoneUpdate ?? this.isPhoneUpdate,
      otpCode: otpCode ?? this.otpCode,
      errorMessage: errorMessage ?? this.errorMessage,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      canResend: canResend ?? this.canResend,
    );
  }
}

class OtpInitial extends OtpState {
  OtpInitial({required super.phoneNumber, required super.isPhoneUpdate});
}
