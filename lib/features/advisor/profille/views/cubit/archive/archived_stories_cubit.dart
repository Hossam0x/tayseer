import 'package:tayseer/features/advisor/profille/data/repositories/archive_repository.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archived_stories_state.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
import 'package:tayseer/my_import.dart';

class ArchivedStoriesCubit extends Cubit<ArchivedStoriesState> {
  final ArchiveRepository _archiveRepository;
  final StoriesRepository _storiesRepository;
  final int _pageSize = 10;

  ArchivedStoriesCubit(this._archiveRepository, this._storiesRepository)
    : super(const ArchivedStoriesState()) {
    fetchArchivedStories();
  }

  Future<void> fetchArchivedStories({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;

      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await _archiveRepository.getArchivedStories(
        page: nextPage,
        limit: _pageSize,
      );

      result.fold(
        (failure) => emit(
          state.copyWith(isLoadingMore: false, errorMessage: failure.message),
        ),
        (stories) => emit(
          state.copyWith(
            stories: [...state.stories, ...stories],
            currentPage: nextPage,
            hasMore: stories.length == _pageSize,
            isLoadingMore: false,
            state: CubitStates.success,
            errorMessage: null,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          state: CubitStates.loading,
          stories: [],
          currentPage: 1,
          hasMore: true,
          errorMessage: null,
        ),
      );

      final result = await _archiveRepository.getArchivedStories(
        page: 1,
        limit: _pageSize,
      );

      if (isClosed) return;

      result.fold(
        (failure) => emit(
          state.copyWith(
            state: CubitStates.failure,
            errorMessage: failure.message,
          ),
        ),
        (stories) => emit(
          state.copyWith(
            state: CubitStates.success,
            stories: stories,
            currentPage: 1,
            hasMore: stories.length == _pageSize,
            errorMessage: null,
          ),
        ),
      );
    }
  }

  void likeStory({required String storyId, required String userId}) {
    final userStoryIndex = state.stories.indexWhere(
      (us) => us.userId == userId,
    );
    if (userStoryIndex == -1) return;

    final userStory = state.stories[userStoryIndex];
    final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);
    if (storyIndex == -1) return;

    final story = userStory.stories[storyIndex];
    final updatedStories = List<StoryModel>.from(userStory.stories);
    updatedStories[storyIndex] = story.copyWith(
      isLiked: !story.isLiked,
      likesCount: story.isLiked ? story.likesCount - 1 : story.likesCount + 1,
    );

    final updatedList = List<UserStoriesModel>.from(state.stories);
    updatedList[userStoryIndex] = userStory.copyWith(stories: updatedStories);

    emit(state.copyWith(stories: updatedList));
    _storiesRepository.likeStory(storyId: storyId);
  }

  Future<void> deleteStory({
    required String storyId,
    required String userId,
  }) async {
    emit(state.copyWith(deleteActionState: CubitStates.loading));
    final result = await _storiesRepository.deleteStory(storyId: storyId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          deleteActionState: CubitStates.failure,
          deleteMessage: failure.message,
        ),
      ),
      (_) {
        final userStoryIndex = state.stories.indexWhere(
          (us) => us.userId == userId,
        );
        if (userStoryIndex == -1) return;

        final userStory = state.stories[userStoryIndex];
        final updatedStories = userStory.stories
            .where((s) => s.id != storyId)
            .toList();

        final updatedList = List<UserStoriesModel>.from(state.stories);
        if (updatedStories.isEmpty) {
          updatedList.removeAt(userStoryIndex);
        } else {
          updatedList[userStoryIndex] = userStory.copyWith(
            stories: updatedStories,
            storiesCount: updatedStories.length,
          );
        }

        emit(
          state.copyWith(
            stories: updatedList,
            deleteActionState: CubitStates.success,
            deleteMessage: 'story_deleted_success',
          ),
        );
      },
    );
  }

  Future<void> unarchiveStory({
    required String storyId,
    required String userId,
  }) async {
    emit(state.copyWith(unarchiveActionState: CubitStates.loading));
    final result = await _storiesRepository.toggleArchiveStory(
      storyId: storyId,
      isArchive: false,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          unarchiveActionState: CubitStates.failure,
          unarchiveMessage: failure.message,
        ),
      ),
      (_) {
        final userStoryIndex = state.stories.indexWhere(
          (us) => us.userId == userId,
        );
        if (userStoryIndex == -1) return;

        final userStory = state.stories[userStoryIndex];
        final updatedStories = userStory.stories
            .where((s) => s.id != storyId)
            .toList();

        final updatedList = List<UserStoriesModel>.from(state.stories);
        if (updatedStories.isEmpty) {
          updatedList.removeAt(userStoryIndex);
        } else {
          updatedList[userStoryIndex] = userStory.copyWith(
            stories: updatedStories,
            storiesCount: updatedStories.length,
          );
        }

        emit(
          state.copyWith(
            stories: updatedList,
            unarchiveActionState: CubitStates.success,
            unarchiveMessage: 'story_unarchived_success',
          ),
        );
      },
    );
  }

  void resetDeleteStoryState() => emit(
    state.copyWith(deleteActionState: CubitStates.initial, deleteMessage: null),
  );

  void resetUnarchiveStoryState() => emit(
    state.copyWith(
      unarchiveActionState: CubitStates.initial,
      unarchiveMessage: null,
    ),
  );

  Future<void> refresh() => fetchArchivedStories();

  void clearError() => emit(state.copyWith(errorMessage: null));
}
