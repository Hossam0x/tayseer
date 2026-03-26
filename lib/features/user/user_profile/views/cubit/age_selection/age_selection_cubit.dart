import 'package:flutter_bloc/flutter_bloc.dart';

class AgeSelectionCubit extends Cubit<int> {
  AgeSelectionCubit(super.initialAge);

  void selectAge(int age) {
    emit(age);
  }
}
