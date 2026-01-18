// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:ui';
import 'package:tayseer/core/utils/animation/fly_animation.dart';
import 'package:tayseer/core/widgets/post_card/post_actions_row.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_stats.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart';

class ImageViewerView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String postId;
  final PostModel? post;
  final bool isFromPostDetails;

  /// Bundled callbacks for post actions
  final PostCallbacks callbacks;

  const ImageViewerView({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.postId,
    this.post,
    required this.isFromPostDetails,
    this.callbacks = const PostCallbacks(),
  });

  @override
  State<ImageViewerView> createState() => _ImageViewerViewState();
}

class _ImageViewerViewState extends State<ImageViewerView>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;

  final ValueNotifier<bool> _showOverlaysNotifier = ValueNotifier(true);
  final GlobalKey _reactionDestinationKey = GlobalKey();

  // Drag variables
  double _dragY = 0.0;
  bool _isDragging = false;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  // ✅ Stream subscription (prevent memory leak)
  late PostModel? _currentPost;
  StreamSubscription<PostModel>? _postSubscription;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPost = widget.post;

    // ✅ Store subscription for cleanup
    _postSubscription = widget.callbacks.postUpdatesStream?.listen(
      _onPostUpdated,
    );

    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _resetController.addListener(_onResetAnimation);
  }

  void _onPostUpdated(PostModel updatedPost) {
    if (mounted && updatedPost.postId == widget.postId) {
      setState(() => _currentPost = updatedPost);
    }
  }

  void _onResetAnimation() {
    setState(() => _dragY = _resetAnimation.value);
  }

  @override
  void dispose() {
    _postSubscription?.cancel(); // ✅ Prevent memory leak
    _pageController.dispose();
    _showOverlaysNotifier.dispose();
    _resetController.removeListener(_onResetAnimation);
    _resetController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Gesture Handlers
  // ══════════════════════════════════════════════════════════════════════════

  void _onImageTap() {
    if (_isDragging) return;
    _showOverlaysNotifier.value = !_showOverlaysNotifier.value;
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _isDragging = true;
    _showOverlaysNotifier.value = false;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() => _dragY += details.delta.dy);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _isDragging = false;
    final screenHeight = MediaQuery.of(context).size.height;
    final threshold = screenHeight * 0.15;
    final velocity = details.primaryVelocity ?? 0;

    if (_dragY.abs() > threshold || velocity.abs() > 1000) {
      Navigator.pop(context);
    } else {
      _showOverlaysNotifier.value = true;
      _resetAnimation = Tween<double>(begin: _dragY, end: 0.0).animate(
        CurvedAnimation(parent: _resetController, curve: Curves.easeOut),
      );
      _resetController.forward(from: 0);
    }
  }

  void _handleDoubleTap(Offset tapPosition) {
    if (!_showOverlaysNotifier.value) {
      _showOverlaysNotifier.value = true;
    }
    
    FlyAnimation.flyWidget(
      context: context,
      startOffset: tapPosition,
      endKey: _reactionDestinationKey,
      child: _buildFlyingHeart(),
      onComplete: () {
        widget.callbacks.onReactionChanged?.call(widget.postId, ReactionType.love);
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Navigation
  // ══════════════════════════════════════════════════════════════════════════

  void _navigateToPostDetails(PostModel post) {
    if (widget.isFromPostDetails) {
      context.pop();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailsView(
          post: post,
          callbacks: widget.callbacks,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Build Methods
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final dragRatio = (_dragY.abs() / MediaQuery.of(context).size.height)
        .clamp(0.0, 1.0);
    final backgroundOpacity = (1.0 - dragRatio * 2).clamp(0.0, 1.0);
    final scale = (1.0 - dragRatio * 0.3).clamp(0.5, 1.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(color: Colors.black.withOpacity(backgroundOpacity)),

          // Draggable Content
          GestureDetector(
            onVerticalDragStart: _onVerticalDragStart,
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            child: Transform.translate(
              offset: Offset(0, _dragY),
              child: Transform.scale(
                scale: scale,
                child: _buildImageSlider(),
              ),
            ),
          ),

          // Overlays
          _buildOverlays(),
        ],
      ),
    );
  }

  Widget _buildOverlays() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _isDragging ? 0.0 : 1.0,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showOverlaysNotifier,
        builder: (context, showOverlays, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Header
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: showOverlays ? 0 : -150,
                left: 0,
                right: 0,
                child: _ViewerHeader(
                  currentIndex: _currentIndex,
                  totalImages: widget.images.length,
                  onClose: () => Navigator.pop(context),
                ),
              ),

              // Counter
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                top: showOverlays ? context.responsiveHeight(120) : -100,
                right: context.responsiveWidth(24),
                child: _GlassCounter(
                  current: _currentIndex + 1,
                  total: widget.images.length,
                ),
              ),

              // Bottom Bar
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                bottom: showOverlays ? 0 : -200,
                left: 0,
                right: 0,
                child: _buildBottomBar(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageSlider() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.images.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) {
        final imageUrl = widget.images[index];
        return GestureDetector(
          onTap: _onImageTap,
          onDoubleTapDown: (details) => _handleDoubleTap(details.globalPosition),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Hero(
                tag: 'post_${widget.postId}_img_$imageUrl',
                child: AppImage(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    final post = _currentPost;
    if (post == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostStats(
                  comments: post.commentsCount,
                  shares: post.sharesCount,
                  onTap: () => _navigateToPostDetails(post),
                ),
                Gap(16.h),
                PostActionsRow(
                  externalDestinationKey: _reactionDestinationKey,
                  likesCount: post.likesCount,
                  topReactions: post.topReactions,
                  myReaction: post.myReaction,
                  isRepostedByMe: post.isRepostedByMe,
                  onReactionChanged: (reaction) {
                    widget.callbacks.onReactionChanged?.call(post.postId, reaction);
                  },
                  onCommentTap: () => _navigateToPostDetails(post),
                  onShareTap: () {
                    widget.callbacks.onShareTap?.call(post.postId);
                  },
                ),
                Gap(16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlyingHeart() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: AppImage(getReactionAsset(ReactionType.love), fit: BoxFit.contain),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Header Widget
// ══════════════════════════════════════════════════════════════════════════════

class _ViewerHeader extends StatelessWidget {
  final int currentIndex;
  final int totalImages;
  final VoidCallback onClose;

  const _ViewerHeader({
    required this.currentIndex,
    required this.totalImages,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, color: Colors.white, size: 28.sp),
                ),
                if (totalImages > 1) _buildDots() else const SizedBox(),
                Icon(Icons.info_outline, color: Colors.white, size: 26.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalImages, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isActive ? 8.w : 6.w,
          height: isActive ? 8.w : 6.w,
          decoration: BoxDecoration(
            color: isActive
                ? HexColor("#AC1A37")
                : Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Counter Widget
// ══════════════════════════════════════════════════════════════════════════════

class _GlassCounter extends StatelessWidget {
  final int current;
  final int total;

  const _GlassCounter({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            "$current\\$total",
            style: Styles.textStyle14.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}