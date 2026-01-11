import 'package:flutter_bloc/flutter_bloc.dart';

// State
class BoostAccountState {
  final int selectedPackageIndex;
  BoostAccountState({this.selectedPackageIndex = 0});
}

// Cubit
class BoostAccountCubit extends Cubit<BoostAccountState> {
  BoostAccountCubit() : super(BoostAccountState());

  void selectPackage(int index) {
    emit(BoostAccountState(selectedPackageIndex: index));
  }
}
