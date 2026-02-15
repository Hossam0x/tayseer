import 'package:equatable/equatable.dart';

class UserAdvisorTabsState extends Equatable {
  final int selectedIndex;
  final int refreshTimestamp;

  const UserAdvisorTabsState({
    this.selectedIndex = 0,
    this.refreshTimestamp = 0,
  });

  UserAdvisorTabsState copyWith({int? selectedIndex, int? refreshTimestamp}) {
    return UserAdvisorTabsState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      refreshTimestamp: refreshTimestamp ?? this.refreshTimestamp,
    );
  }

  @override
  List<Object> get props => [selectedIndex, refreshTimestamp];
}
