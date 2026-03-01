import 'package:flutter_bloc/flutter_bloc.dart';

enum SelectedPackage { basic, pro, elite }

class PackagesState {
  final SelectedPackage selectedPackage;
  final bool isLoading;
  final String? errorMessage;

  PackagesState({
    required this.selectedPackage,
    this.isLoading = false,
    this.errorMessage,
  });

  PackagesState copyWith({
    SelectedPackage? selectedPackage,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PackagesState(
      selectedPackage: selectedPackage ?? this.selectedPackage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PackagesCubit extends Cubit<PackagesState> {
  PackagesCubit()
    : super(PackagesState(selectedPackage: SelectedPackage.basic));

  void selectPackage(SelectedPackage package) {
    emit(state.copyWith(selectedPackage: package));
  }
}
