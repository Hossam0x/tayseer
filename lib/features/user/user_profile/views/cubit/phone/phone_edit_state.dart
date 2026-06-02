part of 'phone_edit_cubit.dart';

class PhoneEditState {
  final String phoneNumber;
  final String phoneError;
  final CountryData selectedCountry;
  final CubitStates updatePhoneStatus;
  final String successMessage;
  final String errorMessage;
  final String fullPhoneNumber;

  /// 'sms' | 'whatsapp'
  final String otpMethod;

  /// true بعد أول تعديل من المستخدم — الـ error ميظهرش قبلها
  final bool isDirty;

  PhoneEditState({
    this.phoneNumber = '',
    this.phoneError = '',
    this.selectedCountry = kDefaultCountry,
    this.updatePhoneStatus = CubitStates.initial,
    this.successMessage = '',
    this.errorMessage = '',
    this.fullPhoneNumber = '',
    this.otpMethod = 'whatsapp',
    this.isDirty = false,
  });

  bool get isLoading => updatePhoneStatus == CubitStates.loading;
  bool get canProceed => phoneNumber.isNotEmpty && phoneError.isEmpty;

  /// الـ error المعروض للـ UI — فارغ لو المستخدم لم يبدأ الكتابة بعد
  String get visibleError => isDirty ? phoneError : '';

  PhoneEditState copyWith({
    String? phoneNumber,
    String? phoneError,
    CountryData? selectedCountry,
    CubitStates? updatePhoneStatus,
    String? successMessage,
    String? errorMessage,
    String? fullPhoneNumber,
    String? otpMethod,
    bool? isDirty,
  }) {
    return PhoneEditState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneError: phoneError ?? this.phoneError,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      updatePhoneStatus: updatePhoneStatus ?? this.updatePhoneStatus,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      fullPhoneNumber: fullPhoneNumber ?? this.fullPhoneNumber,
      otpMethod: otpMethod ?? this.otpMethod,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

class PhoneEditInitial extends PhoneEditState {}
