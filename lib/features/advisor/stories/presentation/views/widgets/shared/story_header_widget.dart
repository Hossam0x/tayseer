import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_cubits.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_custom_controller.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/my_import.dart';

class StoryHeaderWidget extends StatelessWidget {
  final UserStoriesModel userStories;
  final StoryModel? currentStory;
  final DateTime? currentStoryTime;
  final bool isActive;
  final bool isArchive;
  final CustomStoryController storyController;
  final String? heroTag;

  const StoryHeaderWidget({
    super.key,
    required this.userStories,
    required this.currentStory,
    required this.currentStoryTime,
    required this.isActive,
    required this.isArchive,
    required this.storyController,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMine = currentStory?.isMine ?? false;

    return SafeArea(
      bottom: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                storyController.pause();
                VideoManager.instance.stopAll();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        UserAdvisorProfileView(advisorId: userStories.userId),
                  ),
                ).then((_) {
                  if (isActive) storyController.play();
                });
              },
              child: Row(
                children: [
                  Builder(
                    builder: (context) {
                      final bool hasAncestorHero = context.findAncestorWidgetOfExactType<Hero>() != null;
                      
                      Widget content = Container(
                        width: 45.w,
                        height: 45.w,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(1000.r),
                          child: AppImage(userStories.image, fit: BoxFit.cover),
                        ),
                      );

                      if (!hasAncestorHero) {
                        content = Hero(
                          tag: heroTag ?? userStories.userId,
                          child: content,
                        );
                      }

                      return HeroMode(
                        enabled: isActive,
                        child: content,
                      );
                    },
                  ),
                  Gap(10.w),
                  Flexible(
                    child: Text(
                      userStories.name,
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: Colors.white,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 5),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap(6.w),
                  Text(
                    getTimeAgo(context, currentStoryTime),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      shadows: const [
                        Shadow(color: Colors.black45, blurRadius: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap(8.w),
          PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            icon: Icon(Icons.more_vert, color: Colors.white, size: 32.sp),
            onOpened: () => storyController.pause(),
            onCanceled: () {
              if (isActive) storyController.play();
            },
            onSelected: (value) async {
              if (isActive) storyController.play();
              if (currentStory == null) return;
              await _handleMenuAction(context, value, currentStory!);
            },
            itemBuilder: (context) =>
                isMine ? _buildOwnerItems(context) : _buildViewerItems(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    String value,
    StoryModel story,
  ) async {
    if (isArchive) {
      final cubit = context.read<ArchivedStoriesCubit>();
      if (value == 'delete') {
        await cubit.deleteStory(storyId: story.id, userId: userStories.userId);
      } else if (value == 'unarchive') {
        await cubit.unarchiveStory(
          storyId: story.id,
          userId: userStories.userId,
        );
      }
      return;
    }

    final cubit = context.read<StoriesCubit>();
    switch (value) {
      case 'delete':
        await cubit.deleteStory(
          context: context,
          storyId: story.id,
          userId: userStories.userId,
        );
        if (context.mounted) Navigator.pop(context);
      case 'archive':
        await cubit.toggleArchiveStory(
          context: context,
          storyId: story.id,
          userId: userStories.userId,
          isArchive: true,
        );
        if (context.mounted) Navigator.pop(context);
      case 'special':
        await cubit.makeStorySpecial(
          context: context,
          storyId: story.id,
          userId: userStories.userId,
        );
      case 'report':
        context.pushNamed(
          AppRouter.kReportsView,
          arguments: {'type': ReportType.story, 'id': story.id},
        );
      case 'hide':
        await cubit.hideStory(
          context: context,
          storyId: story.id,
          userId: userStories.userId,
        );
        if (context.mounted) Navigator.pop(context);
    }
  }

  List<PopupMenuEntry<String>> _buildOwnerItems(BuildContext context) => [
    PopupMenuItem(
      value: isArchive ? 'unarchive' : 'archive',
      child: _menuItem(
        context,
        isArchive ? context.tr('unarchive_story') : context.tr('archive_story'),
        isArchive ? Icons.unarchive : Icons.archive,
      ),
    ),
    if (!isArchive && currentStory != null && !currentStory!.isSpecial)
      PopupMenuItem(
        value: 'special',
        child: _menuItem(
          context,
          context.tr('special_story'),
          Icons.star_outline,
        ),
      ),
    PopupMenuItem(
      value: 'delete',
      child: _menuItem(
        context,
        context.tr('delete_story'),
        Icons.delete_outline,
        color: Colors.red,
      ),
    ),
  ];

  List<PopupMenuEntry<String>> _buildViewerItems(BuildContext context) => [
    PopupMenuItem(
      value: 'report',
      child: _menuItem(
        context,
        context.tr(AppStrings.report),
        Icons.report_outlined,
      ),
    ),
    PopupMenuItem(
      value: 'hide',
      child: _menuItem(
        context,
        context.tr(AppStrings.hide),
        Icons.hide_image_outlined,
      ),
    ),
  ];

  Widget _menuItem(
    BuildContext context,
    String title,
    IconData icon, {
    Color? color,
  }) => Row(
    children: [
      Icon(icon, size: 20.sp, color: color ?? Colors.black),
      Gap(8.w),
      Text(
        title,
        style: Styles.textStyle14.copyWith(color: color ?? Colors.black),
      ),
    ],
  );
}
