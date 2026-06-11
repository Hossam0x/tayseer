import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/core/utils/story_audio_manager.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/video/story_video_preloader.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_cubits.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/archive/archive_states.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_page_widget.dart';
// ⚠️ ADS TEMPORARILY DISABLED
// import 'package:tayseer/core/services/ad_service.dart';
// import 'package:tayseer/core/widgets/ads/interstitial_loading_overlay.dart';
import 'package:tayseer/my_import.dart' hide Direction;

/// Outer shell: drag-to-dismiss + horizontal page swipe between users.
/// All story logic lives in [UserStoryPage].
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
  late final PageController _page;
  late int _current;
  double _vOffset = 0;
  bool _isDragging = false;
  bool _isPopping = false;

  // Live list that grows as the cubit loads more stories
  late List<UserStoriesModel> _usersStories;

  // ── Ad counter ────────────────────────────────────────────────────────────
  // ⚠️ ADS TEMPORARILY DISABLED — uncomment when Google Ads account is ready.
  // Show an interstitial after every 3 complete user-story sequences.
  // ignore: unused_field
  int _completedUserStories = 0;
  // ignore: unused_field
  static const int _adEvery = 3;
  bool _adPending = false;

  @override
  void initState() {
    super.initState();
    _current = widget.initialUserIndex;
    _usersStories = List.from(widget.usersStories);
    _page = PageController(initialPage: widget.initialUserIndex);
    // Kick off preloading for the initial user and the next one
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAdjacentUserVideos(widget.initialUserIndex);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    videoRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    videoRouteObserver.unsubscribe(this);
    // ✅ Clear ALL story audio when the story screen is fully closed.
    StoryAudioManager.instance.clear();
    VideoManager.instance.stopAll();
    StoryVideoPreloader.instance.clear();
    _page.dispose();
    // Task 3.4: clear ImageCache only if it exceeds 80 MB
    final cacheBytes = PaintingBinding.instance.imageCache.currentSizeBytes;
    if (cacheBytes > 80 * 1024 * 1024) {
      PaintingBinding.instance.imageCache.clear();
      debugPrint(
        '🧹 StoryDetailsView: ImageCache cleared '
        '(was ${(cacheBytes / (1024 * 1024)).toStringAsFixed(1)} MB)',
      );
    }
    super.dispose();
  }

  @override
  void didPushNext() {
    StoryAudioManager.instance.silenceAll();
    VideoManager.instance.stopAll();
  }

  @override
  void didPopNext() {}

  @override
  Widget build(BuildContext context) {
    final opacity = (1.0 - (_vOffset / 400)).clamp(0.0, 1.0);

    // Keep _usersStories in sync with the cubit's storiesList (home feed only).
    // Skip live updates when opened for a single user (e.g. My Story / Profile)
    // to prevent the feed list from overriding the intended stories.
    final isSingleUserView =
        widget.usersStories.length == 1 &&
        widget.usersStories.first.userId == kCurrentUserData?.id;

    final body = widget.isArchive || isSingleUserView
        ? _buildBody(opacity)
        : BlocListener<StoriesCubit, StoriesState>(
            listenWhen: (prev, curr) => prev.storiesList != curr.storiesList,
            listener: (ctx, state) {
              if (!mounted) return;
              final myUserId = kCurrentUserData?.id;
              final updated = state.storiesList
                  .where((us) => us.userId != myUserId)
                  .map(
                    (us) => us.copyWith(stories: us.stories.reversed.toList()),
                  )
                  .toList();
              if (updated.length > _usersStories.length) {
                setState(() => _usersStories = updated);
              }
            },
            child: _buildBody(opacity),
          );

    if (!widget.isArchive) return body;

    return MultiBlocListener(
      listeners: [
        BlocListener<ArchivedStoriesCubit, ArchivedStoriesState>(
          listenWhen: (p, c) =>
              p.unarchiveActionState != c.unarchiveActionState ||
              p.deleteActionState != c.deleteActionState,
          listener: _onArchiveState,
        ),
      ],
      child: body,
    );
  }

  /// Preload video controllers for the current user and the next one.
  /// Uses the new (userId, storyIndex) keyed pool (Task 3.2).
  void _preloadAdjacentUserVideos(int currentIndex) {
    // Update the preloader's full user list so it knows the window
    StoryVideoPreloader.instance.preloadFromStories(_usersStories);
    // Signal which user is now visible — initialises index-0 immediately
    // and queues index-1 in the background
    StoryVideoPreloader.instance.onUserVisible(currentIndex);
  }

  void _onArchiveState(BuildContext ctx, ArchivedStoriesState s) {
    void pop() {
      if (mounted) Navigator.pop(ctx);
    }

    if (s.unarchiveActionState == CubitStates.success) {
      if (s.unarchiveMessage != null) {
        AppToast.success(ctx, ctx.tr(s.unarchiveMessage!));
      }
      ctx.read<ArchivedStoriesCubit>().resetUnarchiveStoryState();
      pop();
    } else if (s.unarchiveActionState == CubitStates.failure) {
      if (s.unarchiveMessage != null) AppToast.error(ctx, s.unarchiveMessage!);
      ctx.read<ArchivedStoriesCubit>().resetUnarchiveStoryState();
    }

    if (s.deleteActionState == CubitStates.success) {
      if (s.deleteMessage != null) {
        AppToast.success(ctx, ctx.tr(s.deleteMessage!));
      }
      ctx.read<ArchivedStoriesCubit>().resetDeleteStoryState();
      pop();
    } else if (s.deleteActionState == CubitStates.failure) {
      if (s.deleteMessage != null) AppToast.error(ctx, s.deleteMessage!);
      ctx.read<ArchivedStoriesCubit>().resetDeleteStoryState();
    }
  }

  // ── Ad helper ─────────────────────────────────────────────────────────────

  /// ⚠️ ADS TEMPORARILY DISABLED — uncomment when Google Ads account is ready.
  Future<void> _onStoriesComplete() async {
    if (_adPending) return;
    if (isGuest) return;
    _completedUserStories++;
    // Ads disabled — nothing to show.
    // if (_completedUserStories % _adEvery != 0) return;
    // final adService = getIt<AdService>();
    // if (adService.shouldSuppressAds) return;
    // if (!mounted) return;
    // _adPending = true;
    // await InterstitialLoadingOverlay.show(
    //   context,
    //   message: context.tr('ads.loading'),
    //   duration: const Duration(milliseconds: 400),
    // );
    // await adService.showInterstitial();
    // _adPending = false;
  }

  Widget _buildBody(double opacity) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Listener(
        onPointerMove: (e) {
          if (!_isDragging && e.delta.dx.abs() > e.delta.dy.abs()) return;
          setState(() {
            _vOffset = (_vOffset + e.delta.dy).clamp(0, double.infinity);
            if (_vOffset > 0) _isDragging = true;
          });
        },
        onPointerUp: (_) {
          if (_isPopping) return;
          if (_vOffset > 100) {
            _isPopping = true;
            Navigator.pop(context);
          } else {
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
                controller: _page,
                itemCount: _usersStories.length,
                onPageChanged: (i) {
                  setState(() => _current = i);
                  // Prefetch next page when reaching the last 3 users
                  if (!widget.isArchive && i >= _usersStories.length - 3) {
                    context.read<StoriesCubit>().fetchStories(
                      loadMore: true,
                      isSpecial: false,
                      context: context,
                    );
                  }
                  // Preload videos for the next user's stories
                  _preloadAdjacentUserVideos(i);
                },
                itemBuilder: (_, i) => UserStoryPage(
                  userStories: _usersStories[i],
                  isArchive: widget.isArchive,
                  heroTag: i == widget.initialUserIndex ? widget.heroTag : null,
                  initialStoryId: i == widget.initialUserIndex
                      ? widget.initialStoryId
                      : null,
                  isActive: _current == i,
                  isDragging: _isDragging,
                  newestFirst: widget.newestFirst,
                  onAllStoriesComplete: () async {
                    // Show ad every N user-story completions
                    await _onStoriesComplete();
                    if (!mounted) return;
                    if (_current < _usersStories.length - 1) {
                      _page.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else if (!_isPopping) {
                      _isPopping = true;
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
