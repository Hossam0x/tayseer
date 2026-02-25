import 'package:story_view/story_view.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive_states.dart';
import 'package:tayseer/features/user/user_advisor_profile/views/user_advisor_profile_view.dart';
import 'package:tayseer/features/user/user_profile/views/user_public_profile_view.dart';
import 'package:tayseer/my_import.dart' hide Direction;

class StoryDetailsView extends StatefulWidget {
  final List<UserStoriesModel> usersStories;
  final int initialUserIndex;
  final String? heroTag;
  final bool isArchive;
  final String? initialStoryId;

  const StoryDetailsView({
    super.key,
    required this.usersStories,
    required this.initialUserIndex,
    this.heroTag,
    this.isArchive = false,
    this.initialStoryId,
  });

  @override
  State<StoryDetailsView> createState() => _StoryDetailsViewState();
}

class _StoryDetailsViewState extends State<StoryDetailsView> with RouteAware {
  late PageController _pageController;
  late int _currentUserIndex;
  double _vOffset = 0;
  bool _isDragging = false;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex;
    _pageController = PageController(initialPage: widget.initialUserIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    videoRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    videoRouteObserver.unsubscribe(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    // We should pause whatever is playing.
    // We'll use a static or global approach if needed, but for now we'll rely on the child widget's visibility detection.
  }

  @override
  void didPopNext() {
    // Resume
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - (_vOffset / 400)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Listener(
        onPointerMove: (event) {
          if (!_isDragging && event.delta.dx.abs() > event.delta.dy.abs()) {
            return;
          }
          setState(() {
            _vOffset += event.delta.dy;
            if (_vOffset < 0) _vOffset = 0;
            if (_vOffset > 0 && !_isDragging) {
              _isDragging = true;
            }
          });
        },
        onPointerUp: (event) {
          if (_isPopping) return;
          if (_vOffset > 100) {
            _isPopping = true;
            Navigator.pop(context);
          } else if (_isDragging || _vOffset > 0) {
            setState(() {
              _vOffset = 0;
              _isDragging = false;
            });
          }
        },
        child: Opacity(
          opacity: opacity,
          child: AnimatedContainer(
            duration: _isDragging
                ? Duration.zero
                : const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translate(0.0, _vOffset, 0.0)
              ..scale(1 - (_vOffset / 2000).clamp(0.0, 0.2)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_isDragging ? 20.r : 0),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.usersStories.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentUserIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _UserStoryPage(
                    userStories: widget.usersStories[index],
                    isArchive: widget.isArchive,
                    heroTag: index == widget.initialUserIndex
                        ? widget.heroTag
                        : null,
                    initialStoryId: index == widget.initialUserIndex
                        ? widget.initialStoryId
                        : null,
                    onAllStoriesComplete: () {
                      if (_currentUserIndex < widget.usersStories.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        if (!_isPopping) {
                          _isPopping = true;
                          Navigator.pop(context);
                        }
                      }
                    },
                    onDraggingChanged: (dragging) {
                      // Handled by parent Listener mostly, but child can signal if needed
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual User Stories Page
// ─────────────────────────────────────────────────────────────────────────────
class _UserStoryPage extends StatefulWidget {
  final UserStoriesModel userStories;
  final bool isArchive;
  final String? initialStoryId;
  final String? heroTag;
  final VoidCallback onAllStoriesComplete;
  final ValueChanged<bool> onDraggingChanged;

  const _UserStoryPage({
    required this.userStories,
    required this.isArchive,
    this.initialStoryId,
    this.heroTag,
    required this.onAllStoriesComplete,
    required this.onDraggingChanged,
  });

  @override
  State<_UserStoryPage> createState() => _UserStoryPageState();
}

class _UserStoryPageState extends State<_UserStoryPage> {
  late StoryController _storyController;
  final List<StoryItem> _storyItems = [];
  late List<StoryModel> _reorderedStories;
  int _currentStoryIndex = 0;
  DateTime? _currentStoryTime;

  @override
  void initState() {
    super.initState();
    _storyController = StoryController();
    _initStoryItems();
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  void _initStoryItems() {
    final chronologicalStories = widget.userStories.stories.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _reorderedStories = chronologicalStories;

    int startIndex = 0;
    if (widget.initialStoryId != null) {
      final index = chronologicalStories.indexWhere(
        (s) => s.id == widget.initialStoryId,
      );
      if (index != -1) startIndex = index;
    } else {
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
      final hasVideo = story.video != null && story.video!.isNotEmpty;
      if (hasVideo) {
        final duration =
            (story.videoDuration != null && story.videoDuration! > 0)
            ? Duration(milliseconds: (story.videoDuration! * 1000).round())
            : const Duration(seconds: 15);
        _storyItems.add(
          StoryItem.pageVideo(
            story.video!,
            controller: _storyController,
            duration: duration,
          ),
        );
      } else {
        _storyItems.add(
          StoryItem.pageImage(
            url: story.image,
            controller: _storyController,
            imageFit: BoxFit.contain,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }

    if (startIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
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
      if (!widget.isArchive) {
        context.read<StoriesCubit>().markStoryAsViewed(
          storyId: currentStory.id,
          userId: widget.userStories.userId,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: VisibilityDetector(
            key: ValueKey('story-page-${widget.userStories.userId}'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction == 0)
                _storyController.pause();
              else if (info.visibleFraction == 1)
                _storyController.play();
            },
            child: StoryView(
              storyItems: _storyItems,
              controller: _storyController,
              onComplete: widget.onAllStoriesComplete,
              onStoryShow: (item, index) {
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
        ),
        // Header
        Positioned(
          top: 30.h,
          right: 20.w,
          left: 20.w,
          child: _buildCustomHeader(),
        ),
        // Bottom Actions & Like Button
        Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomSection()),
      ],
    );
  }

  Widget _buildBottomSection() {
    final currentStoryId = _currentStoryIndex < _reorderedStories.length
        ? _reorderedStories[_currentStoryIndex].id
        : null;
    final currentStory = currentStoryId != null
        ? _reorderedStories[_currentStoryIndex]
        : null;

    if (currentStory != null && currentStory.isMine) {
      return Padding(
        padding: EdgeInsets.only(bottom: 30.h),
        child: _buildMyStoryBottomActions(currentStory),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 30.h),
      child: Stack(
        children: [
          // If we had other bottom UI, it would go here.
          // The Like button is now explicitly pushed to the end (top-right of this bottom container or bottom-right of stack)
          Align(
            alignment: context.isArabicLang
                ? Alignment.bottomLeft
                : Alignment.bottomRight,
            child: widget.isArchive
                ? BlocBuilder<ArchivedStoriesCubit, ArchivedStoriesState>(
                    builder: (context, state) {
                      final updatedUserStory = state.stories.firstWhere(
                        (us) => us.userId == widget.userStories.userId,
                        orElse: () => widget.userStories,
                      );
                      final storyData = currentStoryId != null
                          ? updatedUserStory.stories.firstWhere(
                              (s) => s.id == currentStoryId,
                              orElse: () => currentStory!,
                            )
                          : null;
                      return _LoveButton(
                        isLiked: storyData?.isLiked ?? false,
                        onTap: () {
                          if (storyData != null) {
                            context.read<ArchivedStoriesCubit>().likeStory(
                              storyId: storyData.id,
                              userId: widget.userStories.userId,
                            );
                          }
                        },
                      );
                    },
                  )
                : BlocBuilder<StoriesCubit, StoriesState>(
                    buildWhen: (prev, curr) =>
                        prev.storiesList != curr.storiesList,
                    builder: (context, state) {
                      final updatedUserStory = state.storiesList.firstWhere(
                        (us) => us.userId == widget.userStories.userId,
                        orElse: () => widget.userStories,
                      );
                      final storyData = currentStoryId != null
                          ? updatedUserStory.stories.firstWhere(
                              (s) => s.id == currentStoryId,
                              orElse: () => currentStory!,
                            )
                          : null;
                      return _LoveButton(
                        isLiked: storyData?.isLiked ?? false,
                        onTap: () {
                          if (storyData != null) {
                            context.read<StoriesCubit>().likeStory(
                              storyId: storyData.id,
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
                    context: context,
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                  );
                  if (mounted) Navigator.pop(context);
                } else if (value == 'unarchive') {
                  await cubit.unarchiveStory(
                    context: context,
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                  );
                  if (mounted) Navigator.pop(context);
                }
              } else {
                final cubit = context.read<StoriesCubit>();
                if (value == 'delete') {
                  await cubit.deleteStory(
                    context: context,
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                  );
                  if (mounted) Navigator.pop(context);
                } else if (value == 'archive') {
                  await cubit.toggleArchiveStory(
                    context: context,
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                    isArchive: true,
                  );
                  if (mounted) Navigator.pop(context);
                } else if (value == 'special') {
                  await cubit.makeStorySpecial(
                    context: context,
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                  );
                } else if (value == 'report') {
                  context.pushNamed(AppRouter.kReportReasonsScreen);
                } else if (value == 'hide') {
                  await cubit.hideStory(
                    context: context,
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                  );
                  if (mounted) Navigator.pop(context);
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
                _storyController.pause();
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
                  Hero(
                    tag: widget.heroTag ?? widget.userStories.userId,
                    child: Container(
                      width: 45.w,
                      height: 45.w,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1000.r),
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

  Widget _buildMyStoryBottomActions(StoryModel currentStory) {
    return GestureDetector(
      onTap: () {
        _storyController.pause();
        _showViewersBottomSheet(
          context,
          currentStory,
        ).then((_) => _storyController.play());
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
              '${currentStory.viewsCount}',
              style: Styles.textStyle14Bold.copyWith(color: Colors.white),
            ),
            Gap(16.w),
            Icon(Icons.favorite, color: Colors.red, size: 22.sp),
            Gap(6.w),
            Text(
              '${currentStory.likesCount}',
              style: Styles.textStyle14Bold.copyWith(color: Colors.white),
            ),
            const Spacer(),
            if (currentStory.likedBy != null &&
                currentStory.likedBy!.isNotEmpty)
              _buildStackedAvatars(currentStory.likedBy!),
          ],
        ),
      ),
    );
  }

  Widget _buildStackedAvatars(List<StoryUserModel> likers) {
    final count = likers.length.clamp(0, 3);
    return SizedBox(
      width: (18.w * (count - 1)) + 28.w,
      height: 28.h,
      child: Stack(
        alignment: Alignment.centerRight,
        children: List.generate(count, (i) {
          return Positioned(
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
          );
        }),
      ),
    );
  }

  Future<void> _showViewersBottomSheet(
    BuildContext context,
    StoryModel story,
  ) async {
    final likers = story.likedBy ?? [];
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LikersBottomSheet(likers: likers),
    );
  }
}

class _LoveButton extends StatelessWidget {
  const _LoveButton({required this.isLiked, required this.onTap});

  final bool isLiked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 45.w,
          height: 45.w,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.24),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.white,
            size: 26.sp,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Likers Bottom Sheet — with pagination & profile navigation
// ─────────────────────────────────────────────────────────────────────────────
class _LikersBottomSheet extends StatefulWidget {
  final List<StoryUserModel> likers;

  const _LikersBottomSheet({required this.likers});

  @override
  State<_LikersBottomSheet> createState() => _LikersBottomSheetState();
}

class _LikersBottomSheetState extends State<_LikersBottomSheet> {
  static const int _pageSize = 15;
  int _visibleCount = _pageSize;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (_visibleCount < widget.likers.length) {
        setState(() {
          _visibleCount = (_visibleCount + _pageSize).clamp(
            0,
            widget.likers.length,
          );
        });
      }
    }
  }

  void _navigateToProfile(BuildContext context, StoryUserModel user) {
    Navigator.pop(context); // close bottom sheet first
    final isAdvisor = user.userType.toLowerCase() == 'advisor';
    if (isAdvisor) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserAdvisorProfileView(advisorId: user.id),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserPublicProfileView(userId: user.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedLikers = widget.likers.take(_visibleCount).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // ── Handle bar ─────────────────────────────────────────
          Gap(12.h),
          Container(
            width: 40.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          Gap(16.h),
          // ── Title ───────────────────────────────────────────────
          Text(
            context.tr('likers') != 'likers'
                ? context.tr('likers')
                : 'المعجبين',
            style: Styles.textStyle16Bold,
          ),
          Gap(16.h),
          // ── Content ─────────────────────────────────────────────
          if (widget.likers.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  context.tr('no_likers_yet') != 'no_likers_yet'
                      ? context.tr('no_likers_yet')
                      : 'لا يوجد إعجابات بعد',
                  style: Styles.textStyle14.copyWith(color: AppColors.kGreyB3),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    displayedLikers.length +
                    (_visibleCount < widget.likers.length ? 1 : 0),
                itemBuilder: (context, index) {
                  // Loading indicator at the bottom
                  if (index == displayedLikers.length) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.kprimaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                  final user = displayedLikers[index];
                  return InkWell(
                    onTap: () => _navigateToProfile(context, user),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 6.h,
                      ),
                      leading: CircleAvatar(
                        radius: 22.r,
                        backgroundImage: NetworkImage(user.image),
                      ),
                      title: Text(user.name, style: Styles.textStyle14SemiBold),
                      trailing: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 22.sp,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
