import 'package:tayseer/features/advisor/stories/stories.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_states.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_custom_controller.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_likers_bottom_sheet.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_overlay_widgets.dart';
import 'package:tayseer/my_import.dart';

class StoryBottomSection extends StatelessWidget {
  final UserStoriesModel userStories;
  final StoryModel? currentStory;
  final bool isActive;
  final bool isArchive;
  final CustomStoryController storyController;

  const StoryBottomSection({
    super.key,
    required this.userStories,
    required this.currentStory,
    required this.isActive,
    required this.isArchive,
    required this.storyController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: currentStory?.isMine == true
          ? _MyStoryActions(
              story: currentStory!,
              storyController: storyController,
              isActive: isActive,
            )
          : Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: _LikeButton(
                userStories: userStories,
                currentStory: currentStory,
                isArchive: isArchive,
              ),
            ),
    );
  }
}

// ── My story: views + likes count ────────────────────────────────────────────
class _MyStoryActions extends StatelessWidget {
  final StoryModel story;
  final CustomStoryController storyController;
  final bool isActive;

  const _MyStoryActions({
    required this.story,
    required this.storyController,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        storyController.pause();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: true,
          builder: (_) => StoryLikersBottomSheet(likers: story.likedBy ?? []),
        ).then((_) {
          if (isActive) storyController.play();
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.remove_red_eye_outlined,
              color: Colors.white,
              size: 22.sp,
            ),
            Gap(6.w),
            Text(
              '${story.viewsCount}',
              style: Styles.textStyle14Bold.copyWith(color: Colors.white),
            ),
            Gap(16.w),
            Icon(Icons.favorite, color: Colors.red, size: 22.sp),
            Gap(6.w),
            Text(
              '${story.likesCount}',
              style: Styles.textStyle14Bold.copyWith(color: Colors.white),
            ),
            const Spacer(),
            if (story.likedBy?.isNotEmpty == true)
              _StackedAvatars(likers: story.likedBy!),
          ],
        ),
      ),
    );
  }
}

// ── Stacked avatars ───────────────────────────────────────────────────────────
class _StackedAvatars extends StatelessWidget {
  final List<StoryUserModel> likers;
  const _StackedAvatars({required this.likers});

  @override
  Widget build(BuildContext context) {
    final count = likers.length.clamp(0, 3);
    return SizedBox(
      width: (18.w * (count - 1)) + 28.w,
      height: 28.h,
      child: Stack(
        alignment: Alignment.centerRight,
        children: List.generate(
          count,
          (i) => Positioned(
            right: i * 18.w,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.w),
              ),
              child: CircleAvatar(
                radius: 12.r,
                backgroundImage: NetworkImage(likers[i].image),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Like button (viewer) ──────────────────────────────────────────────────────
class _LikeButton extends StatelessWidget {
  final UserStoriesModel userStories;
  final StoryModel? currentStory;
  final bool isArchive;

  const _LikeButton({
    required this.userStories,
    required this.currentStory,
    required this.isArchive,
  });

  @override
  Widget build(BuildContext context) {
    if (isArchive) {
      return BlocBuilder<ArchivedStoriesCubit, ArchivedStoriesState>(
        builder: (context, state) {
          final story = _resolveStory(state.stories);
          return StoryLoveButton(
            isLiked: story?.isLiked ?? false,
            onTap: () {
              if (story != null) {
                context.read<ArchivedStoriesCubit>().likeStory(
                  storyId: story.id,
                  userId: userStories.userId,
                );
              }
            },
          );
        },
      );
    }

    return BlocBuilder<StoriesCubit, StoriesState>(
      buildWhen: (p, c) => p.storiesList != c.storiesList,
      builder: (context, state) {
        final story = _resolveStory(state.storiesList);
        return StoryLoveButton(
          isLiked: story?.isLiked ?? false,
          onTap: () {
            if (story != null) {
              context.read<StoriesCubit>().likeStory(
                storyId: story.id,
                userId: userStories.userId,
              );
            }
          },
        );
      },
    );
  }

  StoryModel? _resolveStory(List<UserStoriesModel> list) {
    if (currentStory == null) return null;
    final us = list.firstWhere(
      (u) => u.userId == userStories.userId,
      orElse: () => userStories,
    );
    return us.stories.firstWhere(
      (s) => s.id == currentStory!.id,
      orElse: () => currentStory!,
    );
  }
}
