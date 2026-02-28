import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';

class OrderManagementState extends Equatable {
  final CubitStates status;
  final bool? isAvailable;
  final String? errorMessage;
  final String? successMessage;

  const OrderManagementState({
    this.status = CubitStates.initial,
    this.isAvailable,
    this.errorMessage,
    this.successMessage,
  });

  OrderManagementState copyWith({
    CubitStates? status,
    bool? isAvailable,
    String? errorMessage,
    String? successMessage,
  }) {
    return OrderManagementState(
      status: status ?? this.status,
      isAvailable: isAvailable ?? this.isAvailable,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isAvailable,
    errorMessage,
    successMessage,
  ];
}
