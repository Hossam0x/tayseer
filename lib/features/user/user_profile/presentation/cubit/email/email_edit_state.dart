part of 'email_edit_cubit.dart';

class EmailEditState {
  final String email;
  final String emailError;
  final CubitStates status;
  final String successMessage;
  final String errorMessage;
  final String fullEmail;

  EmailEditState({
    this.email = '',
    this.emailError = '',
    this.status = CubitStates.initial,
    this.successMessage = '',
    this.errorMessage = '',
    this.fullEmail = '',
  });

  bool get isLoading => status == CubitStates.loading;
  bool get canProceed => email.isNotEmpty && emailError.isEmpty;

  EmailEditState copyWith({
    String? email,
    String? emailError,
    CubitStates? status,
    String? successMessage,
    String? errorMessage,
    String? fullEmail,
  }) {
    return EmailEditState(
      email: email ?? this.email,
      emailError: emailError ?? this.emailError,
      status: status ?? this.status,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      fullEmail: fullEmail ?? this.fullEmail,
    );
  }
}

class EmailEditInitial extends EmailEditState {}
