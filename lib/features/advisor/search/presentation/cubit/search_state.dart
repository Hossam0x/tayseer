// features/shared/search/presentation/cubit/search_state.dart
import 'package:equatable/equatable.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_advisor_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_event_model.dart';
import 'package:tayseer/features/advisor/search/data/models/search_group_model.dart';
import 'package:tayseer/my_import.dart';

class SearchState extends Equatable {
  final String query;
  final CubitStates searchStatus;
  final String? errorMessage;

  final List<SearchAdvisor> advisors;
  final List<PostModel> posts;
  final List<SearchEvent> events;
  final List<SearchGroup> groups;

  const SearchState({
    this.query = '',
    this.searchStatus = CubitStates.initial,
    this.errorMessage,
    this.advisors = const [],
    this.posts = const [],
    this.events = const [],
    this.groups = const [],
  });

  bool get isEmpty =>
      advisors.isEmpty && posts.isEmpty && events.isEmpty && groups.isEmpty;

  bool get isLoading => searchStatus == CubitStates.loading;
  bool get isSuccess => searchStatus == CubitStates.success;
  bool get isError => searchStatus == CubitStates.failure;

  SearchState copyWith({
    String? query,
    CubitStates? searchStatus,
    String? errorMessage,
    List<SearchAdvisor>? advisors,
    List<PostModel>? posts,
    List<SearchEvent>? events,
    List<SearchGroup>? groups,
  }) {
    return SearchState(
      query: query ?? this.query,
      searchStatus: searchStatus ?? this.searchStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      advisors: advisors ?? this.advisors,
      posts: posts ?? this.posts,
      events: events ?? this.events,
      groups: groups ?? this.groups,
    );
  }

  @override
  List<Object?> get props => [
    query,
    searchStatus,
    errorMessage,
    advisors,
    posts,
    events,
    groups,
  ];
}
