import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/settings/data/models/story_visibility_models.dart';

class StoryVisibilityState extends Equatable {
  final CubitStates state;
  final List<RestrictedUserModel> users;
  final String? errorMessage;
  final bool isLoading;
  final bool isUnrestricting;
  final String searchQuery;

  const StoryVisibilityState({
    this.state = CubitStates.initial,
    this.users = const [],
    this.errorMessage,
    this.isLoading = false,
    this.isUnrestricting = false,
    this.searchQuery = '',
  });

  factory StoryVisibilityState.initial() {
    return const StoryVisibilityState();
  }

  StoryVisibilityState copyWith({
    CubitStates? state,
    List<RestrictedUserModel>? users,
    String? errorMessage,
    bool? isLoading,
    bool? isUnrestricting,
    String? searchQuery,
  }) {
    return StoryVisibilityState(
      state: state ?? this.state,
      users: users ?? this.users,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isUnrestricting: isUnrestricting ?? this.isUnrestricting,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  // الحصول على المستخدمين المحددين
  List<RestrictedUserModel> get selectedUsers {
    return users.where((user) => user.isSelected).toList();
  }

  // الحصول على IDs المستخدمين المحددين
  List<String> get selectedUserIds {
    return selectedUsers.map((user) => user.userId).toList();
  }

  // التحقق من وجود تغييرات
  bool get hasSelections {
    return users.any((user) => user.isSelected);
  }

  @override
  List<Object?> get props => [
    state,
    users,
    errorMessage,
    isLoading,
    isUnrestricting,
    searchQuery,
  ];
}
