import 'package:story_view/story_view.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/my_import.dart' hide Direction;

class StoryDetailsView extends StatefulWidget {
  final UserStoriesModel userStories;
  final String? heroTag;
  final bool isArchive;
  final String? initialStoryId;

  const StoryDetailsView({
    super.key,
    required this.userStories,
    this.heroTag,
    this.isArchive = false,
    this.initialStoryId,
  });

  @override
  State<StoryDetailsView> createState() => _StoryDetailsViewState();
}

class _StoryDetailsViewState extends State<StoryDetailsView> {
  final StoryController _storyController = StoryController();
  final List<StoryItem> _storyItems = [];
  DateTime? _currentStoryTime;
  int _currentStoryIndex = 0;
  late List<StoryModel> _reorderedStories;

  @override
  void initState() {
    super.initState();
    _initStoryItems();
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  void _initStoryItems() {
    // Force chronological order (Oldest -> Newest)
    final chronologicalStories = widget.userStories.stories.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    _reorderedStories = chronologicalStories;

    // Determine start index
    int startIndex = 0;

    if (widget.initialStoryId != null) {
      // If a specific story ID is provided, start from there
      final index = chronologicalStories.indexWhere(
        (s) => s.id == widget.initialStoryId,
      );
      if (index != -1) {
        startIndex = index;
      }
    } else {
      // Find the first unviewed story index as default
      final firstUnviewedIndex = chronologicalStories.indexWhere(
        (story) => !story.isViewed,
      );
      startIndex = firstUnviewedIndex != -1 ? firstUnviewedIndex : 0;
    }

    if (_reorderedStories.isNotEmpty) {
      _currentStoryTime = _reorderedStories[startIndex].createdAt;
      _currentStoryIndex = startIndex;
    }

    for (var story in _reorderedStories) {
      // Check if the story has a video URL
      final hasVideo = story.video != null && story.video!.isNotEmpty;

      if (hasVideo) {
        // Add video story
        _storyItems.add(
          StoryItem.pageVideo(
            story.video!,
            controller: _storyController,
            duration: const Duration(seconds: 15),
            key: Key(story.id),
          ),
        );
      } else {
        // Add image story
        _storyItems.add(
          StoryItem.pageImage(
            url: story.image,
            controller: _storyController,
            imageFit: BoxFit.contain,
            duration: const Duration(seconds: 5),
            key: Key(story.id),
          ),
        );
      }
    }

    // Jump to the first unviewed story after the widget builds
    if (startIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          // Small delay to ensure StoryView is ready
          await Future.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;

          // Jump to the story at startIndex
          for (int i = 0; i < startIndex; i++) {
            _storyController.next();
          }
        }
      });
    }
  }

  void _markCurrentStoryAsViewed() {
    if (_currentStoryIndex < _reorderedStories.length) {
      final currentStory = _reorderedStories[_currentStoryIndex];
      // Note: We removed the !isMine check so the user can see their own border update locally.
      if (widget.isArchive) {
        // Archived stories view marking logic if needed
      } else {
        context.read<StoriesCubit>().markStoryAsViewed(
          storyId: currentStory.id,
          userId: widget.userStories.userId,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: StoryView(
              storyItems: _storyItems,
              controller: _storyController,
              onComplete: () {
                Navigator.pop(context);
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
              onStoryShow: (StoryItem item, int index) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      if (index < _reorderedStories.length) {
                        _currentStoryIndex = index;
                        _currentStoryTime = _reorderedStories[index].createdAt;
                        _markCurrentStoryAsViewed();
                      }
                    });
                  }
                });
              },
              progressPosition: ProgressPosition.top,
              repeat: false,
              inline: false,
            ),
          ),
          Positioned(
            top: 30.h,
            right: 20.w,
            left: 20.w,
            child: _buildCustomHeader(),
          ),

          Positioned(
            bottom: 30.h,
            child: widget.isArchive
                ? BlocBuilder<ArchivedStoriesCubit, ArchivedStoriesState>(
                    builder: (context, state) {
                      final updatedUserStory = state.stories.firstWhere(
                        (userStory) =>
                            userStory.userId == widget.userStories.userId,
                        orElse: () => widget.userStories,
                      );

                      // Find current story by ID from reordered list
                      final currentStoryId =
                          _currentStoryIndex < _reorderedStories.length
                          ? _reorderedStories[_currentStoryIndex].id
                          : null;

                      final currentStory = currentStoryId != null
                          ? updatedUserStory.stories.firstWhere(
                              (s) => s.id == currentStoryId,
                              orElse: () =>
                                  _reorderedStories[_currentStoryIndex],
                            )
                          : null;

                      return _LoveButton(
                        isLiked: currentStory?.isLiked ?? false,
                        onTap: () {
                          if (currentStory != null) {
                            context.read<ArchivedStoriesCubit>().likeStory(
                              storyId: currentStory.id,
                              userId: widget.userStories.userId,
                            );
                          }
                        },
                      );
                    },
                  )
                : BlocBuilder<StoriesCubit, StoriesState>(
                    buildWhen: (previous, current) =>
                        previous.storiesList != current.storiesList,
                    builder: (context, state) {
                      final updatedUserStory = state.storiesList.firstWhere(
                        (userStory) =>
                            userStory.userId == widget.userStories.userId,
                        orElse: () => widget.userStories,
                      );

                      // Find current story by ID from reordered list
                      final currentStoryId =
                          _currentStoryIndex < _reorderedStories.length
                          ? _reorderedStories[_currentStoryIndex].id
                          : null;

                      final currentStory = currentStoryId != null
                          ? updatedUserStory.stories.firstWhere(
                              (s) => s.id == currentStoryId,
                              orElse: () =>
                                  _reorderedStories[_currentStoryIndex],
                            )
                          : null;

                      return _LoveButton(
                        isLiked: currentStory?.isLiked ?? false,
                        onTap: () {
                          if (currentStory != null) {
                            context.read<StoriesCubit>().likeStory(
                              storyId: currentStory.id,
                              userId: widget.userStories.userId,
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    final currentStory = _currentStoryIndex < _reorderedStories.length
        ? _reorderedStories[_currentStoryIndex]
        : null;

    final bool isMine = currentStory?.isMine ?? false;

    return SafeArea(
      bottom: false,
      right: false,
      left: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            icon: Icon(Icons.more_vert, color: Colors.white, size: 32.sp),
            onOpened: () => _storyController.pause(),
            onCanceled: () => _storyController.play(),
            onSelected: (value) async {
              _storyController.play();
              if (currentStory == null) return;

              if (widget.isArchive) {
                final cubit = context.read<ArchivedStoriesCubit>();
                if (value == 'delete') {
                  await cubit.deleteStory(
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                  );
                  if (mounted) Navigator.pop(context);
                } else if (value == 'unarchive') {
                  await cubit.unarchiveStory(
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                  );
                  if (mounted) Navigator.pop(context);
                }
              } else {
                final cubit = context.read<StoriesCubit>();
                if (value == 'delete') {
                  await cubit.deleteStory(
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                  );
                  if (mounted) Navigator.pop(context);
                } else if (value == 'archive') {
                  await cubit.toggleArchiveStory(
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                    isArchive: true,
                  );
                  if (mounted) Navigator.pop(context);
                } else if (value == 'special') {
                  await cubit.makeStorySpecial(
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                  );
                }
              }
            },
            itemBuilder: (context) {
              if (isMine) {
                return [
                  PopupMenuItem(
                    value: widget.isArchive ? 'unarchive' : 'archive',
                    child: _buildPopupItem(
                      widget.isArchive
                          ? context.tr("unarchive_story")
                          : context.tr("archive_story"),
                      widget.isArchive ? Icons.unarchive : Icons.archive,
                    ),
                  ),
                  // Only show special option if not archive and story is not already special
                  if (!widget.isArchive &&
                      currentStory != null &&
                      !currentStory.isSpecial)
                    PopupMenuItem(
                      value: 'special',
                      child: _buildPopupItem(
                        context.tr("special_story"),
                        Icons.star_outline,
                      ),
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: _buildPopupItem(
                      context.tr("delete_story"),
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                  ),
                ];
              }
              return [
                PopupMenuItem(
                  value: 'report',
                  child: _buildPopupItem(
                    context.tr(AppStrings.report),
                    Icons.report_outlined,
                  ),
                ),
                PopupMenuItem(
                  value: 'hide',
                  child: _buildPopupItem(
                    context.tr(AppStrings.hide),
                    Icons.hide_image_outlined,
                  ),
                ),
              ];
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserAdvisorProfileView(
                      advisorId: widget.userStories.userId,
                    ),
                  ),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    getTimeAgo(context, _currentStoryTime),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
                    ),
                  ),
                  Gap(8.w),
                  // الاسم
                  Flexible(
                    child: Text(
                      widget.userStories.name,
                      textAlign: TextAlign.end,
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
                  Gap(12.w),
                  // الصورة آخر حاجة (هتظهر في اليمين)
                  Hero(
                    tag: widget.heroTag ?? widget.userStories.userId,
                    child: Container(
                      width: 45.w,
                      height: 45.w,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          1000.r,
                        ), // نص الـ width عشان يبقى دايرة كاملة
                        child: AppImage(
                          widget.userStories.image,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupItem(String title, IconData icon, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
}

class _LoveButton extends StatelessWidget {
  const _LoveButton({required this.isLiked, required this.onTap});

  final bool isLiked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.symmetric(horizontal: 30.w),
      onPressed: onTap,
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.white,
        size: 30.sp,
      ),
    );
  }
}
