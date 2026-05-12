import 'dart:async';

import 'package:flutter/services.dart';
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
  });

  final List<BestAdvisorModel> advisors;
  final PaginationModel? pagination;
  final VoidCallback? onLoadMore;
  final Function(String advisorId)? onFollowTap;
  final bool isLoadingMore;

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
      margin: EdgeInsets.symmetric(vertical: 20.h),
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
                Text(
                  context.tr('expert_guidance_for_you'),
                  style: Styles.textStyle12.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Gap(16.h),
          SizedBox(
            height: 200.h,
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
        onTap: () {
          context.pushNamed(
            AppRouter.kUserProfileView,
            arguments: {'advisorId': widget.advisor.id},
          );
        },
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
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -50,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: AppColors.kprimaryColor.withValues(
                      alpha: 0.03,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      // ── Avatar ──
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.kprimaryColor.withValues(
                              alpha: 0.2,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.advisor.image ?? '',
                            width: 90.r,
                            height: 90.r,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => CircleAvatar(
                              radius: 45.r,
                              backgroundColor: Colors.grey.shade100,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            errorWidget: (_, __, ___) => CircleAvatar(
                              radius: 45.r,
                              backgroundColor: Colors.grey.shade100,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Gap(16.w),
                      // ── Details ──
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ── Name + verified badge ──
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.advisor.name ?? '',
                                    style: Styles.textStyle18.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Gap(4.w),
                                // ── Rating badge ──
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
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
                                        size: 14.sp,
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
                            Gap(4.h),
                            Text(
                              TranslationHelper.translateYearsExperienceFromString(
                                context,
                                widget.advisor.yearsOfExperience,
                              ),
                              style: Styles.textStyle14.copyWith(
                                color: AppColors.kprimaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Gap(8.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
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
                                ),
                                // ── Follow button ──
                                if (widget.onFollowTap != null)
                                  GestureDetector(
                                    onTap: _handleFollowTap,
                                    child: ScaleTransition(
                                      scale: _scaleAnim,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
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
                                                key: const ValueKey(
                                                  'following',
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 6.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        16.r,
                                                      ),
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  context.tr('following'),
                                                  style: Styles.textStyle10
                                                      .copyWith(
                                                        color: Colors
                                                            .grey
                                                            .shade600,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              )
                                            : Container(
                                                key: const ValueKey('follow'),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 12.w,
                                                  vertical: 6.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.kprimaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        16.r,
                                                      ),
                                                ),
                                                child: Text(
                                                  context.tr('follow'),
                                                  style: Styles.textStyle10
                                                      .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
