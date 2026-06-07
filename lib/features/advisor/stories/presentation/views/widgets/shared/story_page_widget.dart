import 'package:story_view/story_view.dart';
import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/core/utils/story_audio_manager.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/video/story_video_preloader.dart';
import 'package:tayseer/features/advisor/stories/stories.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_bottom_section.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_custom_controller.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_gesture_layer.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_header_widget.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_image_guard.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_overlay_widgets.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_post_card.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/shared/story_video_muted.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart' hide Direction;

// ─────────────────────────────────────────────────────────────────────────────
// UserStoryPage — one user's stories: progress bar + media + overlays
// ─────────────────────────────────────────────────────────────────────────────
class UserStoryPage extends StatefulWidget {
  final UserStoriesModel userStories;
  final bool isArchive;
  final String? initialStoryId;
  final String? heroTag;
  final VoidCallback onAllStoriesComplete;
  final bool isActive;
  final bool isDragging;
  final bool newestFirst;

  const UserStoryPage({
    super.key,
    required this.userStories,
    required this.isArchive,
    this.initialStoryId,
    this.heroTag,
    required this.onAllStoriesComplete,
    this.isActive = false,
    this.isDragging = false,
    this.newestFirst = false,
  });

  @override
  State<UserStoryPage> createState() => _UserStoryPageState();
}

