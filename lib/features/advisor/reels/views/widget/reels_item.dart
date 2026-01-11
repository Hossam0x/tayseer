import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/reels/view_model/cubit/reels_cubit.dart';
import 'package:tayseer/features/advisor/reels/views/widget/reels_overlay.dart';
import 'package:tayseer/features/advisor/reels/views/widget/reels_video_background.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReelsItem extends StatefulWidget {
  final PostModel post;
  final bool isCurrentPage;
  final VideoPlayerController? sharedController;

  const ReelsItem({
    super.key,
    required this.post,
    this.isCurrentPage = true,
    this.sharedController,
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
  void dispose() {
    _iconTimer?.cancel();
    _iconAnimController.dispose();
    super.dispose();
  }

  void _handleVisibility(VisibilityInfo info) {
    if (!mounted) return;
    final isNowVisible = info.visibleFraction > 0.7;
    if (isNowVisible != _isVisible) {
      setState(() {
        _isVisible = isNowVisible;
        if (!isNowVisible) {
          // لما الفيديو يختفي، نلغي حالة التوقف اليدوي عشان لما يرجع يشتغل عادي
          _isPausedByUser = false;
        }
      });
    }
  }

  void _togglePlay() {
    if (!mounted) return;
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

  // ✅ اللوجيك هنا: يشتغل لو الصفحة دي هي اللي عليها الدور + ظاهرة + اليوزر مش موقفه
  bool get _shouldPlay => widget.isCurrentPage && !_isPausedByUser;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('reel_${widget.post.postId}'),
      onVisibilityChanged: _handleVisibility,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video Background
          ReelsVideoBackground(
            videoUrl: widget.post.videoUrl ?? '',
            shouldPlay: _shouldPlay,
            onTap: _togglePlay,
            showProgressBar: true,
            sharedController: widget.sharedController,
          ),

          // 2. Gradient Overlay
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.15, 0.85, 1.0],
                ),
              ),
            ),
          ),

          // 3. Play/Pause Animation Icon
          if (_showIcon)
            Center(
              child: ScaleTransition(
                scale: _iconScaleAnim,
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
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

          // 4. Info Overlay - Using BlocSelector to get updated post from state
          BlocSelector<ReelsCubit, ReelsState, PostModel>(
            selector: (state) {
              return state.reels.firstWhere(
                (reel) => reel.postId == widget.post.postId,
                orElse: () => widget.post,
              );
            },
            builder: (context, currentPost) {
              return ReelsOverlay(
                post: currentPost,
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
              );
            },
          ),
        ],
      ),
    );
  }
}
