import 'package:flutter_bloc/flutter_bloc.dart';

class LocationSelectionCubit extends Cubit<String?> {
  LocationSelectionCubit(super.initialLocation);

  void selectLocation(String location) {
    emit(location);
  }
}
