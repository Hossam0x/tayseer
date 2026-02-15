import 'package:flutter_bloc/flutter_bloc.dart';

class FollowCubit extends Cubit<bool> {
  FollowCubit(super.initialFollowing);

  void toggle() {
    emit(!state);
  }
}