class _UserStoryPageState extends State<UserStoryPage> with RouteAware {
  late CustomStoryController _ctrl;
  late List<StoryModel> _stories;
  final List<StoryItem> _items = [];
  int _index = 0;
  DateTime? _storyTime;
  bool _itemsBuilt = false;
  bool _mediaReady = false;
  bool _showPostBtn = false;
  Offset? _postBtnPos;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _ctrl = CustomStoryController()..isAllowedToPlay = widget.isActive;
    _ctrl.pause();
    // Only schedule an initial pause if NOT already active.
    // When isActive=true from the start (e.g. "My Stories"), we must NOT
    // post-frame-pause again — _onMediaReady() will call play() once media
    // is ready, and a late pause would freeze the first story.
    if (!widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.pause();
      });
    } else {
      // Active from the start: mark viewed after first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _markViewed();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    videoRouteObserver.subscribe(this, ModalRoute.of(context)!);
    if (!_itemsBuilt) {
      _itemsBuilt = true;
      _buildItems();
    }
  }

  @override
  void didUpdateWidget(UserStoryPage old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _ctrl.isAllowedToPlay = true;
      if (!widget.isDragging && _mediaReady) _ctrl.play();
      _markViewed();
    }
    if (!widget.isActive && old.isActive) {
      _ctrl
        ..isAllowedToPlay = false
        ..pause();
    }
    if (widget.isDragging && !old.isDragging && widget.isActive) {
      _ctrl.pause();
    } else if (!widget.isDragging && old.isDragging && widget.isActive) {
      if (_mediaReady) _ctrl.play();
    }
  }

  /// ✅ KEY FIX: silence ALL story audio the moment another route appears.
  /// This covers: PostDetailsView, advisor profile, report screen, etc.
  @override
  void didPushNext() {
    _ctrl
      ..isAllowedToPlay = false
      ..pause();
    StoryAudioManager.instance.silenceAll();
    VideoManager.instance.stopAll();
  }

  @override
  void didPopNext() {
    if (!mounted) return;
    _ctrl.isAllowedToPlay = widget.isActive;
    if (widget.isActive && _mediaReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isActive) _ctrl.play();
      });
    }
  }

  @override
  void dispose() {
    videoRouteObserver.unsubscribe(this);
    // Silence before dispose — StoryAudioManager.clear() is called by
    // StoryDetailsView.dispose() after all pages are gone.
    _ctrl
      ..isAllowedToPlay = false
      ..pause()
      ..dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _onMediaReady() {
    if (!mounted) return;
    _mediaReady = true;
    if (widget.isActive && !widget.isDragging) _ctrl.play();
  }

  void _markViewed() {
    if (!widget.isActive || widget.isArchive || _index >= _stories.length) {
      return;
    }
    context.read<StoriesCubit>().markStoryAsViewed(
      storyId: _stories[_index].id,
      userId: widget.userStories.userId,
    );
  }

  // ── Build story items ──────────────────────────────────────────────────────

  void _buildItems() {
    final sorted = widget.userStories.stories.toList()
      ..sort(
        (a, b) => widget.newestFirst
            ? b.createdAt.compareTo(a.createdAt)
            : a.createdAt.compareTo(b.createdAt),
      );
    _stories = sorted;

    int start = 0;
    if (widget.initialStoryId != null) {
      final i = sorted.indexWhere((s) => s.id == widget.initialStoryId);
      if (i != -1) start = i;
    } else {
      final i = sorted.indexWhere((s) => !s.isViewed);
      start = i != -1 ? i : 0;
    }

    if (sorted.isNotEmpty) {
      _storyTime = sorted[start].createdAt;
      _index = start;
      // post story مع PostModel كاملة تبدأ ready مباشرة (مفيش media تتحمل)
      // post story بـ postId بس أو story عادية تستنى الـ media
      _mediaReady = sorted[start].isPostStory && sorted[start].post != null;
    }

    // ── Preload videos for this user's stories ────────────────────────────
    // Task 3.2: signal the current story index to the (userId, storyIndex) pool.
    // StoryDetailsView already called onUserVisible which seeded index-0 and
    // index-1. We fire onStoryVisible here to advance the window if needed.
    if (start < sorted.length) {
      StoryVideoPreloader.instance.onStoryVisible(start);
    }

    // ── Precache images for this user's stories via CachedNetworkImage ───────
    // CachedNetworkImage stores to disk automatically; we also warm the
    // Flutter memory cache so the image shows instantly without any flicker.
    for (final s in sorted) {
      if (!s.isPostStory && (s.video?.isEmpty ?? true) && s.image.isNotEmpty) {
        // Warm Flutter memory cache
        precacheImage(CachedNetworkImageProvider(s.image), context);
      }
    }

    final isArabic = context.isArabicLang;
    for (final s in sorted) {
      _items.add(_buildItem(s, isArabic));
    }

    if (start > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          for (var i = 0; i < start; i++) {
            _ctrl.next();
          }
        }
      });
    }
  }

  StoryItem _buildItem(StoryModel story, bool isArabic) {
    // post story مع الـ PostModel كاملة — نعرض الـ PostCard
    if (story.isPostStory && story.post != null) {
      return StoryItem(
        Transform.scale(
          scaleX: isArabic ? -1.0 : 1.0,
          child: StoryPostCard(post: story.post!, storyController: _ctrl),
        ),
        duration: const Duration(seconds: 8),
      );
    }

    // post story بـ postId بس (صورة مع postId) — نعرض الصورة عادي
    // الـ open post button هيظهر لما المستخدم يضغط على المنتصف

    final hasVideo = story.video?.isNotEmpty == true;
    final Duration dur;
    if (hasVideo && (story.videoDuration ?? 0) > 0) {
      dur = Duration(milliseconds: (story.videoDuration! * 1000).round());
    } else {
      dur = Duration(seconds: hasVideo ? 15 : 5);
    }

    final media = hasVideo
        ? StoryVideoMuted(
            key: ValueKey('video_${story.id}'),
            url: story.video!,
            storyController: _ctrl,
            onReady: _onMediaReady,
            loadingWidget: const _StoryLoader(),
            errorWidget: const _StoryLoader(),
          )
        : StoryImageGuard(
            url: story.image,
            storyController: _ctrl,
            onReady: _onMediaReady,
          );

    return StoryItem(
      Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Colors.black,
            child: Transform.scale(scaleX: isArabic ? -1.0 : 1.0, child: media),
          ),
          const IgnorePointer(child: _StoryGradientOverlay()),
        ],
      ),
      duration: dur,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isArabic = context.isArabicLang;
    final story = _index < _stories.length ? _stories[_index] : null;

    return Stack(
      children: [
        // StoryView — outer flip for Arabic RTL progress bars
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()..scale(isArabic ? -1.0 : 1.0, 1.0),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: StoryView(
              storyItems: _items,
              controller: _ctrl,
              onComplete: widget.onAllStoriesComplete,
              onStoryShow: (_, i) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    _index = i;
                    if (i < _stories.length) {
                      _storyTime = _stories[i].createdAt;
                      _mediaReady =
                          _stories[i].isPostStory && _stories[i].post != null;
                      _showPostBtn = false;
                    }
                  });
                  _markViewed();
                  // Task 3.2: notify preloader so it shifts the preload window
                  if (i < _stories.length &&
                      !_stories[i].isPostStory &&
                      _stories[i].video?.isNotEmpty == true) {
                    StoryVideoPreloader.instance.onStoryVisible(i);
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

        // 3-zone gesture layer
        Positioned.fill(
          child: StoryGestureLayer(
            isActive: widget.isActive,
            isArabic: isArabic,
            isPostStory: story?.isPostStory == true,
            showOpenPostButton: _showPostBtn,
            storyController: _ctrl,
            onShowPostButton: (pos) {
              _ctrl.pause();
              setState(() {
                _showPostBtn = true;
                _postBtnPos = pos;
              });
            },
            onDismissButton: () {
              if (_showPostBtn) {
                setState(() => _showPostBtn = false);
                if (widget.isActive) _ctrl.play();
              }
            },
          ),
        ),

        // Open-post overlay
        if (_showPostBtn && story?.isPostStory == true)
          StoryOpenPostButtonOverlay(
            position:
                _postBtnPos ??
                Offset(
                  MediaQuery.of(context).size.width / 2,
                  MediaQuery.of(context).size.height / 2,
                ),
            onTap: () {
              setState(() => _showPostBtn = false);
              _ctrl.pause();
              // ✅ Silence story audio before entering PostDetailsView
              StoryAudioManager.instance.silenceAll();
              VideoManager.instance.stopAll();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => story!.post != null
                      ? PostDetailsView(post: story.post!, isFromProfile: false)
                      : PostDetailsView(
                          isFromProfile: false,
                          postId_fromNotifc: story.postId,
                        ),
                ),
              ).then((_) {
                if (mounted && widget.isActive) _ctrl.play();
              });
            },
          ),

        // Mute button (video / reel stories only)
        if (story != null && _hasMuteBtn(story))
          Positioned(top: 120.h, right: 16.w, child: const StoryMuteButton()),

        // Header
        Positioned(
          top: 30.h,
          left: 20.w,
          right: 20.w,
          child: StoryHeaderWidget(
            userStories: widget.userStories,
            currentStory: story,
            currentStoryTime: _storyTime,
            isActive: widget.isActive,
            isArchive: widget.isArchive,
            storyController: _ctrl,
            heroTag: widget.heroTag,
          ),
        ),

        // Bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: StoryBottomSection(
            userStories: widget.userStories,
            currentStory: story,
            isActive: widget.isActive,
            isArchive: widget.isArchive,
            storyController: _ctrl,
          ),
        ),
      ],
    );
  }

  bool _hasMuteBtn(StoryModel s) =>
      (!s.isPostStory && s.video?.isNotEmpty == true) ||
      (s.isPostStory && s.post?.isReel == true);
}

// ─────────────────────────────────────────────────────────────────────────────
// Small private widgets used only inside this file
// ─────────────────────────────────────────────────────────────────────────────

class _StoryLoader extends StatelessWidget {
  const _StoryLoader();

  @override
  Widget build(BuildContext context) => const StoryLoadingRing();
}

class _StoryGradientOverlay extends StatelessWidget {
  const _StoryGradientOverlay();

  @override
  Widget build(BuildContext context) => DecoratedBox(
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
  );
}
