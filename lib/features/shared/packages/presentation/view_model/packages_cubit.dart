import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../advisor/settings/data/models/package_model.dart';
import '../../../../advisor/settings/data/repositories/advisor_packages_repository.dart';

enum SelectedPackage { basic, pro, elite }

class PackagesState {
  final SelectedPackage selectedPackage;
  final List<AdvisorPackageModel> packages;
  final bool isLoading;
  final String? errorMessage;

  PackagesState({
    required this.selectedPackage,
    this.packages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  PackagesState copyWith({
    SelectedPackage? selectedPackage,
    List<AdvisorPackageModel>? packages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PackagesState(
      selectedPackage: selectedPackage ?? this.selectedPackage,
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PackagesCubit extends Cubit<PackagesState> {
  final AdvisorPackagesRepository _repository;

  PackagesCubit(this._repository)
    : super(PackagesState(selectedPackage: SelectedPackage.basic));

  Future<void> getPackages() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    final result = await _repository.getPackages();
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (packages) => emit(state.copyWith(isLoading: false, packages: packages)),
    );
  }

  void selectPackage(SelectedPackage package) {
    emit(state.copyWith(selectedPackage: package));
  }
}
