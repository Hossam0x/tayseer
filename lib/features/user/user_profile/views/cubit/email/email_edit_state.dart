// email_edit_state.dart
part of 'email_edit_cubit.dart';

class EmailEditState {
  final CubitStates status;
  final String email;
  final String emailError;
  final String errorMessage;
  final String successMessage;
  final String fullEmail;

  const EmailEditState({
    this.status = CubitStates.initial,
    this.email = '',
    this.emailError = '',
    this.errorMessage = '',
    this.successMessage = '',
    this.fullEmail = '',
  });

  bool get canProceed => email.isNotEmpty && emailError.isEmpty;
  bool get isLoading => status == CubitStates.loading;

  EmailEditState copyWith({
    CubitStates? status,
    String? email,
    String? emailError,
    String? errorMessage,
    String? successMessage,
    String? fullEmail,
  }) {
    return EmailEditState(
      status: status ?? this.status,
      email: email ?? this.email,
      emailError: emailError ?? this.emailError,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      fullEmail: fullEmail ?? this.fullEmail,
    );
  }
}

class EmailEditInitial extends EmailEditState {}
