import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/reels/view_model/cubit/reels_cubit.dart';
import 'package:tayseer/features/shared/reels/views/widget/reels_overlay.dart';
import 'package:tayseer/features/shared/reels/views/widget/reels_video_background.dart';
import 'package:tayseer/core/utils/animation/fly_animation.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReelsItem extends StatefulWidget {
  final PostModel post;
  final bool isCurrentPage;
  final bool shouldInitialize;
  final VideoPlayerController? sharedController;
  final VoidCallback? onClose;

  const ReelsItem({
    super.key,
    required this.post,
    this.isCurrentPage = true,
    this.shouldInitialize = true,
    this.sharedController,
    this.onClose,
  });

  @override
  State<ReelsItem> createState() => _ReelsItemState();
}

class _ReelsItemState extends State<ReelsItem>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  bool _isPausedByUser = false;
  bool _showIcon = false;
  Timer? _iconTimer;
  late AnimationController _iconAnimController;
  late Animation<double> _iconScaleAnim;
  VideoPlayerController? _activeController;
  final GlobalKey _likeButtonKey = GlobalKey();

  // ✅ متغيرات التسريع بالضغط المطوّل
  bool _isSpeedMode = false;
  Timer? _longPressTimer;
  Offset? _pointerDownPosition;
  static const Duration _longPressDuration = Duration(milliseconds: 400);
  static const double _moveThreshold =
      20.0; // لو الصباع اتحرك أكتر من كده، نلغي

  @override
  void initState() {
    super.initState();
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _iconScaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _iconAnimController, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(ReelsItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isCurrentPage && _isSpeedMode) {
      _stopSpeedMode();
    }
  }

  @override
  void dispose() {
    _iconTimer?.cancel();
    _longPressTimer?.cancel();
    _iconAnimController.dispose();
    if (_isSpeedMode && _activeController != null) {
      _activeController!.setPlaybackSpeed(1.0);
    }
    super.dispose();
  }

  // ═══════════════════════════════════════════════════
  // Pointer events — بيشتغل قبل أي GestureDetector
  // ═══════════════════════════════════════════════════
  void _onPointerDown(PointerDownEvent event) {
    _pointerDownPosition = event.position;
    _longPressTimer?.cancel();
    _longPressTimer = Timer(_longPressDuration, () {
      _startSpeedMode();
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_pointerDownPosition == null) return;
    final distance = (event.position - _pointerDownPosition!).distance;
    if (distance > _moveThreshold) {
      // المستخدم بيسحب (scroll) — نلغي الـ long press
      _longPressTimer?.cancel();
      if (_isSpeedMode) _stopSpeedMode();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _longPressTimer?.cancel();
    _pointerDownPosition = null;
    if (_isSpeedMode) _stopSpeedMode();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    _pointerDownPosition = null;
    if (_isSpeedMode) _stopSpeedMode();
  }

  // ═══════════════════════════════════════════════════
  // التسريع
  // ═══════════════════════════════════════════════════
  void _startSpeedMode() {
    if (!mounted) return;
    if (_isPausedByUser) return;

    final controller = _activeController;
    if (controller == null || !controller.value.isInitialized) return;
    if (!controller.value.isPlaying) return;

    setState(() => _isSpeedMode = true);
    controller.setPlaybackSpeed(2.0);
    debugPrint('⚡ Speed mode ON — 2x');
  }

  void _stopSpeedMode() {
    if (!mounted) return;
    if (!_isSpeedMode) return;

    setState(() => _isSpeedMode = false);
    _activeController?.setPlaybackSpeed(1.0);
    debugPrint('⚡ Speed mode OFF — 1x');
  }

  // ═══════════════════════════════════════════════════
  // Visibility
  // ═══════════════════════════════════════════════════
  void _handleVisibility(VisibilityInfo info) {
    if (!mounted) return;
    final isNowVisible = info.visibleFraction > 0.7;
    if (isNowVisible != _isVisible) {
      setState(() {
        _isVisible = isNowVisible;
        if (!isNowVisible) {
          _isPausedByUser = false;
          if (_isSpeedMode) _stopSpeedMode();
        }
      });
    }
  }

  // ═══════════════════════════════════════════════════
  // Play / Pause
  // ═══════════════════════════════════════════════════
  void _togglePlay() {
    if (!mounted) return;
    if (_isSpeedMode) return; // ✅ ما نعملش toggle وإحنا في وضع التسريع

    setState(() {
      _isPausedByUser = !_isPausedByUser;
      _showIcon = true;
    });

    _iconAnimController.reset();
    _iconAnimController.forward();

    _iconTimer?.cancel();
    _iconTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showIcon = false);
    });
  }

  bool get _shouldPlay => widget.isCurrentPage && !_isPausedByUser;

  // ═══════════════════════════════════════════════════
  // Double Tap — Like
  // ═══════════════════════════════════════════════════
  void _handleDoubleTap(Offset tapPosition) {
    if (!mounted) return;
    if (_isSpeedMode) return;

    FlyAnimation.flyWidget(
      context: context,
      startOffset: tapPosition,
      endKey: _likeButtonKey,
      child: _buildFlyingHeart(),
      onComplete: () {
        context.read<ReelsCubit>().reactToReel(
          postId: widget.post.postId,
          reactionType: ReactionType.love,
        );
      },
    );
  }

  Widget _buildFlyingHeart() {
    return Icon(Icons.favorite, color: Colors.red, size: 90.sp);
  }

  // ═══════════════════════════════════════════════════
  // Build
  // ═══════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('reel_${widget.post.postId}'),
      onVisibilityChanged: _handleVisibility,
      // ✅ Listener يلتقط pointer events قبل أي gesture arena
      child: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _togglePlay,
          onDoubleTapDown: canAct
              ? (details) => _handleDoubleTap(details.globalPosition)
              : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ──────────────────────────────────
              // 1. Video Background
              // ──────────────────────────────────
              RepaintBoundary(
                child: ReelsVideoBackground(
                  videoUrl: widget.post.videoUrl ?? '',
                  videoId: widget.post.postId,
                  thumbnailUrl: widget.post.videoData?.thumbnail,
                  shouldPlay: _shouldPlay,
                  shouldInitialize: widget.shouldInitialize,
                  onTap: _togglePlay,
                  onDoubleTap: canAct ? _handleDoubleTap : null,
                  showProgressBar: true,
                  sharedController: widget.sharedController,
                  onControllerCreated: (controller) {
                    _activeController = controller;
                    if (mounted) setState(() {});
                  },
                ),
              ),

              // ──────────────────────────────────
              // 2. Gradient Overlay — يختفي عند التسريع
              // ──────────────────────────────────
              AnimatedOpacity(
                opacity: _isSpeedMode ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x4D000000),
                          Colors.transparent,
                          Colors.transparent,
                          Color(0x4D000000),
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: [0.0, 0.15, 0.85, 1.0],
                      ),
                    ),
                    child: SizedBox.expand(),
                  ),
                ),
              ),

              // ──────────────────────────────────
              // 3. Play/Pause Icon — يختفي عند التسريع
              // ──────────────────────────────────
              if (_showIcon && !_isSpeedMode)
                Center(
                  child: ScaleTransition(
                    scale: _iconScaleAnim,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Icon(
                          _isPausedByUser
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: Colors.white,
                          size: 50.sp,
                        ),
                      ),
                    ),
                  ),
                ),

              // ──────────────────────────────────
              // 4. Info Overlay — يختفي عند التسريع
              // ──────────────────────────────────
              AnimatedOpacity(
                opacity: _isSpeedMode ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: IgnorePointer(
                  ignoring: _isSpeedMode,
                  child: RepaintBoundary(
                    child: BlocSelector<ReelsCubit, ReelsState, PostModel>(
                      selector: (state) {
                        return state.reelsMap[widget.post.postId] ??
                            widget.post;
                      },
                      builder: (context, currentPost) {
                        return ReelsOverlay(
                          post: currentPost,
                          cachedController: _activeController,
                          likeButtonKey: _likeButtonKey,
                          onClose: widget.onClose,
                          onReactionChanged: (ReactionType? reaction) {
                            context.read<ReelsCubit>().reactToReel(
                              postId: widget.post.postId,
                              reactionType: reaction,
                            );
                          },
                          onShareTapped: () {
                            context.read<ReelsCubit>().toggleShareReel(
                              postId: widget.post.postId,
                            );
                          },
                          onSaveTapped: () {
                            context.read<ReelsCubit>().toggleSaveReel(
                              postId: widget.post.postId,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ──────────────────────────────────
              // 5. ✅ Speed Indicator (2x)
              // ──────────────────────────────────
              if (_isSpeedMode) _buildSpeedIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedIndicator() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60.h,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fast_forward_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  '2x',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
