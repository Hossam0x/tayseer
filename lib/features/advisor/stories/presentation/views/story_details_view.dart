import 'package:story_view/story_view.dart';
import 'package:tayseer/core/enum/report_type.dart';
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
  final bool newestFirst;

  const StoryDetailsView({
    super.key,
    required this.usersStories,
    required this.initialUserIndex,
    this.heroTag,
    this.isArchive = false,
    this.initialStoryId,
    this.newestFirst = false,
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
  void didPushNext() {}

  @override
  void didPopNext() {}

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - (_vOffset / 400)).clamp(0.0, 1.0);

    if (widget.isArchive) {
      return MultiBlocListener(
        listeners: [
          BlocListener<ArchivedStoriesCubit, ArchivedStoriesState>(
            listenWhen: (prev, curr) =>
                prev.unarchiveActionState != curr.unarchiveActionState ||
                prev.deleteActionState != curr.deleteActionState,
            listener: (context, state) {
              if (state.unarchiveActionState == CubitStates.success) {
                if (state.unarchiveMessage != null) {
                  AppToast.success(
                    context,
                    context.tr(state.unarchiveMessage!),
                  );
                }
                context.read<ArchivedStoriesCubit>().resetUnarchiveStoryState();
                if (mounted) Navigator.pop(context);
              } else if (state.unarchiveActionState == CubitStates.failure) {
                if (state.unarchiveMessage != null) {
                  AppToast.error(context, state.unarchiveMessage!);
                }
                context.read<ArchivedStoriesCubit>().resetUnarchiveStoryState();
              }

              if (state.deleteActionState == CubitStates.success) {
                if (state.deleteMessage != null) {
                  AppToast.success(context, context.tr(state.deleteMessage!));
                }
                context.read<ArchivedStoriesCubit>().resetDeleteStoryState();
                if (mounted) Navigator.pop(context);
              } else if (state.deleteActionState == CubitStates.failure) {
                if (state.deleteMessage != null) {
                  AppToast.error(context, state.deleteMessage!);
                }
                context.read<ArchivedStoriesCubit>().resetDeleteStoryState();
              }
            },
          ),
        ],
        child: _buildScaffold(context, opacity),
      );
    }

    return _buildScaffold(context, opacity);
  }

  Widget _buildScaffold(BuildContext context, double opacity) {
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
                    isActive: _currentUserIndex == index,
                    isDragging: _isDragging,
                    newestFirst: widget.newestFirst,
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
                    onDraggingChanged: (dragging) {},
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
// Custom Story Controller — guards play() so inactive pages can't play
// ─────────────────────────────────────────────────────────────────────────────
class CustomStoryController extends StoryController {
  bool isAllowedToPlay = false;

  @override
  void play() {
    if (isAllowedToPlay) {
      super.play();
    }
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
  final bool isActive;
  final bool isDragging;
  final bool newestFirst;

  const _UserStoryPage({
    required this.userStories,
    required this.isArchive,
    this.initialStoryId,
    this.heroTag,
    required this.onAllStoriesComplete,
    required this.onDraggingChanged,
    this.isActive = false,
    this.isDragging = false,
    this.newestFirst = false,
  });

  @override
  State<_UserStoryPage> createState() => _UserStoryPageState();
}

class _UserStoryPageState extends State<_UserStoryPage> {
  late CustomStoryController _storyController;
  final List<StoryItem> _storyItems = [];
  late List<StoryModel> _reorderedStories;
  int _currentStoryIndex = 0;
  DateTime? _currentStoryTime;

  bool _storyItemsInitialized = false;

  @override
  void initState() {
    super.initState();
    _storyController = CustomStoryController();
    // Only the active page is allowed to trigger play
    _storyController.isAllowedToPlay = widget.isActive;
    // Note: _initStoryItems is called in didChangeDependencies (needs context)

    // Immediately pause inactive pages so the media loader doesn't fire play
    if (!widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _storyController.pause();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Build story items once — needs context for isArabicLang
    if (!_storyItemsInitialized) {
      _storyItemsInitialized = true;
      _initStoryItems();
    }
  }

  @override
  void didUpdateWidget(covariant _UserStoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Page became active — allow and start playing
    if (widget.isActive && !oldWidget.isActive) {
      _storyController.isAllowedToPlay = true;
      if (!widget.isDragging) {
        _storyController.play();
      }
      _markCurrentStoryAsViewed();
    }

    // Page became inactive — disallow and pause immediately
    if (!widget.isActive && oldWidget.isActive) {
      _storyController.isAllowedToPlay = false;
      _storyController.pause();
    }

    // Handle drag-to-dismiss pause/resume
    if (widget.isDragging && !oldWidget.isDragging && widget.isActive) {
      _storyController.pause();
    } else if (!widget.isDragging && oldWidget.isDragging && widget.isActive) {
      _storyController.play();
    }
  }

  @override
  void dispose() {
    _storyController.dispose();
    super.dispose();
  }

  void _initStoryItems() {
    final chronologicalStories = widget.userStories.stories.toList()
      ..sort(
        (a, b) => widget.newestFirst
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt),
      );
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

    final isArabic = context.isArabicLang;

    for (var story in _reorderedStories) {
      final hasVideo = story.video != null && story.video!.isNotEmpty;
      if (hasVideo) {
        final duration =
            (story.videoDuration != null && story.videoDuration! > 0)
            ? Duration(milliseconds: (story.videoDuration! * 1000).round())
            : const Duration(seconds: 15);
        _storyItems.add(
          StoryItem(
            Stack(
              fit: StackFit.expand,
              children: [
                // Black bg + video content
                Container(
                  color: Colors.black,
                  child: Transform.scale(
                    scaleX: isArabic ? -1.0 : 1.0,
                    child: StoryVideo.url(
                      story.video!,
                      controller: _storyController,
                      key: ValueKey('video_${story.id}'),
                      loadingWidget: const Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                      errorWidget: const Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Gradient overlay — top & bottom dark bands only
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.65),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                        stops: const [0.0, 0.18, 0.78, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            duration: duration,
          ),
        );
      } else {
        _storyItems.add(
          StoryItem(
            Stack(
              fit: StackFit.expand,
              children: [
                // Black bg + image content
                Container(
                  color: Colors.black,
                  child: Transform.scale(
                    scaleX: isArabic ? -1.0 : 1.0,
                    child: StoryImage.url(
                      story.image,
                      controller: _storyController,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Gradient overlay — top & bottom dark bands only
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.65),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                        stops: const [0.0, 0.18, 0.78, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    if (!widget.isActive) return;
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
    final isArabic = context.isArabicLang;

    return Stack(
      children: [
        // ── StoryView: outer flip makes bars go RTL; inner flip per item restores content ──
        // In Arabic: scaleX(-1) flips the whole StoryView so:
        //   - Bars are ordered right→left ✅
        //   - Fill inside each bar goes right→left ✅
        //   - Content (images/videos) have a counter-flip inside each StoryItem ✅
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(isArabic ? -1.0 : 1.0, 1.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
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
              indicatorOuterPadding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
            ),
          ),
        ),

        // ── RTL Gesture interceptor ─────────────────────────────────────────
        // The stock StoryView has: right 70% = next, left 70px = previous.
        // In Arabic UI we flip it: left 75% = next, right 25% = previous.
        if (isArabic)
          Positioned.fill(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  // LEFT area (75%) → NEXT story
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) {
                        if (widget.isActive) _storyController.pause();
                      },
                      onTapCancel: () {
                        if (widget.isActive) _storyController.play();
                      },
                      onTapUp: (_) {
                        if (!widget.isActive) return;
                        _storyController.play();
                        _storyController.next();
                      },
                    ),
                  ),
                  // RIGHT area (25%) → PREVIOUS story
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (_) {
                        if (widget.isActive) _storyController.pause();
                      },
                      onTapCancel: () {
                        if (widget.isActive) _storyController.play();
                      },
                      onTapUp: (_) {
                        if (!widget.isActive) return;
                        _storyController.play();
                        _storyController.previous();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Header (avatar + name + time + menu) ───────────────────────────
        Positioned(
          top: 30.h,
          right: 20.w,
          left: 20.w,
          child: _buildCustomHeader(),
        ),

        // ── Bottom (like / views) ───────────────────────────────────────────
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
      child: Align(
        alignment: AlignmentDirectional.bottomEnd,
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
                buildWhen: (prev, curr) => prev.storiesList != curr.storiesList,
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
    );
  }

  Widget _buildCustomHeader() {
    final currentStory = _currentStoryIndex < _reorderedStories.length
        ? _reorderedStories[_currentStoryIndex]
        : null;
    final bool isMine = currentStory?.isMine ?? false;

    return SafeArea(
      bottom: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar + Name + Time (tap → advisor profile)
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
                ).then((_) {
                  if (mounted && widget.isActive) _storyController.play();
                });
              },
              child: Row(
                children: [
                  HeroMode(
                    enabled: widget.isActive,
                    child: Hero(
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
                  ),
                  Gap(10.w),
                  Flexible(
                    child: Text(
                      widget.userStories.name,
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
                    getTimeAgo(context, _currentStoryTime),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        const Shadow(color: Colors.black45, blurRadius: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap(8.w),
          // Popup menu
          PopupMenuButton<String>(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            icon: Icon(Icons.more_vert, color: Colors.white, size: 32.sp),
            onOpened: () => _storyController.pause(),
            onCanceled: () {
              if (widget.isActive) _storyController.play();
            },
            onSelected: (value) async {
              if (widget.isActive) _storyController.play();
              if (currentStory == null) return;
              if (widget.isArchive) {
                final cubit = context.read<ArchivedStoriesCubit>();
                if (value == 'delete') {
                  await cubit.deleteStory(
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                  );
                } else if (value == 'unarchive') {
                  await cubit.unarchiveStory(
                    storyId: currentStory.id,
                    userId: widget.userStories.userId,
                  );
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
                  context.pushNamed(
                    AppRouter.kReportsView,
                    arguments: {
                      'type': ReportType.story,
                      'id': currentStory.id,
                    },
                  );
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
        _showViewersBottomSheet(context, currentStory).then((_) {
          if (mounted && widget.isActive) _storyController.play();
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
      enableDrag: true,
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
// Likers Bottom Sheet — draggable, paginated & profile navigation
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

  void _onScroll(ScrollController controller) {
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 100) {
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

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.25,
      maxChildSize: 0.92,
      expand: false,
      snap: true,
      snapSizes: const [0.45, 0.7, 0.92],
      builder: (context, scrollController) {
        scrollController.addListener(() => _onScroll(scrollController));
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Drag handle ──
              Padding(
                padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              // ── Title row ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 18.sp,
                      ),
                    ),
                    Gap(10.w),
                    Text(
                      context.tr('story_likers'),
                      style: Styles.textStyle16SemiBold,
                    ),
                    const Spacer(),
                    if (widget.likers.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.kprimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          '${widget.likers.length}',
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.kprimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[100]),
              // ── List ──
              Expanded(
                child: widget.likers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 48.sp,
                              color: Colors.grey[300],
                            ),
                            Gap(12.h),
                            Text(
                              context.tr('no_likers_yet'),
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.kGreyB3,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        itemCount: displayedLikers.length,
                        itemBuilder: (context, index) {
                          final user = displayedLikers[index];
                          return GestureDetector(
                            onTap: () => _navigateToProfile(context, user),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 4.h),
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 24.r,
                                        backgroundImage: NetworkImage(
                                          user.image,
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: 14.w,
                                          height: 14.w,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5.w,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.favorite,
                                            color: Colors.white,
                                            size: 8.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gap(12.w),
                                  Expanded(
                                    child: Text(
                                      user.name,
                                      style: Styles.textStyle14SemiBold,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14.sp,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
            ],
          ),
        );
      },
    );
  }
}
