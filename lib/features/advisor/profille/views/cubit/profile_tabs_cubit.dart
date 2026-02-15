import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_tabs_state.dart';

class ProfileTabsCubit extends Cubit<ProfileTabsState> {
  ProfileTabsCubit() : super(const ProfileTabsState());

  void changeTab(int index) {
    if (state.selectedIndex == index) {
      // If tapping the same tab, trigger a refresh
      emit(
        state.copyWith(refreshTimestamp: DateTime.now().millisecondsSinceEpoch),
      );
    } else {
      // If switching tabs, update the index
      emit(state.copyWith(selectedIndex: index));
    }
  }

  // Called when tab changes via swipe (without tap)
  void updateIndex(int index) {
    if (state.selectedIndex != index) {
      emit(state.copyWith(selectedIndex: index));
    }
  }
}
