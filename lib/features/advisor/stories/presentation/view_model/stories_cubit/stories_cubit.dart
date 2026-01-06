import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/data/repository/stories_repository.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/my_import.dart';

class StoriesCubit extends Cubit<StoriesState> {
  final StoriesRepository storiesRepository;
  final int pageSize = 10;

  StoriesCubit(this.storiesRepository) : super(const StoriesState());

  Future<void> fetchStories({bool loadMore = false}) async {
    if (loadMore) {
      if (state.isLoadingMore || !state.hasMore) return;
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;
      final result = await storiesRepository.fetchStories(page: nextPage);

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
        ),
      );
      final result = await storiesRepository.fetchStories(page: 1);
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
            ),
          );
        },
      );
    }
  }

  void markStoryAsViewed({required String storyId, required String userId}) {
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
      viewsCount: story.viewsCount + 1,
    );

    // التحقق إذا تمت مشاهدة جميع القصص
    final allViewed = updatedStories.every((s) => s.viewsCount > 0);

    // تحديث userStory فقط
    final updatedUserStory = userStory.copyWith(
      stories: updatedStories,
      allViewed: allViewed,
      isViewedByMe: true,
    );

    // تحديث القائمة الرئيسية - فقط العنصر المتغير
    final updatedList = List<UserStoriesModel>.from(state.storiesList);
    updatedList[userStoryIndex] = updatedUserStory;

    emit(state.copyWith(storiesList: updatedList));

    // إرسال الطلب للـ backend
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
}
