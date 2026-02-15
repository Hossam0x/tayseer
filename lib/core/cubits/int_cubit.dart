import 'package:flutter_bloc/flutter_bloc.dart';

class IntCubit extends Cubit<int> {
  IntCubit([super.initialValue = 0]);

  void setValue(int value) {
    emit(value);
  }
}
