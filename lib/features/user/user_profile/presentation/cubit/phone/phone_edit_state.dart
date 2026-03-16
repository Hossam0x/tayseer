part of 'phone_edit_cubit.dart';

class PhoneEditState {
  final String phoneNumber;
  final String phoneError;
  final String selectedCountryCode;
  final String selectedCountryFlag;
  final String selectedCountryName;
  final CubitStates updatePhoneStatus;
  final String successMessage;
  final String errorMessage;
  final String fullPhoneNumber;

  PhoneEditState({
    this.phoneNumber = '',
    this.phoneError = '',
    this.selectedCountryCode = '+966',
    this.selectedCountryFlag = '🇸🇦',
    this.selectedCountryName = 'السعودية',
    this.updatePhoneStatus = CubitStates.initial,
    this.successMessage = '',
    this.errorMessage = '',
    this.fullPhoneNumber = '',
  });

  bool get isLoading => updatePhoneStatus == CubitStates.loading;
  bool get canProceed => phoneNumber.isNotEmpty && phoneError.isEmpty;

  PhoneEditState copyWith({
    String? phoneNumber,
    String? phoneError,
    String? selectedCountryCode,
    String? selectedCountryFlag,
    String? selectedCountryName,
    CubitStates? updatePhoneStatus,
    String? successMessage,
    String? errorMessage,
    String? fullPhoneNumber,
  }) {
    return PhoneEditState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneError: phoneError ?? this.phoneError,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
      selectedCountryFlag: selectedCountryFlag ?? this.selectedCountryFlag,
      selectedCountryName: selectedCountryName ?? this.selectedCountryName,
      updatePhoneStatus: updatePhoneStatus ?? this.updatePhoneStatus,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      fullPhoneNumber: fullPhoneNumber ?? this.fullPhoneNumber,
    );
  }
}

class PhoneEditInitial extends PhoneEditState {}
