import 'package:dartz/dartz.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/my_import.dart';

class StoriesCubit extends Cubit<StoriesState> {
  final StoriesRepository storiesRepository;
  final int pageSize = 10;

  StoriesCubit(this.storiesRepository) : super(const StoriesState());

  Future<void> fetchStories({
    bool loadMore = false,
    String? advisorId,
    bool? isSpecial,
    bool isSilent = false,
    required BuildContext context,
  }) async {
    final effectiveAdvisorId = advisorId ?? state.advisorId;
    final effectiveIsSpecial = isSpecial ?? state.isSpecial;

    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await storiesRepository.fetchStories(
        page: nextPage,
        advisorId: effectiveAdvisorId,
        isSpecial: effectiveIsSpecial,
        context: context,
      );

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              isLoadingMore: false,
              storiesMessage: failure.message,
            ),
          );
        },
        (newStories) {
          final updatedList = [...state.storiesList, ...newStories];
          emit(
            state.copyWith(
              storiesList: updatedList,
              currentPage: nextPage,
              hasMore: newStories.length >= pageSize,
              isLoadingMore: false,
              advisorId: effectiveAdvisorId,
              isSpecial: effectiveIsSpecial,
            ),
          );
        },
      );
    } else {
      if (!isSilent) {
        emit(
          state.copyWith(
            storiesState: CubitStates.loading,
            currentPage: 1,
            hasMore: true,
            advisorId: advisorId,
            isSpecial: isSpecial,
          ),
        );
      }
      final result = await storiesRepository.fetchStories(
        page: 1,
        advisorId: effectiveAdvisorId,
        isSpecial: effectiveIsSpecial,
        context: context,
      );
      result.fold(
        (failure) {
          emit(
            state.copyWith(
              storiesState: CubitStates.failure,
              storiesMessage: failure.message,
            ),
          );
        },
        (storiesList) {
          emit(
            state.copyWith(
              storiesState: CubitStates.success,
              storiesList: storiesList,
              currentPage: 1,
              hasMore: storiesList.length >= pageSize,
              advisorId: effectiveAdvisorId,
              isSpecial: effectiveIsSpecial,
            ),
          );
        },
      );
    }
  }

  /// Silent fetch that doesn't require a [BuildContext].
  /// Used after adding a story when the original context is already popped.
  Future<void> fetchStoriesSilent() async {
    final effectiveAdvisorId = state.advisorId;
    final effectiveIsSpecial = state.isSpecial;

    final result = await storiesRepository.fetchStoriesSilent(
      page: 1,
      advisorId: effectiveAdvisorId,
      isSpecial: effectiveIsSpecial,
    );

    result.fold(
      (failure) {
        debugPrint('Silent story fetch failed: ${failure.message}');
      },
      (storiesList) {
        emit(
          state.copyWith(
            storiesState: CubitStates.success,
            storiesList: storiesList,
            currentPage: 1,
            hasMore: storiesList.length >= pageSize,
            advisorId: effectiveAdvisorId,
            isSpecial: effectiveIsSpecial,
          ),
        );
      },
    );
  }

  void markStoryAsViewed({required String storyId, required String userId}) {
    final currentList = state.storiesList;
    final userStoryIndex = currentList.indexWhere(
      (userStory) => userStory.userId == userId,
    );

    if (userStoryIndex == -1) return;

    final userStory = currentList[userStoryIndex];
    final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);

    if (storyIndex == -1) return;

    final story = userStory.stories[storyIndex];
    if (story.viewsCount > 0) return;

    bool isLastStory = storyIndex == userStory.stories.length - 1;
    final List<StoryModel> updatedStories = List.from(userStory.stories);
    updatedStories[storyIndex] = story.copyWith(viewsCount: 1);

    final bool allViewedLocally =
        isLastStory || updatedStories.every((s) => s.viewsCount > 0);

    final updatedUserStory = userStory.copyWith(
      stories: updatedStories,
      allViewed: allViewedLocally,
      isViewedByMe: true,
    );

    final List<UserStoriesModel> updatedList = List.from(currentList);
    updatedList[userStoryIndex] = updatedUserStory;

    emit(state.copyWith(storiesList: updatedList));
    storiesRepository.markStoryAsViewed(storyId: storyId);
  }

  void likeStory({required String storyId, required String userId}) {
    final userStoryIndex = state.storiesList.indexWhere(
      (userStory) => userStory.userId == userId,
    );
    if (userStoryIndex == -1) return;

    final userStory = state.storiesList[userStoryIndex];
    final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);
    if (storyIndex == -1) return;

    final story = userStory.stories[storyIndex];
    final updatedStories = List<StoryModel>.from(userStory.stories);
    updatedStories[storyIndex] = story.copyWith(
      isLiked: !story.isLiked,
      likesCount: story.isLiked ? story.likesCount - 1 : story.likesCount + 1,
    );

    final updatedUserStory = userStory.copyWith(stories: updatedStories);
    final List<UserStoriesModel> updatedList = List.from(state.storiesList);
    updatedList[userStoryIndex] = updatedUserStory;

    emit(state.copyWith(storiesList: updatedList));
    storiesRepository.likeStory(storyId: storyId);
  }

  Future<void> deleteStory({
    required BuildContext context,
    required String storyId,
    required String userId,
  }) async {
    final result = await storiesRepository.deleteStory(storyId: storyId);

    result.fold(
      (failure) {
        emit(state.copyWith(storiesMessage: failure.message));
        if (context.mounted) {
          AppToast.error(context, failure.message);
        }
      },
      (_) {
        final userStoryIndex = state.storiesList.indexWhere(
          (us) => us.userId == userId,
        );
        if (userStoryIndex == -1) return;

        final userStory = state.storiesList[userStoryIndex];
        final updatedStories = userStory.stories
            .where((s) => s.id != storyId)
            .toList();

        final updatedList = List<UserStoriesModel>.from(state.storiesList);
        if (updatedStories.isEmpty) {
          updatedList.removeAt(userStoryIndex);
        } else {
          updatedList[userStoryIndex] = userStory.copyWith(
            stories: updatedStories,
            storiesCount: updatedStories.length,
          );
        }

        emit(state.copyWith(storiesList: updatedList));
        if (context.mounted) {
          AppToast.success(context, context.tr('story_deleted_success'));
        }
      },
    );
  }

  Future<void> toggleArchiveStory({
    required BuildContext context,
    required String storyId,
    required String userId,
    required bool isArchive,
  }) async {
    final result = await storiesRepository.toggleArchiveStory(
      storyId: storyId,
      isArchive: isArchive,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(storiesMessage: failure.message));
        if (context.mounted) {
          AppToast.error(context, failure.message);
        }
      },
      (_) {
        if (isArchive) {
          final userStoryIndex = state.storiesList.indexWhere(
            (us) => us.userId == userId,
          );
          if (userStoryIndex == -1) return;

          final userStory = state.storiesList[userStoryIndex];
          final updatedStories = userStory.stories
              .where((s) => s.id != storyId)
              .toList();

          final updatedList = List<UserStoriesModel>.from(state.storiesList);
          if (updatedStories.isEmpty) {
            updatedList.removeAt(userStoryIndex);
          } else {
            updatedList[userStoryIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          }
          emit(state.copyWith(storiesList: updatedList));
          if (context.mounted) {
            AppToast.success(context, context.tr('story_archived_success'));
          }
        }
      },
    );
  }

  Future<Either<Failure, void>> hideStory({
    required BuildContext context,
    required String storyId,
    required String userId,
  }) async {
    final result = await storiesRepository.hideStory(storyId: storyId);

    return result.fold(
      (failure) {
        emit(state.copyWith(storiesMessage: failure.message));
        if (context.mounted) {
          AppToast.error(context, failure.message);
        }
        return Left(failure);
      },
      (_) {
        final userStoryIndex = state.storiesList.indexWhere(
          (us) => us.userId == userId,
        );
        if (userStoryIndex != -1) {
          final userStory = state.storiesList[userStoryIndex];
          final updatedStories = userStory.stories
              .where((s) => s.id != storyId)
              .toList();

          final updatedList = List<UserStoriesModel>.from(state.storiesList);
          if (updatedStories.isEmpty) {
            updatedList.removeAt(userStoryIndex);
          } else {
            updatedList[userStoryIndex] = userStory.copyWith(
              stories: updatedStories,
              storiesCount: updatedStories.length,
            );
          }
          emit(state.copyWith(storiesList: updatedList));
        }
        if (context.mounted) {
          AppToast.success(context, context.tr('story_hidden_success'));
        }
        return const Right(null);
      },
    );
  }

  Future<void> makeStorySpecial({
    required BuildContext context,
    required String storyId,
    required String userId,
  }) async {
    final result = await storiesRepository.makeStorySpecial(storyId: storyId);

    result.fold(
      (failure) {
        emit(state.copyWith(storiesMessage: failure.message));
        if (context.mounted) {
          AppToast.error(context, failure.message);
        }
      },
      (_) {
        final userStoryIndex = state.storiesList.indexWhere(
          (us) => us.userId == userId,
        );
        if (userStoryIndex == -1) return;

        final userStory = state.storiesList[userStoryIndex];
        final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);
        if (storyIndex == -1) return;

        final updatedStories = List<StoryModel>.from(userStory.stories);
        updatedStories[storyIndex] = updatedStories[storyIndex].copyWith(
          isSpecial: true,
        );

        final List<UserStoriesModel> updatedList = List.from(state.storiesList);
        updatedList[userStoryIndex] = userStory.copyWith(
          stories: updatedStories,
        );

        emit(state.copyWith(storiesList: updatedList));
        if (context.mounted) {
          AppToast.success(context, context.tr('story_special_success'));
        }
      },
    );
  }

  Future<void> createStory({
    String? content,
    List<File>? images,
    List<XFile>? videos,
    double? videoDuration,
    BuildContext? context,
  }) async {
    emit(
      state.copyWith(
        createStoryState: CubitStates.loading,
        uploadProgress: 0.0,
      ),
    );
    final result = await storiesRepository.createStories(
      content: content,
      images: images,
      videos: videos,
      videoDuration: videoDuration,
      onSendProgress: (sent, total) {
        if (total > 0) {
          final progress = sent / total;
          if ((progress - state.uploadProgress).abs() > 0.01 ||
              progress == 1.0) {
            emit(
              state.copyWith(
                uploadProgress: progress,
                createStoryState: CubitStates.loading,
              ),
            );
          }
        }
      },
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            createStoryState: CubitStates.failure,
            createStoryMessage: failure.message,
          ),
        );
      },
      (_) {
        emit(state.copyWith(createStoryState: CubitStates.success));

        // Refetch stories after a delay to allow backend processing
        Future.delayed(const Duration(milliseconds: 1500), () {
          fetchStoriesSilent();
        });

        if (context != null && context.mounted) {
          AppToast.success(context, context.tr('story_created_success'));
        }
      },
    );
  }
}
