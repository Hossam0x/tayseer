import 'package:equatable/equatable.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/my_import.dart';

class StoriesState extends Equatable {
  final String storiesMessage;
  final CubitStates storiesState;
  final List<UserStoriesModel> storiesList;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final String? advisorId;
  final bool isSpecial;
  final CubitStates createStoryState;
  final String createStoryMessage;
  final double uploadProgress;

  // ── My Stories (profile / home self-story section) ─────────────────────────
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
    myStories,
    myStoriesState,
    myStoriesMessage,
  ];
}

/// Internal sentinel so `copyWith(myStories: null)` works correctly.
const _sentinel = Object();
