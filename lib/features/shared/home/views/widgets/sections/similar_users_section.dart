import 'package:tayseer/core/models/pagination_model.dart';
import 'package:tayseer/features/shared/home/model/similar_user_model.dart';
import 'package:tayseer/features/user/interactions/data/Model/interaction_usermodel%20.dart';
import 'package:tayseer/my_import.dart';

class SimilarUsersSection extends StatefulWidget {
  const SimilarUsersSection({
    super.key,
    required this.users,
    required this.pagination,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  final List<SimilarUserModel> users;
  final PaginationModel? pagination;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;

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
                  context.tr('similar_users'),
                  style: Styles.textStyle20.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.kprimaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  context.tr('similar_users_desc'),
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
              itemCount: widget.users.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) => _SimilarUserCard(
                user: widget.users[index],
                isSelected: _currentPage == index,
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
  const _SimilarUserCard({required this.user, required this.isSelected});

  final SimilarUserModel user;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 400),
      scale: isSelected ? 1.0 : 0.95,
      child: GestureDetector(
        onTap: () {
          context.pushNamed(
            AppRouter.kMarriageView,
            arguments: {
              'personId': user.id,
              'fromInteractions': false,
              'isFavorite': false,
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
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.kprimaryColor.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 40.r,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: user.image != null
                          ? NetworkImage(user.image!)
                          : null,
                      child: user.image == null
                          ? Icon(
                              Icons.person,
                              size: 36,
                              color: Colors.grey.shade400,
                            )
                          : null,
                    ),
                  ),
                  Gap(16.w),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.name ?? '',
                                style: Styles.textStyle16SemiBold.copyWith(
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (user.isVerified == true)
                              Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 16.sp,
                              ),
                          ],
                        ),
                        Gap(4.h),
                        Row(
                          children: [
                            if (user.age != null)
                              _Tag(label: '${user.age} ${context.tr('age')}'),
                            if (user.age != null && user.city != null) Gap(6.w),
                            if (user.city != null)
                              Flexible(child: _Tag(label: user.city!)),
                          ],
                        ),
                        Gap(8.h),
                        // Similarity score
                        if (user.similarityScore != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
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
                                  size: 12.sp,
                                ),
                                Gap(4.w),
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
