part of 'email_edit_cubit.dart';

class EmailEditState {
  final String email;
  final String emailError;
  final CubitStates status;
  final String successMessage;
  final String errorMessage;
  final String fullEmail;

  /// true بعد أول تعديل من المستخدم — الـ error ميظهرش قبلها
  final bool isDirty;

  EmailEditState({
    this.email = '',
    this.emailError = '',
    this.status = CubitStates.initial,
    this.successMessage = '',
    this.errorMessage = '',
    this.fullEmail = '',
    this.isDirty = false,
  });

  bool get isLoading => status == CubitStates.loading;
  bool get canProceed => email.isNotEmpty && emailError.isEmpty;

  /// الـ error المعروض للـ UI — فارغ لو المستخدم لم يبدأ الكتابة بعد
  String get visibleError => isDirty ? emailError : '';

  EmailEditState copyWith({
    String? email,
    String? emailError,
    CubitStates? status,
    String? successMessage,
    String? errorMessage,
    String? fullEmail,
    bool? isDirty,
  }) {
    return EmailEditState(
      email: email ?? this.email,
      emailError: emailError ?? this.emailError,
      status: status ?? this.status,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      fullEmail: fullEmail ?? this.fullEmail,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}

class EmailEditInitial extends EmailEditState {}
