import 'package:flutter_bloc/flutter_bloc.dart';

class ToggleCubit extends Cubit<bool> {
  ToggleCubit([super.initialValue = false]);

  void toggle() => emit(!state);
  void set(bool value) => emit(value);
}
