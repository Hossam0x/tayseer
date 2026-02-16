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

  // Pagination Properties
  final bool hasMore;
  final bool isLoadingMore;
  final int currentPage;
  final int totalPages;
  final String lastSearchType;

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
    this.hasMore = false,
    this.isLoadingMore = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.lastSearchType = 'all',
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
    bool? hasMore,
    bool? isLoadingMore,
    int? currentPage,
    int? totalPages,
    String? lastSearchType,
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
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      lastSearchType: lastSearchType ?? this.lastSearchType,
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
    hasMore,
    isLoadingMore,
    currentPage,
    totalPages,
    lastSearchType,
  ];
}
