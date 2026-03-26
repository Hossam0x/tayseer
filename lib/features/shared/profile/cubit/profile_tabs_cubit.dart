import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileTabsState extends Equatable {
  final int selectedIndex;
  final int refreshTimestamp;

  const ProfileTabsState({this.selectedIndex = 0, this.refreshTimestamp = 0});

  ProfileTabsState copyWith({int? selectedIndex, int? refreshTimestamp}) {
    return ProfileTabsState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      refreshTimestamp: refreshTimestamp ?? this.refreshTimestamp,
    );
  }

  @override
  List<Object> get props => [selectedIndex, refreshTimestamp];
}

class ProfileTabsCubit extends Cubit<ProfileTabsState> {
  ProfileTabsCubit() : super(const ProfileTabsState());

  void changeTab(int index) {
    if (state.selectedIndex == index) {
      emit(
        state.copyWith(refreshTimestamp: DateTime.now().millisecondsSinceEpoch),
      );
    } else {
      emit(state.copyWith(selectedIndex: index));
    }
  }

  void updateIndex(int index) {
    if (state.selectedIndex != index) {
      emit(state.copyWith(selectedIndex: index));
    }
  }
}
