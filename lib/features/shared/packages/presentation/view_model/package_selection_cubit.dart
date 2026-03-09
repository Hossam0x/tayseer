import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/shared/packages/domain/entities/package_type.dart';

class PackageSelectionState {
  final PackageType selectedPackage;

  const PackageSelectionState({required this.selectedPackage});

  PackageSelectionState copyWith({PackageType? selectedPackage}) {
    return PackageSelectionState(
      selectedPackage: selectedPackage ?? this.selectedPackage,
    );
  }
}

class PackageSelectionCubit extends Cubit<PackageSelectionState> {
  PackageSelectionCubit()
    : super(const PackageSelectionState(selectedPackage: PackageType.basic));

  void selectPackage(PackageType package) {
    if (state.selectedPackage != package) {
      emit(state.copyWith(selectedPackage: package));
    }
  }
}
