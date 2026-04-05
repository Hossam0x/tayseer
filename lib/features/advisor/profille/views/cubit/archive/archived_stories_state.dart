import 'package:equatable/equatable.dart';
import 'package:tayseer/core/enum/cubit_states.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';

class ArchivedStoriesState extends Equatable {
  final CubitStates state;
  final List<UserStoriesModel> stories;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final CubitStates unarchiveActionState;
  final String? unarchiveMessage;
  final CubitStates deleteActionState;
  final String? deleteMessage;

  const ArchivedStoriesState({
    this.state = CubitStates.initial,
    this.stories = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.unarchiveActionState = CubitStates.initial,
    this.unarchiveMessage,
    this.deleteActionState = CubitStates.initial,
    this.deleteMessage,
  });

  ArchivedStoriesState copyWith({
    CubitStates? state,
    List<UserStoriesModel>? stories,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    CubitStates? unarchiveActionState,
    String? unarchiveMessage,
    CubitStates? deleteActionState,
    String? deleteMessage,
  }) {
    return ArchivedStoriesState(
      state: state ?? this.state,
      stories: stories ?? this.stories,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      unarchiveActionState: unarchiveActionState ?? this.unarchiveActionState,
      unarchiveMessage: unarchiveMessage ?? this.unarchiveMessage,
      deleteActionState: deleteActionState ?? this.deleteActionState,
      deleteMessage: deleteMessage ?? this.deleteMessage,
    );
  }

  @override
  List<Object?> get props => [
    state,
    stories,
    errorMessage,
    currentPage,
    hasMore,
    isLoadingMore,
    isRefreshing,
    unarchiveActionState,
    unarchiveMessage,
    deleteActionState,
    deleteMessage,
  ];
}
