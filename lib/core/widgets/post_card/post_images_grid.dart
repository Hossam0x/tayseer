import 'package:flutter/services.dart';
import 'package:tayseer/core/widgets/connectivity_cached_image.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/views/image_viewer_view.dart';
import 'package:tayseer/my_import.dart';

class PostImagesGrid extends StatefulWidget {
  final List<ImageModel> images;
  final String postId;
  final PostModel? post;
  final bool isFromPostDetails;
  final PostCallbacks callbacks;
  final bool isFromProfile;
  final String? heroPrefix;

  /// Called when user wants to navigate to post details — passes current image index
  final void Function(int initialImageIndex)? onNavigateToDetails;

  /// Called whenever the carousel page changes — passes current index
  final void Function(int index)? onImageIndexChanged;

  /// Initial page index for the carousel
  final int initialImageIndex;

  const PostImagesGrid({
    super.key,
    required this.images,
    required this.postId,
    this.post,
    required this.isFromPostDetails,
    this.callbacks = const PostCallbacks(),
    required this.isFromProfile,
    this.heroPrefix,
    this.onNavigateToDetails,
    this.onImageIndexChanged,
    this.initialImageIndex = 0,
  });

  @override
  State<PostImagesGrid> createState() => _PostImagesGridState();
}

class _PostImagesGridState extends State<PostImagesGrid>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  int _currentIndex = 0;

  // Long-press drag on dots
  double _dragStartX = 0;
  int _dragStartIndex = 0;

  // Lifted state animation
  late final AnimationController _liftController;
  late final Animation<double> _liftScale;
  late final Animation<double> _liftElevation;
  bool _isLifted = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialImageIndex);
    _currentIndex = widget.initialImageIndex;

    _liftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _liftScale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _liftController, curve: Curves.easeOut));
    _liftElevation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(parent: _liftController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _liftController.dispose();
    super.dispose();
  }

  void _openGallery(int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => ImageViewerView(
          isFromProfile: widget.isFromProfile,
          images: widget.images.map((e) => e.image).toList(),
          initialIndex: index,
          postId: widget.postId,
          post: widget.post,
          isFromPostDetails: widget.isFromPostDetails,
          callbacks: widget.callbacks,
          heroPrefix: widget.heroPrefix,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _goToPage(int index) {
    final clamped = index.clamp(0, widget.images.length - 1);
    _pageController.animateToPage(
      clamped,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();
    if (widget.images.length == 1) return _buildSingleImage(context);
    return _buildCarousel(context);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🖼️ Single Image
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSingleImage(BuildContext context) {
    final image = widget.images[0];
    final maxAllowedHeight = context.responsiveHeight(500);
    final aspectRatio = image.aspectRatio.clamp(0.5, 2.5);
    final heroTag =
        '${widget.heroPrefix ?? (widget.isFromProfile ? 'profile' : 'home')}_post_${widget.postId}_img_${image.image}';

    final bool hasAncestorHero = context.findAncestorWidgetOfExactType<Hero>() != null;
    Widget content = Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: maxAllowedHeight),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ConnectivityCachedImage(
          imageUrl: image.image,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildShimmer(),
        ),
      ),
    );

    if (!hasAncestorHero) {
      content = Hero(
        tag: heroTag,
        child: content,
      );
    }

    return GestureDetector(
      onTap: () => _openGallery(0),
      child: content,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 📸 Instagram-style Carousel
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildCarousel(BuildContext context) {
    final firstAspect = widget.images[0].aspectRatio.clamp(0.5, 1.5);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final carouselHeight = (screenWidth / firstAspect).clamp(
      context.responsiveHeight(200),
      context.responsiveHeight(500),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        double adjustedCarouselHeight = carouselHeight;

        // If constrained (like in stories), ensure dots fit
        if (availableHeight.isFinite && widget.images.length > 1) {
          final dotsSpace = 12.h + 30.h; // Gap + dots/counter height
          if (adjustedCarouselHeight + dotsSpace > availableHeight) {
            adjustedCarouselHeight = (availableHeight - dotsSpace).clamp(100.h, 500.h);
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: adjustedCarouselHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                  widget.onImageIndexChanged?.call(index);
                },
                itemBuilder: (context, index) => _buildCarouselItem(context, index),
              ),
            ),
            const SizedBox(height: 8),
            _buildDotsAndCounter(),
          ],
        );
      },
    );
  }

  Widget _buildCarouselItem(BuildContext context, int index) {
    final image = widget.images[index];
    final heroTag =
        '${widget.heroPrefix ?? (widget.isFromProfile ? 'profile' : 'home')}_post_${widget.postId}_img_${image.image}';

    final bool hasAncestorHero = context.findAncestorWidgetOfExactType<Hero>() != null;

    Widget content = ConnectivityCachedImage(
      imageUrl: image.image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => _buildShimmer(),
    );

    if (!hasAncestorHero) {
      content = Hero(
        tag: heroTag,
        child: content,
      );
    }

    return GestureDetector(
      onTap: () => _openGallery(index),
      child: content,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔵 Dots + Counter
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildDotsAndCounter() {
    final total = widget.images.length;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left spacer to balance counter
          SizedBox(width: 40.w),

          // Dots — centered, with long-press drag support
          Expanded(child: Center(child: _buildDots(total))),

          // Counter: "2/10"
          SizedBox(
            width: 40.w,
            child: Text(
              '${_currentIndex + 1}/$total',
              textAlign: TextAlign.end,
              style: Styles.textStyle12.copyWith(
                color: AppColors.kGreyB3,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDots(int total) {
    // Show max 10 dots; if more → show counter only
    const maxDots = 10;
    if (total > maxDots) return const SizedBox.shrink();

    return GestureDetector(
      // Long press start → lift the container
      onLongPressStart: (details) {
        _dragStartX = details.globalPosition.dx;
        _dragStartIndex = _currentIndex;
        setState(() => _isLifted = true);
        _liftController.forward();
        HapticFeedback.mediumImpact();
      },
      // Drag while lifted → navigate between images with vibration
      onLongPressMoveUpdate: (details) {
        final delta = details.globalPosition.dx - _dragStartX;
        // Flip direction based on text direction (RTL vs LTR)
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        final directedDelta = isRtl ? -delta : delta;
        // Every 8px of drag = 1 image step
        final steps = (directedDelta / 8).round();
        final targetIndex = (_dragStartIndex + steps).clamp(
          0,
          widget.images.length - 1,
        );
        if (targetIndex != _currentIndex) {
          HapticFeedback.heavyImpact();
          _goToPage(targetIndex);
        }
      },
      // Release → drop back down
      onLongPressEnd: (_) {
        _liftController.reverse();
        setState(() => _isLifted = false);
      },
      onLongPressCancel: () {
        _liftController.reverse();
        setState(() => _isLifted = false);
      },
      child: AnimatedBuilder(
        animation: _liftController,
        builder: (context, child) {
          return Transform.scale(
            scale: _liftScale.value,
            child: Container(
              // ✅ مساحة ضغط كبيرة + padding مريح
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: _isLifted ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: _isLifted
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: _liftElevation.value * 2,
                          spreadRadius: _liftElevation.value * 0.3,
                          offset: Offset(0, -_liftElevation.value * 0.5),
                        ),
                      ]
                    : [],
              ),
              child: child,
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(total, (index) {
            final isActive = index == _currentIndex;
            return GestureDetector(
              onTap: () => _goToPage(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: isActive ? 8.w : 6.w,
                height: isActive ? 8.w : 6.w,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.kprimaryColor : AppColors.kGreyB3,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ✨ Shimmer
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }
}
