import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_states.dart';
import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_navigation.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/stories/stories_load_more_indicator.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/stories/story_grid_item.dart';
import 'package:tayseer/my_import.dart';

class StoriesGrid extends StatelessWidget {
  final ArchivedStoriesState state;
  const StoriesGrid({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final allStories = flattenStories(state.stories);

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          if (state.hasMore && !state.isLoadingMore) {
            context.read<ArchivedStoriesCubit>().fetchArchivedStories(
              loadMore: true,
            );
          }
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () => context.read<ArchivedStoriesCubit>().refresh(),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(20.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == allStories.length) {
                    return StoriesLoadMoreIndicator(state: state);
                  }
                  final parentUserStory = allStories[index].key;
                  final story = allStories[index].value;
                  return GestureDetector(
                    onTap: () => _onStoryTap(context, parentUserStory, story),
                    child: Hero(
                      tag: 'archive_${story.id}',
                      child: StoryGridItem(story: story),
                    ),
                  );
                }, childCount: allStories.length + (state.hasMore ? 1 : 0)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStoryTap(
    BuildContext context,
    UserStoriesModel parentUserStory,
    StoryModel story,
  ) {
    final tempUserStory = parentUserStory.copyWith(
      stories: parentUserStory.stories.reversed.toList(),
    );
    openStoryDetails(
      context: context,
      usersStories: [tempUserStory],
      initialUserIndex: 0,
      heroTag: 'archive_${story.id}',
      isArchive: true,
      initialStoryId: story.id,
    );
  }
}
