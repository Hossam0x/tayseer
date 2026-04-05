import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/wallet/data/models/balance_package_model.dart';

enum RechargeStatus {
  initial,
  loading,
  loaded,
  purchasing,
  success,
  canceled,
  error,
}

class RechargeState extends Equatable {
  final RechargeStatus status;
  final List<BalancePackageModel> packages;
  final String? error;
  final int? selectedIndex;

  const RechargeState({
    this.status = RechargeStatus.initial,
    this.packages = const [],
    this.error,
    this.selectedIndex,
  });

  RechargeState copyWith({
    RechargeStatus? status,
    List<BalancePackageModel>? packages,
    String? error,
    int? selectedIndex,
    bool clearSelected = false,
  }) {
    return RechargeState(
      status: status ?? this.status,
      packages: packages ?? this.packages,
      error: error ?? this.error,
      selectedIndex: clearSelected
          ? null
          : (selectedIndex ?? this.selectedIndex),
    );
  }

  @override
  List<Object?> get props => [status, packages, error, selectedIndex];
}
