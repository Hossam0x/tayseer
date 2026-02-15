import 'package:equatable/equatable.dart';

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
