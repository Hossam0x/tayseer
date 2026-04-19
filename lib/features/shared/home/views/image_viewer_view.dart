import 'dart:async';
import 'dart:ui';
import 'package:tayseer/core/enum/report_type.dart';
import 'package:tayseer/core/utils/animation/fly_animation.dart';
import 'package:tayseer/core/widgets/post_card/post_actions_row.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/widgets/post_card/post_stats.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Constants
// ══════════════════════════════════════════════════════════════════════════════
const _kDismissThresholdRatio = 0.15;
const _kDismissVelocity = 1000.0;
const _kDragScaleReduction = 0.3;
const _kMinDragScale = 0.5;
const _kResetDuration = Duration(milliseconds: 200);
const _kOverlayDuration = Duration(milliseconds: 300);
const _kMaxZoomScale = 4.0;
const _kZoomThreshold = 1.01;

const _kWhite20 = Color.fromRGBO(255, 255, 255, 0.2);
const _kWhite30 = Color.fromRGBO(255, 255, 255, 0.3);
const _kWhite50 = Color.fromRGBO(255, 255, 255, 0.5);
const _kBlack20 = Color.fromRGBO(0, 0, 0, 0.2);
const _kBlack30 = Color.fromRGBO(0, 0, 0, 0.3);

class ImageViewerView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String postId;
  final PostModel? post;
  final bool isFromPostDetails;
  final bool isFromProfile;

  /// Bundled callbacks for post actions
  final PostCallbacks callbacks;
  final String? heroPrefix;

  const ImageViewerView({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.postId,
    this.post,
    required this.isFromPostDetails,
    this.callbacks = const PostCallbacks(),
    required this.isFromProfile,
    this.heroPrefix,
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

  // Drag state
  final ValueNotifier<double> _dragYNotifier = ValueNotifier(0.0);
  bool _isDragging = false;
  bool _isZoomed = false;
  double _screenHeight = 0;

  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  // Stream subscription
  late PostModel? _currentPost;
  StreamSubscription<PostModel?>? _postSubscription;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentPost = widget.post;

    _postSubscription = widget.callbacks.postUpdatesStream?.listen(
      _onPostUpdated,
    );

    _resetController = AnimationController(
      vsync: this,
      duration: _kResetDuration,
    );
    _resetController.addListener(_onResetAnimation);
  }

  void _onPostUpdated(PostModel? updatedPost) {
    if (!mounted) return;

    // ✅ لو البوست اتحذف (null) -> اخرج
    if (updatedPost == null) {
      Navigator.of(context).pop();
      return;
    }

    if (updatedPost.postId == widget.postId) {
      setState(() => _currentPost = updatedPost);
    }
  }

  void _onResetAnimation() {
    _dragYNotifier.value = _resetAnimation.value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenHeight = MediaQuery.sizeOf(context).height;
  }

  @override
  void dispose() {
    _postSubscription?.cancel();
    _pageController.dispose();
    _showOverlaysNotifier.dispose();
    _dragYNotifier.dispose();
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

  // ── Dismiss callbacks (called from _ZoomableImage) ─────────────────────

  void _onDismissStart() {
    setState(() => _isDragging = true);
    _showOverlaysNotifier.value = false;
  }

  void _onDismissUpdate(double totalDragY) {
    _dragYNotifier.value = totalDragY;
  }

  void _onDismissEnd(double dragY, double velocity) {
    final threshold = _screenHeight * _kDismissThresholdRatio;

    if (dragY.abs() > threshold || velocity.abs() > _kDismissVelocity) {
      Navigator.pop(context);
      return;
    }

    _resetAnimation = Tween<double>(
      begin: dragY,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _resetController, curve: Curves.easeOut));
    _resetController.forward(from: 0);
    _showOverlaysNotifier.value = true;
    setState(() => _isDragging = false);
  }

  void _onDismissCancel() {
    _dragYNotifier.value = 0;
    _showOverlaysNotifier.value = true;
    setState(() => _isDragging = false);
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
          isFromProfile: widget.isFromProfile,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Build Methods
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background – rebuilds only on drag value change
          ValueListenableBuilder<double>(
            valueListenable: _dragYNotifier,
            builder: (context, dragY, _) {
              final ratio = (dragY.abs() / _screenHeight).clamp(0.0, 1.0);
              final opacity = (1.0 - ratio * 2).clamp(0.0, 1.0);
              return ColoredBox(color: Color.fromRGBO(0, 0, 0, opacity));
            },
          ),

          // Draggable Content – rebuilds only on drag value change
          ValueListenableBuilder<double>(
            valueListenable: _dragYNotifier,
            builder: (context, dragY, child) {
              final ratio = (dragY.abs() / _screenHeight).clamp(0.0, 1.0);
              final scale = (1.0 - ratio * _kDragScaleReduction).clamp(
                _kMinDragScale,
                1.0,
              );
              return Transform(
                transform: Matrix4.identity()
                  ..translate(0.0, dragY)
                  ..scale(scale),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: _buildImageSlider(),
          ),

          // Overlays
          _buildOverlays(),
        ],
      ),
    );
  }

  Widget _buildOverlays() {
    return AnimatedOpacity(
      duration: _kResetDuration,
      opacity: _isDragging ? 0.0 : 1.0,
      child: ValueListenableBuilder<bool>(
        valueListenable: _showOverlaysNotifier,
        builder: (context, showOverlays, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedPositioned(
                duration: _kOverlayDuration,
                top: showOverlays ? 0 : -150,
                left: 0,
                right: 0,
                child: RepaintBoundary(
                  child: _ViewerHeader(
                    postId: widget.postId,
                    currentIndex: _currentIndex,
                    totalImages: widget.images.length,
                    onClose: () => Navigator.pop(context),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _kOverlayDuration,
                top: showOverlays ? context.responsiveHeight(120) : -100,
                right: context.responsiveWidth(24),
                child: RepaintBoundary(
                  child: _GlassCounter(
                    current: _currentIndex + 1,
                    total: widget.images.length,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: _kOverlayDuration,
                bottom: showOverlays ? 0 : -200,
                left: 0,
                right: 0,
                child: RepaintBoundary(child: _buildBottomBar()),
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
      physics: _isZoomed
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
          _isZoomed = false;
        });
      },
      itemBuilder: (context, index) {
        return _ZoomableImage(
          isFromProfile: widget.isFromProfile,
          heroPrefix: widget.heroPrefix,
          imageUrl: widget.images[index],
          postId: widget.postId,
          onTap: _onImageTap,
          onZoomStatusChanged: (isZoomed) {
            if (_isZoomed != isZoomed) {
              setState(() => _isZoomed = isZoomed);
            }
          },
          onDismissStart: _onDismissStart,
          onDismissUpdate: _onDismissUpdate,
          onDismissEnd: _onDismissEnd,
          onDismissCancel: _onDismissCancel,
          onDoubleTapReaction: (tapPosition) {
            if (!_showOverlaysNotifier.value) {
              _showOverlaysNotifier.value = true;
            }
            if (canAct) {
              FlyAnimation.flyWidget(
                context: context,
                startOffset: tapPosition,
                endKey: _reactionDestinationKey,
                child: _buildFlyingHeart(),
                onComplete: () {
                  widget.callbacks.onReactionChanged?.call(
                    widget.postId,
                    ReactionType.love,
                  );
                },
              );
            }
          },
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
            color: _kBlack20,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            border: const Border(top: BorderSide(color: _kWhite30, width: 1.5)),
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
                    widget.callbacks.onReactionChanged?.call(
                      post.postId,
                      reaction,
                    );
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
// ✅ ويدجت جديد مخصص لمعالجة الزوم بشكل منفصل (Zoomable Image Widget)
// ══════════════════════════════════════════════════════════════════════════════

class _ZoomableImage extends StatefulWidget {
  final bool isFromProfile;
  final String? heroPrefix;
  final String imageUrl;
  final String postId;
  final VoidCallback onTap;
  final ValueChanged<bool> onZoomStatusChanged;
  final Function(Offset) onDoubleTapReaction;

  // Dismiss callbacks (forwarded from parent)
  final VoidCallback? onDismissStart;
  final ValueChanged<double>? onDismissUpdate;
  final void Function(double dragY, double velocity)? onDismissEnd;
  final VoidCallback? onDismissCancel;

  const _ZoomableImage({
    required this.isFromProfile,
    this.heroPrefix,
    required this.imageUrl,
    required this.postId,
    required this.onTap,
    required this.onZoomStatusChanged,
    required this.onDoubleTapReaction,
    this.onDismissStart,
    this.onDismissUpdate,
    this.onDismissEnd,
    this.onDismissCancel,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  bool _lastZoomedState = false;

  // Dismiss tracking
  bool _isDismissing = false;
  double _cumulativeDismissY = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _kResetDuration,
    );
    _animationController.addListener(_onAnimationTick);
    _transformationController.addListener(_checkZoomStatus);
  }

  void _onAnimationTick() {
    if (_animation != null) {
      _transformationController.value = _animation!.value;
    }
  }

  void _checkZoomStatus() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    final isZoomed = scale > _kZoomThreshold;
    if (isZoomed != _lastZoomedState) {
      _lastZoomedState = isZoomed;
      widget.onZoomStatusChanged(isZoomed);
    }
  }

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationTick);
    _transformationController.removeListener(_checkZoomStatus);
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_transformationController.value != Matrix4.identity()) {
      _animation =
          Matrix4Tween(
            begin: _transformationController.value,
            end: Matrix4.identity(),
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOut,
            ),
          );
      _animationController.forward(from: 0);
    } else {
      widget.onDoubleTapReaction(details.globalPosition);
    }
  }

  // ── InteractiveViewer interaction handlers ────────────────────────────

  void _onInteractionStart(ScaleStartDetails details) {
    if (details.pointerCount == 1 && !_lastZoomedState) {
      _isDismissing = true;
      _cumulativeDismissY = 0;
      widget.onDismissStart?.call();
    }
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_isDismissing) {
      if (details.pointerCount > 1) {
        // Pinch detected → cancel dismiss, let zoom take over
        _isDismissing = false;
        widget.onDismissCancel?.call();
      } else {
        _cumulativeDismissY += details.focalPointDelta.dy;
        widget.onDismissUpdate?.call(_cumulativeDismissY);
      }
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (_isDismissing) {
      _isDismissing = false;
      widget.onDismissEnd?.call(
        _cumulativeDismissY,
        details.velocity.pixelsPerSecond.dy,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: () {},
      onDoubleTapDown: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: _kMaxZoomScale,
        panEnabled: _lastZoomedState,
        onInteractionStart: _onInteractionStart,
        onInteractionUpdate: _onInteractionUpdate,
        onInteractionEnd: _onInteractionEnd,
        child: Center(
          child: Hero(
            tag:
                '${widget.heroPrefix ?? (widget.isFromProfile ? 'profile' : 'home')}_post_${widget.postId}_img_${widget.imageUrl}',
            child: CachedNetworkImage(
              imageUrl: widget.imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => const SizedBox.shrink(),
              errorWidget: (context, url, error) => const Icon(
                Icons.broken_image_outlined,
                color: _kWhite30,
                size: 48,
              ),
            ),
          ),
        ),
      ),
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
  final String postId;

  const _ViewerHeader({
    required this.currentIndex,
    required this.totalImages,
    required this.onClose,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: _kBlack20,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
            border: const Border(
              bottom: BorderSide(color: _kWhite30, width: 1.5),
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
                if (totalImages > 1 && totalImages < 15)
                  _buildDots()
                else
                  const SizedBox(),

                CustomClick(
                  onTap: () {
                    context.pushNamed(
                      AppRouter.kReportsView,
                      arguments: {'type': ReportType.post, 'id': postId},
                    );
                  },
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
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
            color: isActive ? HexColor("#AC1A37") : _kWhite50,
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
            color: _kBlack30,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: _kWhite20),
          ),
          child: Text(
            "$current/$total",
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
