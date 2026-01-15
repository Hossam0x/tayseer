// ignore_for_file: avoid_print

import 'dart:ui';
import 'package:tayseer/core/utils/animation/fly_animation.dart';
import 'package:tayseer/core/widgets/post_card/post_actions_row.dart';
import 'package:tayseer/core/widgets/post_card/post_stats.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/home/view_model/home_state.dart';
import 'package:tayseer/features/shared/post_details/presentation/views/post_details_view.dart';
import 'package:tayseer/my_import.dart';

class ImageViewerView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String postId;
  final PostModel? post;
  final HomeCubit homeCubit;
  final bool isFromPostDetails;

  const ImageViewerView({
    super.key,
    required this.images,
    required this.initialIndex,
    required this.postId,
    this.post,
    required this.homeCubit,
    required this.isFromPostDetails,
  });

  @override
  State<ImageViewerView> createState() => _ImageViewerViewState();
}

class _ImageViewerViewState extends State<ImageViewerView>
    with SingleTickerProviderStateMixin {
  // 2. إضافة Mixin للانيميشن
  late PageController _pageController;
  late int _currentIndex;

  final ValueNotifier<bool> _showOverlaysNotifier = ValueNotifier(true);
  final GlobalKey _reactionDestinationKey = GlobalKey();

  // 3. متغيرات السحب (Drag Logic)
  double _dragY = 0.0;
  bool _isDragging = false;
  late AnimationController _resetController;
  late Animation<double> _resetAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // إعداد الانيميشن لعودة الصورة لمكانها لو السحب لم يكتمل
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _resetController.addListener(() {
      setState(() {
        _dragY = _resetAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _showOverlaysNotifier.dispose();
    _resetController.dispose();
    super.dispose();
  }

  void _onImageTap() {
    // لو بنسحب مش عايزين التاب يشتغل
    if (_isDragging) return;
    _showOverlaysNotifier.value = !_showOverlaysNotifier.value;
  }

  // 4. منطق السحب الرأسي
  void _onVerticalDragStart(DragStartDetails details) {
    _isDragging = true;
    _showOverlaysNotifier.value = false; // إخفاء القوائم عند بدء السحب
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragY += details.delta.dy;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _isDragging = false;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double threshold = screenHeight * 0.15; // 15% من الشاشة يكفي للاغلاق
    final double velocity = details.primaryVelocity ?? 0;

    // شرط الاغلاق: مسافة كبيرة أو سحب سريع
    if (_dragY.abs() > threshold || velocity.abs() > 1000) {
      Navigator.pop(context);
    } else {
      // العودة للمركز (Reset)
      _showOverlaysNotifier.value = true; // إظهار القوائم مرة أخرى
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
    // حساب الشفافية بناءً على مسافة السحب
    // كلما زاد _dragY قلت الشفافية (من 1 إلى 0)
    final double dragRatio = (_dragY.abs() / MediaQuery.of(context).size.height)
        .clamp(0.0, 1.0);
    final double backgroundOpacity = (1.0 - dragRatio * 2).clamp(0.0, 1.0);

    // حساب التصغير (Scale) مثل فيسبوك
    final double scale = (1.0 - dragRatio * 0.3).clamp(0.5, 1.0);

    return BlocProvider.value(
      value: widget.homeCubit,
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // جعلنا الخلفية شفافة عشان نتحكم فيها يدوياً
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 5. الخلفية السوداء المتغيرة الشفافية
            Container(color: Colors.black.withOpacity(backgroundOpacity)),

            // 6. المحتوى القابل للسحب (Gesture Detector Wrapper)
            GestureDetector(
              onVerticalDragStart: _onVerticalDragStart,
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: Transform.translate(
                offset: Offset(0, _dragY), // تحريك المحتوى
                child: Transform.scale(
                  scale: scale, // تصغير المحتوى
                  child: _buildImageSlider(),
                ),
              ),
            ),

            // UI Overlays (يتم اخفاؤها تماماً أثناء السحب عبر Opacity)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _isDragging ? 0.0 : 1.0, // اخفاء العناصر لو بنسحب
              child: ValueListenableBuilder<bool>(
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
                        top: showOverlays
                            ? context.responsiveHeight(120)
                            : -100,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    return PageView.builder(
      controller: _pageController,
      // physics: _isDragging ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      itemCount: widget.images.length,
      onPageChanged: (index) {
        setState(() => _currentIndex = index);
      },
      itemBuilder: (context, index) {
        final imageUrl = widget.images[index];
        return GestureDetector(
          onTap: _onImageTap,
          onDoubleTapDown: (details) =>
              _handleDoubleTap(details.globalPosition),
          child: InteractiveViewer(
            // مهم: منع التداخل بين الزوم والسحب للاغلاق
            // لو الزوم 1 (الوضع الطبيعي) نسمح بالسحب للاغلاق من الـ Parent
            onInteractionStart: (details) {
              // يمكن إضافة منطق هنا لوقف السحب الخارجي إذا بدأ الزوم
            },
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

  // ... (rest of your _buildBottomBar and other widgets remain unchanged)
  Widget _buildBottomBar(BuildContext context) {
    return BlocSelector<HomeCubit, HomeState, PostModel?>(
      selector: (state) {
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
                      onTap: () {
                        widget.isFromPostDetails
                            ? context.pop()
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailsView(
                                    post: post,
                                    postUpdatesStream: widget.homeCubit.stream
                                        .map((state) {
                                          return state.posts.firstWhere(
                                            (p) => p.postId == post.postId,
                                            orElse: () => post,
                                          );
                                        }),
                                    onReactionChanged: (postId, reactionType) {
                                      widget.homeCubit.reactToPost(
                                        postId: postId,
                                        reactionType: reactionType,
                                      );
                                    },
                                    onShareTap: (postId) {
                                      widget.homeCubit.toggleSharePost(
                                        postId: postId,
                                      );
                                    },
                                    onHashtagTap: (hashtag) {
                                      context.pushNamed(
                                        AppRouter.kAdvisorSearchView,
                                      );
                                    },
                                  ),
                                ),
                              );
                      },
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
                      onCommentTap: () => {
                        widget.isFromPostDetails
                            ? context.pop()
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailsView(
                                    post: post,
                                    postUpdatesStream: widget.homeCubit.stream
                                        .map((state) {
                                          return state.posts.firstWhere(
                                            (p) => p.postId == post.postId,
                                            orElse: () => post,
                                          );
                                        }),
                                    onReactionChanged: (postId, reactionType) {
                                      widget.homeCubit.reactToPost(
                                        postId: postId,
                                        reactionType: reactionType,
                                      );
                                    },
                                    onShareTap: (postId) {
                                      widget.homeCubit.toggleSharePost(
                                        postId: postId,
                                      );
                                    },
                                    onHashtagTap: (hashtag) {
                                      context.pushNamed(
                                        AppRouter.kAdvisorSearchView,
                                      );
                                    },
                                  ),
                                ),
                              ),
                      },
                      onShareTap: () =>
                          widget.homeCubit.toggleSharePost(postId: post.postId),
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

// ... (Header and Counter classes remain unchanged)
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
