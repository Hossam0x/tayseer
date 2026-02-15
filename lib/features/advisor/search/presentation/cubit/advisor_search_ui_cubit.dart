import 'package:flutter_bloc/flutter_bloc.dart';

class AdvisorSearchUiState {
  final int selectedIndex;

  const AdvisorSearchUiState({this.selectedIndex = 0});
}

class AdvisorSearchUiCubit extends Cubit<AdvisorSearchUiState> {
  AdvisorSearchUiCubit(int initialIndex)
    : super(AdvisorSearchUiState(selectedIndex: initialIndex));

  void updateIndex(int index) {
    emit(AdvisorSearchUiState(selectedIndex: index));
  }
}
