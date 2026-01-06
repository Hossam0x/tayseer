import 'package:story_view/story_view.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
import 'package:tayseer/my_import.dart' hide Direction;

class StoryDetailsView extends StatefulWidget {
  final UserStoriesModel userStories;

  const StoryDetailsView({super.key, required this.userStories});

  @override
  State<StoryDetailsView> createState() => _StoryDetailsViewState();
}

class _StoryDetailsViewState extends State<StoryDetailsView> {
  final StoryController _storyController = StoryController();
  final List<StoryItem> _storyItems = [];
  DateTime? _currentStoryTime;
  int _currentStoryIndex = 0;

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
    if (widget.userStories.stories.isNotEmpty) {
      _currentStoryTime = widget.userStories.stories.first.createdAt;
    }

    for (var story in widget.userStories.stories) {
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

  void _markCurrentStoryAsViewed() {
    if (_currentStoryIndex < widget.userStories.stories.length) {
      final currentStory = widget.userStories.stories[_currentStoryIndex];
      context.read<StoriesCubit>().markStoryAsViewed(
        storyId: currentStory.id,
        userId: widget.userStories.userId,
      );
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
                      if (index < widget.userStories.stories.length) {
                        _currentStoryIndex = index;
                        _currentStoryTime =
                            widget.userStories.stories[index].createdAt;
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
            child: BlocBuilder<StoriesCubit, StoriesState>(
              buildWhen: (previous, current) =>
                  previous.storiesList != current.storiesList,
              builder: (context, state) {
                // البحث عن القصة الحالية في الـ state المحدث
                final updatedUserStory = state.storiesList.firstWhere(
                  (userStory) => userStory.userId == widget.userStories.userId,
                  orElse: () => widget.userStories,
                );

                final currentStory =
                    _currentStoryIndex < updatedUserStory.stories.length
                    ? updatedUserStory.stories[_currentStoryIndex]
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
            onOpened: () {
              _storyController.pause();
            },
            onCanceled: () {
              _storyController.play();
            },
            onSelected: (value) {
              _storyController.play();
              if (value == 'report') {
                // TODO: تنفيذ الإبلاغ
              } else if (value == 'hide') {
                // TODO: تنفيذ الإخفاء
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      context.tr(AppStrings.report),
                      style: Styles.textStyle14.copyWith(color: Colors.black),
                    ),
                    Gap(8.w),
                    Icon(
                      Icons.report_outlined,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'hide',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      context.tr(AppStrings.hide),
                      style: Styles.textStyle14.copyWith(color: Colors.black),
                    ),
                    Gap(8.w),
                    Icon(
                      Icons.hide_image_outlined,
                      size: 20.sp,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
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
                  tag: widget.userStories.userId,
                  child: Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        22.5.r,
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
        ],
      ),
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
