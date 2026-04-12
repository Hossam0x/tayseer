import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_avatar_tile.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_navigation.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_ring_container.dart';
import 'package:tayseer/my_import.dart';

class HomeUserStoryItem extends StatelessWidget {
  final String userId;
  final int userIndex;

  const HomeUserStoryItem({
    super.key,
    required this.userId,
    required this.userIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<StoriesCubit, StoriesState, UserStoriesModel?>(
      selector: (state) {
        try {
          return state.storiesList.firstWhere((s) => s.userId == userId);
        } catch (_) {
          return null;
        }
      },
      builder: (context, userStoryModel) {
        if (userStoryModel == null) return const SizedBox.shrink();
        return CustomClick(
          onTap: () => _openStory(context, userStoryModel),
          child: StoryAvatarTile(
            name: userStoryModel.name,
            avatar: StoryRingContainer(
              heroTag: userStoryModel.userId,
              allViewed: userStoryModel.allViewed,
              child: AppImage(userStoryModel.image, fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }

  void _openStory(BuildContext context, UserStoriesModel userStoryModel) {
    final myUserId = kCurrentUserData?.id;
    final allStories = context
        .read<StoriesCubit>()
        .state
        .storiesList
        .where((us) => us.userId != myUserId)
        .map((us) => us.copyWith(stories: us.stories.reversed.toList()))
        .toList();

    final safeIndex = allStories
        .indexWhere((us) => us.userId == userId)
        .clamp(0, allStories.length - 1);

    openStoryDetails(
      context: context,
      usersStories: allStories,
      initialUserIndex: safeIndex,
    );
  }
}
