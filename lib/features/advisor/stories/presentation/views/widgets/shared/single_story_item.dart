import 'package:tayseer/features/advisor/stories/data/models/stories_response_model.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_avatar_tile.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_navigation.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_ring_container.dart';
import 'package:tayseer/my_import.dart';

class SingleStoryItem extends StatefulWidget {
  final StoryModel story;
  final UserStoriesModel parentUserStory;
  final List<UserStoriesModel> allStories;

  const SingleStoryItem({
    super.key,
    required this.story,
    required this.parentUserStory,
    required this.allStories,
  });

  @override
  State<SingleStoryItem> createState() => _SingleStoryItemState();
}

class _SingleStoryItemState extends State<SingleStoryItem> {
  String? _previousImageUrl;

  @override
  void didUpdateWidget(SingleStoryItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parentUserStory.image != widget.parentUserStory.image) {
      _previousImageUrl = oldWidget.parentUserStory.image;
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = 'profile_story_${widget.story.id}';
    return CustomClick(
      onTap: () => _openStory(context, heroTag),
      child: StoryAvatarTile(
        name: widget.parentUserStory.name,
        avatar: StoryRingContainer(
          heroTag: heroTag,
          allViewed: widget.parentUserStory.allViewed,
          child: CachedNetworkImage(
            imageUrl: widget.story.image,
            fit: BoxFit.cover,
            width: context.responsiveWidth(76),
            height: context.responsiveWidth(76),
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            useOldImageOnUrlChange: true,
            placeholder: (_, _x) =>
                _previousImageUrl != null && _previousImageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: _previousImageUrl!,
                    fit: BoxFit.cover,
                    width: context.responsiveWidth(76),
                    height: context.responsiveWidth(76),
                    fadeInDuration: Duration.zero,
                    fadeOutDuration: Duration.zero,
                    errorWidget: (_, _x, _y) =>
                        Container(color: AppColors.secondary200),
                  )
                : Container(color: AppColors.secondary200),
            errorWidget: (_, _x, _y) => Container(
              color: AppColors.secondary200,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.secondary400,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openStory(BuildContext context, String heroTag) {
    final flatList = <UserStoriesModel>[
      for (final us in widget.allStories)
        for (final s in ([
          ...us.stories,
        ]..sort((a, b) => b.createdAt.compareTo(a.createdAt))))
          us.copyWith(stories: [s]),
    ];

    final initialIndex = flatList.indexWhere(
      (us) => us.stories.first.id == widget.story.id,
    );

    openStoryDetails(
      context: context,
      usersStories: flatList,
      initialUserIndex: initialIndex != -1 ? initialIndex : 0,
      heroTag: heroTag,
    );
  }
}
