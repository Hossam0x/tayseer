import 'dart:ui';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:tayseer/core/models/pagination_model.dart';
import 'package:tayseer/features/shared/home/model/similar_user_model.dart';
import 'package:tayseer/features/user/interactions/data/Model/interaction_usermodel%20.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/regards_purchase_sheet.dart';
import 'package:tayseer/my_import.dart';

class SimilarUsersSection extends StatefulWidget {
  const SimilarUsersSection({
    super.key,
    required this.users,
    required this.pagination,
    this.onLoadMore,
    this.onUserVisited,
    this.isLoadingMore = false,
    this.onSeeMore,
  });

  final List<SimilarUserModel> users;
  final PaginationModel? pagination;
  final VoidCallback? onLoadMore;
  final Function(String userId)? onUserVisited;
  final bool isLoadingMore;
  final VoidCallback? onSeeMore;

  @override
  State<SimilarUsersSection> createState() => _SimilarUsersSectionState();
}

class _SimilarUsersSectionState extends State<SimilarUsersSection> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
    _precacheUserImages();
  }

  void _precacheUserImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (final user in widget.users) {
        final url = user.image;
        if (url != null && url.isNotEmpty) {
          DefaultCacheManager().downloadFile(url);
        }
      }
    });
  }

  @override
  void didUpdateWidget(SimilarUsersSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.users != widget.users) {
      _precacheUserImages();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);

    if (widget.users.isNotEmpty &&
        index >= (widget.users.length * 0.75).floor() &&
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
    if (widget.users.isEmpty) return const SizedBox.shrink();

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
                  context.tr('similar_users'),
                  style: Styles.textStyle20.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.kprimaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                if (widget.onSeeMore != null)
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
              itemCount: widget.users.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _SimilarUserCard(
                key: ValueKey(widget.users[index].id),
                user: widget.users[index],
                isSelected: _currentPage == index,
                onUserVisited: widget.onUserVisited,
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

class _SimilarUserCard extends StatelessWidget {
  const _SimilarUserCard({
    super.key,
    required this.user,
    required this.isSelected,
    this.onUserVisited,
  });

  final SimilarUserModel user;
  final bool isSelected;
  final Function(String userId)? onUserVisited;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 400),
      scale: isSelected ? 1.0 : 0.95,
      child: GestureDetector(
        onTap: () async {
          // ✅ تحقق من الاشتراك قبل الدخول على البروفايل
          final isSubscribed = getIt<InteractionsCubit>().state.isSubscribed;
          if (!isSubscribed) {
            showGoldPurchaseSheet(context);
            return;
          }

          await context.pushNamed(
            AppRouter.kMarriageView,
            arguments: {
              'personId': user.id,
              'fromInteractions': true,
              'isFavorite': false,
              'popAfterInteraction': false,
              'interactionUser': InteractionUserModel(
                userId: user.id ?? '',
                name: user.name ?? '',
                age: user.age ?? 0,
                country: user.city ?? '',
                day: '',
                job: '',
                image: user.image ?? '',
                isverified: user.isVerified ?? false,
                isImageBlurred: false,
              ),
            },
          );
          // ✅ بعد ما يرجع من البروفايل، شيل الكارت
          if (user.id != null) {
            onUserVisited?.call(user.id!);
          }
        },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: isSelected
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
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  // ── Avatar ──
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.kprimaryColor.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: user.image ?? '',
                            memCacheWidth: 140,
                            width: 70.r,
                            height: 70.r,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => CircleAvatar(
                              radius: 35.r,
                              backgroundColor: Colors.grey.shade100,
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey.shade400,
                              ),
                            ),
                            errorWidget: (_, __, ___) => CircleAvatar(
                              radius: 35.r,
                              backgroundColor: Colors.grey.shade100,
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                          if (user.imageBlur == true)
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                user.name ?? '',
                                style: Styles.textStyle16SemiBold.copyWith(
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user.isVerified == true) ...[
                              Gap(4.w),
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 15.sp,
                              ),
                            ],
                          ],
                        ),
                        Gap(4.h),
                        Row(
                          children: [
                            if (user.age != null)
                              _Tag(label: '${user.age} ${context.tr('age')}'),
                            if (user.age != null && user.city != null) Gap(5.w),
                            if (user.city != null)
                              Flexible(child: _Tag(label: user.city!)),
                          ],
                        ),
                        if (user.similarityScore != null) ...[
                          Gap(6.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flash_on_rounded,
                                  color: Colors.green,
                                  size: 11.sp,
                                ),
                                Gap(3.w),
                                Text(
                                  '${user.similarityScore}% ${context.tr('similarity')}',
                                  style: Styles.textStyle10.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: Styles.textStyle10.copyWith(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
