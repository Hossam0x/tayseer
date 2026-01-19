import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';

enum AccountOperation { none, suspend, delete }

class AccountManagementState extends Equatable {
  final CubitStates state;
  final String? errorMessage;
  final String? successMessage;
  final AccountOperation operation;

  const AccountManagementState({
    this.state = CubitStates.initial,
    this.errorMessage,
    this.successMessage,
    this.operation = AccountOperation.none,
  });

  AccountManagementState copyWith({
    CubitStates? state,
    String? errorMessage,
    String? successMessage,
    AccountOperation? operation,
  }) {
    return AccountManagementState(
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      operation: operation ?? this.operation,
    );
  }

  @override
  List<Object?> get props => [state, errorMessage, successMessage, operation];
}
