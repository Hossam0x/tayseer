import 'package:flutter_bloc/flutter_bloc.dart';

class YearPickerCubit extends Cubit<int> {
  YearPickerCubit(super.initialYear);

  void selectYear(int year) {
    emit(year);
  }
}
