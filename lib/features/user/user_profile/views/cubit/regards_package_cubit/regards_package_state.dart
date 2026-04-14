import 'package:equatable/equatable.dart';


enum RegardsPackagePurchaseStatus {
  initial,
  purchasing,
  success,
  canceled,
  error,
}

class RegardsPackagePurchaseState extends Equatable {
  final RegardsPackagePurchaseStatus status;
  final String? error;

  const RegardsPackagePurchaseState({
    this.status = RegardsPackagePurchaseStatus.initial,
    this.error,
  });

  RegardsPackagePurchaseState copyWith({
    RegardsPackagePurchaseStatus? status,
    String? error,
  }) {
    return RegardsPackagePurchaseState(
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, error];
}
