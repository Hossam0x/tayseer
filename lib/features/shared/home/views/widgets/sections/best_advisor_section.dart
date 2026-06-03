import 'dart:async';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:tayseer/core/models/pagination_model.dart';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/utils/post_event_bus.dart';
import 'package:tayseer/features/shared/home/model/best_advisor_model.dart';
import 'package:tayseer/core/utils/translation_helper.dart';
import 'package:tayseer/my_import.dart';

class BestAdvisorSection extends StatefulWidget {
  const BestAdvisorSection({
    super.key,
    required this.advisors,
    required this.pagination,
    this.onLoadMore,
    this.onFollowTap,
    this.isLoadingMore = false,
    this.onSeeMore,
  });

  final List<BestAdvisorModel> advisors;
  final PaginationModel? pagination;
  final VoidCallback? onLoadMore;
  final Function(String advisorId)? onFollowTap;
  final bool isLoadingMore;
  final VoidCallback? onSeeMore;

  @override
  State<BestAdvisorSection> createState() => _BestAdvisorSectionState();
}

class _BestAdvisorSectionState extends State<BestAdvisorSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _precacheAdvisorImages();
  }

  void _precacheAdvisorImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final advisor in widget.advisors) {
        final url = advisor.image;
        if (url != null && url.isNotEmpty) {
          DefaultCacheManager().downloadFile(url);
        }
      }
    });
  }

  @override
  void didUpdateWidget(BestAdvisorSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.advisors != widget.advisors) {
      _precacheAdvisorImages();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);

    if (widget.advisors.isNotEmpty &&
        index >= (widget.advisors.length * 0.75).floor() &&
        widget.onLoadMore != null &&
        !widget.isLoadingMore &&
        _hasMoreData()) {
      widget.onLoadMore!();
    }
  }

  bool _hasMoreData() {
    if (widget.pagination == null) return false;
    return widget.pagination!.currentPage < widget.pagination!.totalPages;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.advisors.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('best_advisors'),
                  style: Styles.textStyle20.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.kprimaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onSeeMore,
                  child: Text(
                    context.tr('see_more'),
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.kprimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(10.h),
          SizedBox(
            height: 170.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.advisors.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _AdvisorCarouselItem(
                key: ValueKey(widget.advisors[index].id),
                advisor: widget.advisors[index],
                isSelected: _currentPage == index,
                onFollowTap: widget.onFollowTap,
              ),
            ),
          ),
          if (widget.isLoadingMore)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdvisorCarouselItem extends StatefulWidget {
  const _AdvisorCarouselItem({
    super.key,
    required this.advisor,
    required this.isSelected,
    this.onFollowTap,
  });

  final BestAdvisorModel advisor;
  final bool isSelected;
  final Function(String advisorId)? onFollowTap;
  @override
  State<_AdvisorCarouselItem> createState() => _AdvisorCarouselItemState();
}

class _AdvisorCarouselItemState extends State<_AdvisorCarouselItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late bool _isFollowing;

  // 🔔 يسمع لـ follow events من البوستات أو الـ profile
  StreamSubscription<PostEvent>? _followSub;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.advisor.isFollowing ?? false;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _subscribeToFollowEvents();
  }

  void _subscribeToFollowEvents() {
    _followSub = PostEventBus.instance.onPostEvent.listen((event) {
      if (!mounted) return;
      if (event.type != PostEventType.followToggled) return;
      if (event.advisorId != widget.advisor.id) return;
      // تجاهل الـ events اللي الكارت ده نفسه بعتها (عبر onFollowTap → HomeCubit)
      // لأن HomeCubit بيعمل optimistic update على الـ advisor model مباشرة
      // وبيبعت sourceId = 'HomeCubit' — بس هنا نسمع كل حاجة تانية (من البروفايل)
      if (event.sourceId == 'HomeCubit') return;
      setState(() => _isFollowing = event.isFollowing ?? _isFollowing);
    });
  }

  @override
  void didUpdateWidget(_AdvisorCarouselItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لما الـ HomeCubit يعمل optimistic update على الـ advisor model
    // الـ widget بيتبني من جديد بـ isFollowing الجديد
    if (oldWidget.advisor.isFollowing != widget.advisor.isFollowing) {
      _isFollowing = widget.advisor.isFollowing ?? false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _followSub?.cancel();
    super.dispose();
  }

  Future<void> _handleFollowTap() async {
    if (widget.onFollowTap == null) return;

    AudioService.instance.playFollowSound(isFollowing: !_isFollowing);
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    HapticFeedback.heavyImpact();

    await _controller.forward();
    await _controller.reverse();

    setState(() => _isFollowing = !_isFollowing);
    widget.onFollowTap!(widget.advisor.id ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 400),
      scale: widget.isSelected ? 1.0 : 0.95,
      child: GestureDetector(
        onTap: () => context.pushNamed(
          AppRouter.kUserProfileView,
          arguments: {'advisorId': widget.advisor.id},
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? AppColors.kprimaryColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ══════════════════════════════
                  // الجزء العلوي: صورة + معلومات
                  // ══════════════════════════════
                  Row(
                    children: [
                      // ── Avatar ──
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.kprimaryColor.withValues(
                              alpha: 0.25,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: widget.advisor.image ?? '',
                                memCacheWidth: 160,
                                width: 70.r,
                                height: 70.r,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => CircleAvatar(
                                  radius: 35.r,
                                  backgroundColor: Colors.grey.shade100,
                                  child: Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                errorWidget: (_, __, ___) => CircleAvatar(
                                  radius: 35.r,
                                  backgroundColor: Colors.grey.shade100,
                                  child: Icon(
                                    Icons.person,
                                    size: 32,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              if (widget.advisor.imageBlur == true)
                                Positioned.fill(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 6,
                                      sigmaY: 6,
                                    ),
                                    child: const ColoredBox(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Gap(12.w),
                      // ── Details ──
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // اسم + تقييم
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.advisor.name ?? '',
                                    style: Styles.textStyle16Bold.copyWith(
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Gap(4.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 13.sp,
                                      ),
                                      Gap(2.w),
                                      Text(
                                        widget.advisor.rate?.toString() ?? '0',
                                        style: Styles.textStyle12.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Gap(3.h),
                            // سنوات الخبرة
                            Text(
                              TranslationHelper.translateYearsExperienceFromString(
                                context,
                                widget.advisor.yearsOfExperience,
                              ),
                              style: Styles.textStyle12.copyWith(
                                color: AppColors.kprimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(3.h),
                            // subtitle
                            Text(
                              TranslationHelper.translateAdvisorSubtitle(
                                context,
                                widget.advisor.subtitle,
                              ),
                              style: Styles.textStyle12.copyWith(
                                color: Colors.grey.shade600,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Gap(20.h),

                  // ══════════════════════════════
                  // الجزء السفلي: زرارين أو follow بالكامل
                  // ══════════════════════════════
                  Row(
                    children: [
                      // ── Follow button ──
                      if (widget.onFollowTap != null)
                        Expanded(
                          child: GestureDetector(
                            onTap: _handleFollowTap,
                            child: ScaleTransition(
                              scale: _scaleAnim,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                      scale: animation,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    ),
                                child: _isFollowing
                                    ? Container(
                                        key: const ValueKey('following'),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            context.tr('following'),
                                            style: Styles.textStyle12.copyWith(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        key: const ValueKey('follow'),
                                        padding: EdgeInsets.symmetric(
                                          vertical: 8.h,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.kprimaryColor,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            context.tr('follow'),
                                            style: Styles.textStyle12.copyWith(
                                              color: AppColors.kprimaryColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      // ── Book Session button (فقط لو hasAvailableSessions == true) ──
                      if (widget.advisor.hasAvailableSessions == true) ...[
                        if (widget.onFollowTap != null) Gap(8.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.pushNamed(
                              AppRouter.kChooseSessionView,
                              arguments: {
                                'title': context.tr('book_session'),
                                'advisorId': widget.advisor.id ?? '',
                              },
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.kprimaryColor,
                                    AppColors.kprimaryColor.withValues(
                                      alpha: 0.8,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    color: Colors.white,
                                    size: 13.sp,
                                  ),
                                  Gap(4.w),
                                  Text(
                                    context.tr('book_session'),
                                    style: Styles.textStyle12.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
