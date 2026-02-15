import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/cubit/user_advisor_tabs_state.dart';

class UserAdvisorTabsCubit extends Cubit<UserAdvisorTabsState> {
  UserAdvisorTabsCubit() : super(const UserAdvisorTabsState());

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
