part of 'phone_edit_cubit.dart';

class PhoneEditState {
  final CubitStates updatePhoneStatus;
  final String selectedCountryCode;
  final String selectedCountryFlag;
  final String selectedCountryName;
  final String phoneNumber;
  final String phoneError;
  final String errorMessage;
  final String successMessage;
  final String fullPhoneNumber;

  const PhoneEditState({
    this.updatePhoneStatus = CubitStates.initial,
    this.selectedCountryCode = "+966",
    this.selectedCountryFlag = "🇸🇦",
    this.selectedCountryName = "السعودية",
    this.phoneNumber = '',
    this.phoneError = '',
    this.errorMessage = '',
    this.successMessage = '',
    this.fullPhoneNumber = '',
  });

  bool get canProceed => phoneNumber.isNotEmpty && phoneError.isEmpty;
  bool get isLoading => updatePhoneStatus == CubitStates.loading;

  PhoneEditState copyWith({
    CubitStates? updatePhoneStatus,
    String? selectedCountryCode,
    String? selectedCountryFlag,
    String? selectedCountryName,
    String? phoneNumber,
    String? phoneError,
    String? errorMessage,
    String? successMessage,
    String? fullPhoneNumber,
  }) {
    return PhoneEditState(
      updatePhoneStatus: updatePhoneStatus ?? this.updatePhoneStatus,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      selectedCountryFlag: selectedCountryFlag ?? this.selectedCountryFlag,
      selectedCountryName: selectedCountryName ?? this.selectedCountryName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneError: phoneError ?? this.phoneError,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      fullPhoneNumber: fullPhoneNumber ?? this.fullPhoneNumber,
    );
  }
}

class PhoneEditInitial extends PhoneEditState {}
