import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:tayseer/core/utils/animation/fly_animation.dart';
import 'package:tayseer/core/widgets/post_card/post_actions_row.dart';
import 'package:tayseer/core/widgets/post_card/post_stats.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/home/view_model/home_state.dart';
import 'package:tayseer/my_import.dart';

class ImageViewerView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String postId;
  final PostModel? post;
  final HomeCubit homeCubit;

  const ImageViewerView({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.postId,
    this.post,
    required this.homeCubit,
  });

  @override
  State<ImageViewerView> createState() => _ImageViewerViewState();
}

class _ImageViewerViewState extends State<ImageViewerView> {
  late PageController _pageController;
  late int _currentIndex;

  // ✅ Performance: استخدام ValueNotifier لتجنب إعادة بناء الصفحة بالكامل
  final ValueNotifier<bool> _showOverlaysNotifier = ValueNotifier(true);

  final GlobalKey _reactionDestinationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _showOverlaysNotifier.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onImageTap() {
    _showOverlaysNotifier.value = !_showOverlaysNotifier.value;
  }

  void _handleDoubleTap(Offset tapPosition) {
    // 1. إظهار الأشرطة لو مخفية
    if (!_showOverlaysNotifier.value) {
      _showOverlaysNotifier.value = true;
    }

    // 2. تشغيل القلب الطائر
    FlyAnimation.flyWidget(
      context: context,
      startOffset: tapPosition,
      endKey: _reactionDestinationKey,
      child: _buildFlyingHeart(),
      onComplete: () {
        widget.homeCubit.reactToPost(
          postId: widget.postId,
          reactionType: ReactionType.love,
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.homeCubit,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Image Slider (ثابت لا يعاد بناؤه مع الأشرطة)
            _buildImageSlider(),

            // 3. UI Overlays (Header, Counter, BottomBar)
            // نستخدم ValueListenableBuilder عشان نحدث الأجزاء دي بس
            ValueListenableBuilder<bool>(
              valueListenable: _showOverlaysNotifier,
              builder: (context, showOverlays, child) {
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
                      child: _buildBottomBar(context),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // فصلنا السلايدر عشان الكود يبقى أنضف
  Widget _buildImageSlider() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.images.length,
      onPageChanged: (index) {
        // تحديث بسيط هنا (ممكن نستخدم Notifier للاندكس لو عايزين نمنع الـ setState هنا كمان، بس مقبول هنا)
        setState(() => _currentIndex = index);
      },
      itemBuilder: (context, index) {
        final imageUrl = widget.images[index];
        return GestureDetector(
          onTap: _onImageTap,
          onDoubleTapDown: (details) =>
              _handleDoubleTap(details.globalPosition),
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

  Widget _buildBottomBar(BuildContext context) {
    return BlocSelector<HomeCubit, HomeState, PostModel?>(
      selector: (state) {
        // Safe selection using collection logic manually
        try {
          return state.posts.firstWhere((p) => p.postId == widget.postId);
        } catch (_) {
          return widget.post;
        }
      },
      builder: (context, post) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PostStats(
                      comments: post.commentsCount,
                      shares: post.sharesCount,
                    ),
                    Gap(16.h),
                    PostActionsRow(
                      externalDestinationKey: _reactionDestinationKey,
                      likesCount: post.likesCount,
                      topReactions: post.topReactions,
                      myReaction: post.myReaction,
                      isRepostedByMe: post.isRepostedByMe,
                      onReactionChanged: (reaction) {
                        widget.homeCubit.reactToPost(
                          postId: post.postId,
                          reactionType: reaction,
                        );
                      },
                      onCommentTap: () => print("Open Comments"),
                    ),
                    Gap(16.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 📌 فصلنا الهيدر في ويدجت مستقلة
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
                if (totalImages > 1)
                  Row(
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
                  )
                else
                  const SizedBox(),
                Icon(Icons.info_outline, color: Colors.white, size: 26.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 📌 فصلنا العداد في ويدجت مستقلة
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
