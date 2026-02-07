// features/shared/search/presentation/cubit/search_state.dart
import 'package:equatable/equatable.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_advisor_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_event_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_group_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_user_model.dart';
import 'package:tayseer/my_import.dart';

// features/shared/search/presentation/cubit/search_state.dart
class SearchState extends Equatable {
  final String query;
  final CubitStates searchStatus;
  final String? errorMessage;

  // New properties for actions
  final CubitStates actionStatus;
  final String? actionMessage;

  final List<SearchAdvisor> advisors;
  final List<PostModel> posts;
  final List<SearchUser> users;
  final List<SearchEvent> events;
  final List<SearchGroup> groups;

  const SearchState({
    this.query = '',
    this.searchStatus = CubitStates.initial,
    this.errorMessage,
    this.actionStatus = CubitStates.initial,
    this.actionMessage,
    this.advisors = const [],
    this.posts = const [],
    this.users = const [],
    this.events = const [],
    this.groups = const [],
  });

  bool get isEmpty =>
      advisors.isEmpty &&
      posts.isEmpty &&
      events.isEmpty &&
      groups.isEmpty &&
      users.isEmpty;

  bool get isLoading => searchStatus == CubitStates.loading;
  bool get isSuccess => searchStatus == CubitStates.success;
  bool get isError => searchStatus == CubitStates.failure;

  SearchState copyWith({
    String? query,
    CubitStates? searchStatus,
    String? errorMessage,
    CubitStates? actionStatus,
    String? actionMessage,
    List<SearchAdvisor>? advisors,
    List<PostModel>? posts,
    List<SearchUser>? users,
    List<SearchEvent>? events,
    List<SearchGroup>? groups,
  }) {
    return SearchState(
      query: query ?? this.query,
      searchStatus: searchStatus ?? this.searchStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
      advisors: advisors ?? this.advisors,
      posts: posts ?? this.posts,
      users: users ?? this.users,
      events: events ?? this.events,
      groups: groups ?? this.groups,
    );
  }

  @override
  List<Object?> get props => [
    query,
    searchStatus,
    errorMessage,
    actionStatus,
    actionMessage,
    advisors,
    posts,
    users,
    events,
    groups,
  ];
}
