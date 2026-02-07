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
  }) async {
    // 1. Identify effective parameters
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
      emit(
        state.copyWith(
          storiesState: CubitStates.loading,
          currentPage: 1,
          hasMore: true,
          advisorId: advisorId, // Overwrite if provided
          isSpecial: isSpecial, // Overwrite if provided
        ),
      );
      final result = await storiesRepository.fetchStories(
        page: 1,
        advisorId: effectiveAdvisorId,
        isSpecial: effectiveIsSpecial,
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

  void markStoryAsViewed({required String storyId, required String userId}) {
    debugPrint(
      "StoriesCubit: Attempting to mark story $storyId for user $userId as viewed",
    );

    final currentList = state.storiesList;
    final userStoryIndex = currentList.indexWhere(
      (userStory) => userStory.userId == userId,
    );

    if (userStoryIndex == -1) {
      debugPrint(
        "StoriesCubit: User $userId not found in storiesList. Available IDs: ${currentList.map((e) => e.userId).toList()}",
      );
      return;
    }

    final userStory = currentList[userStoryIndex];
    final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);

    if (storyIndex == -1) {
      debugPrint(
        "StoriesCubit: Story $storyId not found for user $userId. Available story IDs: ${userStory.stories.map((e) => e.id).toList()}",
      );
      return;
    }

    final story = userStory.stories[storyIndex];

    // Check if this is the last story
    bool isLastStory = storyIndex == userStory.stories.length - 1;

    // Build updated stories
    final List<StoryModel> updatedStories = List.from(userStory.stories);
    updatedStories[storyIndex] = story.copyWith(
      viewsCount: (story.viewsCount + 1),
    );

    // Determine allViewed
    final bool allViewedLocally =
        isLastStory || updatedStories.every((s) => s.viewsCount > 0);

    debugPrint(
      "StoriesCubit: Mark Successful. isLastStory: $isLastStory, allViewed will be: $allViewedLocally",
    );

    final updatedUserStory = userStory.copyWith(
      stories: updatedStories,
      allViewed: allViewedLocally,
      isViewedByMe: true,
    );

    final List<UserStoriesModel> updatedList = List.from(currentList);
    updatedList[userStoryIndex] = updatedUserStory;

    emit(state.copyWith(storiesList: updatedList));

    // call API
    storiesRepository.markStoryAsViewed(storyId: storyId);
  }

  void likeStory({required String storyId, required String userId}) {
    // إيجاد index بدلاً من map على القائمة كلها
    final userStoryIndex = state.storiesList.indexWhere(
      (userStory) => userStory.userId == userId,
    );

    if (userStoryIndex == -1) return;

    final userStory = state.storiesList[userStoryIndex];
    final storyIndex = userStory.stories.indexWhere((s) => s.id == storyId);

    if (storyIndex == -1) return;

    final story = userStory.stories[storyIndex];

    // تحديث القصة المحددة فقط
    final updatedStories = List<StoryModel>.from(userStory.stories);
    updatedStories[storyIndex] = story.copyWith(
      isLiked: !story.isLiked,
      likesCount: story.isLiked ? story.likesCount - 1 : story.likesCount + 1,
    );

    // تحديث userStory فقط
    final updatedUserStory = userStory.copyWith(stories: updatedStories);

    // تحديث القائمة الرئيسية - فقط العنصر المتغير
    final updatedList = List<UserStoriesModel>.from(state.storiesList);
    updatedList[userStoryIndex] = updatedUserStory;

    emit(state.copyWith(storiesList: updatedList));

    // إرسال الطلب للـ backend
    storiesRepository.likeStory(storyId: storyId);
  }

  Future<void> deleteStory({
    required String storyId,
    required String userId,
  }) async {
    final result = await storiesRepository.deleteStory(storyId: storyId);

    result.fold(
      (failure) {
        emit(state.copyWith(storiesMessage: failure.message));
      },
      (_) {
        // إزالة القصة محلياً
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
      },
    );
  }

  Future<void> toggleArchiveStory({
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
      },
      (_) {
        // في الـ Home/Profile غالباً بنشيلها لو اتعملها أرشفة (أو بنحدث حالتها)
        // بس العميل طلب إننا نشيلها لو هي في الـ Archive (unarchive)
        // هنا المنطق العام للهوم والبروفايل
        if (isArchive) {
          // لو اتعملها أرشفة من الهوم، ممكن نشيلها من القائمة المعروضة حالياً
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
        }
      },
    );
  }

  Future<void> makeStorySpecial({
    required String storyId,
    required String userId,
  }) async {
    final result = await storiesRepository.makeStorySpecial(storyId: storyId);

    result.fold(
      (failure) {
        emit(state.copyWith(storiesMessage: failure.message));
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

        final updatedList = List<UserStoriesModel>.from(state.storiesList);
        updatedList[userStoryIndex] = userStory.copyWith(
          stories: updatedStories,
        );

        emit(state.copyWith(storiesList: updatedList));
      },
    );
  }

  Future<void> createStory({
    String? content,
    List<File>? images,
    List<XFile>? videos,
  }) async {
    emit(state.copyWith(createStoryState: CubitStates.loading));
    final result = await storiesRepository.createStories(
      content: content,
      images: images,
      videos: videos,
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
        // Refresh stories
        fetchStories();
      },
    );
  }
}
