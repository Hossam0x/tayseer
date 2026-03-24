import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/story_details_view.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/stories/stories_skeleton.dart';
import 'package:tayseer/features/advisor/settings/view/widgets/stories/story_grid_item.dart';
import 'package:tayseer/my_import.dart';

class StoriesTabView extends StatelessWidget {
  const StoriesTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArchivedStoriesCubit, ArchivedStoriesState>(
      listener: (context, state) {
        if (state.errorMessage != null && state.state == CubitStates.failure) {
          AppToast.error(context, state.errorMessage!);
          context.read<ArchivedStoriesCubit>().clearError();
        }
      },
      builder: (context, state) {
        switch (state.state) {
          case CubitStates.loading:
            return const StoriesSkeleton();
          case CubitStates.failure:
            return CustomErrorView(
              message: state.errorMessage,
              onRetry: () => context.read<ArchivedStoriesCubit>().refresh(),
            );
          case CubitStates.success:
            if (state.stories.isEmpty) {
              return SharedEmptyState(title: context.tr('no_stories'));
            }
            return _StoriesGrid(state: state);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }
}

class _StoriesGrid extends StatelessWidget {
  final ArchivedStoriesState state;
  const _StoriesGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final allStories = <MapEntry<UserStoriesModel, StoryModel>>[];
    for (final userStory in state.stories) {
      for (final story in userStory.stories) {
        allStories.add(MapEntry(userStory, story));
      }
    }

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
                    return _LoadMoreIndicator(state: state);
                  }
                  final parentUserStory = allStories[index].key;
                  final story = allStories[index].value;
                  return GestureDetector(
                    onTap: () => _openStory(context, parentUserStory, story),
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

  void _openStory(
    BuildContext context,
    UserStoriesModel parentUserStory,
    StoryModel story,
  ) {
    final chronologicalStories = parentUserStory.stories.reversed.toList();
    final tempUserStory = parentUserStory.copyWith(
      stories: chronologicalStories,
    );

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (newContext, _, __) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: getIt<StoriesCubit>()),
            BlocProvider.value(value: context.read<ArchivedStoriesCubit>()),
          ],
          child: StoryDetailsView(
            usersStories: [tempUserStory],
            initialUserIndex: 0,
            heroTag: 'archive_${story.id}',
            isArchive: true,
            initialStoryId: story.id,
          ),
        ),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

class _LoadMoreIndicator extends StatelessWidget {
  final ArchivedStoriesState state;
  const _LoadMoreIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.hasMore) return const SizedBox.shrink();
    if (state.isLoadingMore) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          color: Colors.grey.shade100,
        ),
      );
    }
    return Center(
      child: Icon(
        Icons.arrow_downward,
        color: AppColors.primary300,
        size: 24.sp,
      ),
    );
  }
}
