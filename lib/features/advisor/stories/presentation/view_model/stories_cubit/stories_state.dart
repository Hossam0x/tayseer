import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/my_import.dart';

class StoriesState extends Equatable {
  final String storiesMessage;
  final CubitStates storiesState;
  final List<UserStoriesModel> storiesList; // Home feed (isSpecial: false)
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? advisorId;
  final bool isSpecial;
  final CubitStates createStoryState;
  final String createStoryMessage;
  final double uploadProgress;

  // ── My Special Stories (Self Profile) ──────────────────────────────────────
  final List<UserStoriesModel> mySpecialStories;
  final CubitStates mySpecialStoriesState;
  final int mySpecialCurrentPage;
  final bool mySpecialHasMore;
  final bool mySpecialIsLoadingMore;

  // ── Advisor Special Stories (Remote Profiles) ──────────────────────────────
  final List<UserStoriesModel> advisorSpecialStories;
  final CubitStates advisorSpecialStoriesState;
  final int advisorSpecialCurrentPage;
  final bool advisorSpecialHasMore;
  final bool advisorSpecialIsLoadingMore;
  final String? activeAdvisorId; // The ID of the currently loaded remote advisor

  // ── My Stories (profile / home self-story ring section) ────────────────────
  /// The current advisor's own stories fetched from /stories/my-stories.
  /// null = not yet fetched.
  final UserStoriesModel? myStories;
  final CubitStates myStoriesState;
  final String myStoriesMessage;

  const StoriesState({
    this.storiesMessage = '',
    this.storiesState = CubitStates.initial,
    this.storiesList = const [],
    this.currentPage = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.advisorId,
    this.isSpecial = false,
    this.createStoryState = CubitStates.initial,
    this.createStoryMessage = '',
    this.uploadProgress = 0.0,
    this.mySpecialStories = const [],
    this.mySpecialStoriesState = CubitStates.initial,
    this.mySpecialCurrentPage = 1,
    this.mySpecialHasMore = true,
    this.mySpecialIsLoadingMore = false,
    this.advisorSpecialStories = const [],
    this.advisorSpecialStoriesState = CubitStates.initial,
    this.advisorSpecialCurrentPage = 1,
    this.advisorSpecialHasMore = true,
    this.advisorSpecialIsLoadingMore = false,
    this.activeAdvisorId,
    this.myStories,
    this.myStoriesState = CubitStates.initial,
    this.myStoriesMessage = '',
  });

  StoriesState copyWith({
    String? storiesMessage,
    CubitStates? storiesState,
    List<UserStoriesModel>? storiesList,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    String? advisorId,
    bool? isSpecial,
    CubitStates? createStoryState,
    String? createStoryMessage,
    double? uploadProgress,
    List<UserStoriesModel>? mySpecialStories,
    CubitStates? mySpecialStoriesState,
    int? mySpecialCurrentPage,
    bool? mySpecialHasMore,
    bool? mySpecialIsLoadingMore,
    List<UserStoriesModel>? advisorSpecialStories,
    CubitStates? advisorSpecialStoriesState,
    int? advisorSpecialCurrentPage,
    bool? advisorSpecialHasMore,
    bool? advisorSpecialIsLoadingMore,
    String? activeAdvisorId,
    // Use a sentinel to allow explicitly setting myStories to null
    Object? myStories = _sentinel,
    CubitStates? myStoriesState,
    String? myStoriesMessage,
  }) {
    return StoriesState(
      storiesMessage: storiesMessage ?? this.storiesMessage,
      storiesState: storiesState ?? this.storiesState,
      storiesList: storiesList ?? this.storiesList,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      advisorId: advisorId ?? this.advisorId,
      isSpecial: isSpecial ?? this.isSpecial,
      createStoryState: createStoryState ?? this.createStoryState,
      createStoryMessage: createStoryMessage ?? this.createStoryMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      mySpecialStories: mySpecialStories ?? this.mySpecialStories,
      mySpecialStoriesState: mySpecialStoriesState ?? this.mySpecialStoriesState,
      mySpecialCurrentPage: mySpecialCurrentPage ?? this.mySpecialCurrentPage,
      mySpecialHasMore: mySpecialHasMore ?? this.mySpecialHasMore,
      mySpecialIsLoadingMore: mySpecialIsLoadingMore ?? this.mySpecialIsLoadingMore,
      advisorSpecialStories: advisorSpecialStories ?? this.advisorSpecialStories,
      advisorSpecialStoriesState:
          advisorSpecialStoriesState ?? this.advisorSpecialStoriesState,
      advisorSpecialCurrentPage:
          advisorSpecialCurrentPage ?? this.advisorSpecialCurrentPage,
      advisorSpecialHasMore: advisorSpecialHasMore ?? this.advisorSpecialHasMore,
      advisorSpecialIsLoadingMore:
          advisorSpecialIsLoadingMore ?? this.advisorSpecialIsLoadingMore,
      activeAdvisorId: activeAdvisorId ?? this.activeAdvisorId,
      myStories: myStories == _sentinel
          ? this.myStories
          : myStories as UserStoriesModel?,
      myStoriesState: myStoriesState ?? this.myStoriesState,
      myStoriesMessage: myStoriesMessage ?? this.myStoriesMessage,
    );
  }

  @override
  List<Object?> get props => [
    storiesMessage,
    storiesState,
    storiesList,
    currentPage,
    hasMore,
    isLoadingMore,
    advisorId,
    isSpecial,
    createStoryState,
    createStoryMessage,
    uploadProgress,
    mySpecialStories,
    mySpecialStoriesState,
    mySpecialCurrentPage,
    mySpecialHasMore,
    mySpecialIsLoadingMore,
    advisorSpecialStories,
    advisorSpecialStoriesState,
    advisorSpecialCurrentPage,
    advisorSpecialHasMore,
    advisorSpecialIsLoadingMore,
    activeAdvisorId,
    myStories,
    myStoriesState,
    myStoriesMessage,
  ];
}

/// Internal sentinel so `copyWith(myStories: null)` works correctly.
const _sentinel = Object();
