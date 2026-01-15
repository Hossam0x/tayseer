import 'package:intl/intl.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/shared_empty_state.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/ratings_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RatingsTab extends StatelessWidget {
  const RatingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RatingsCubit>(
      create: (_) => getIt<RatingsCubit>(),
      child: const _RatingsTabContent(),
    );
  }
}

class _RatingsTabContent extends StatelessWidget {
  const _RatingsTabContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RatingsCubit, RatingsState>(
      builder: (context, state) {
        switch (state.state) {
          case CubitStates.loading:
            return _buildSkeletonRatings();
          case CubitStates.failure:
            return _buildErrorRatings(context, state.errorMessage);
          case CubitStates.success:
            if (state.ratings.isEmpty) {
              return const SharedEmptyState(title: "لا توجد تقييمات");
            }
            return _buildRatingsContent(context, state);
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSkeletonRatings() {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: [
            // Summary skeleton
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  Gap(16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.grey.shade400,
                            ),
                            width: 60.w,
                            height: 30.h,
                          ),
                          Gap(8.h),
                          Container(
                            width: 100.w,
                            height: 15.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Gap(8.h),
                          Container(
                            width: 80.w,
                            height: 15.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      Gap(24.w),
                      Expanded(
                        child: Column(
                          children: List.generate(
                            5,
                            (index) => Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: Row(
                                children: [
                                  Container(
                                    width: 20.w,
                                    height: 15.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  Gap(12.w),
                                  Expanded(
                                    child: Container(
                                      height: 8.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ),
                                  Gap(12.w),
                                  Container(
                                    width: 60.w,
                                    height: 15.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.r),
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
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
            Gap(20.h),
            // Ratings list skeleton
            ...List.generate(
              3,
              (index) => Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60.r,
                      height: 60.r,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Gap(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 100.w,
                                height: 20.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              Container(
                                width: 80.w,
                                height: 15.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          Gap(12.h),
                          Container(
                            width: double.infinity,
                            height: 80.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorRatings(BuildContext context, String? errorMessage) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.kRedColor, size: 48.w),
          Gap(16.h),
          Text(
            errorMessage ?? 'حدث خطأ في تحميل التقييمات',
            style: Styles.textStyle16.copyWith(color: AppColors.kRedColor),
            textAlign: TextAlign.center,
          ),
          Gap(24.h),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.kprimaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            onPressed: () => context.read<RatingsCubit>().refresh(),
            child: Text(
              'إعادة المحاولة',
              style: Styles.textStyle14Meduim.copyWith(
                color: AppColors.kWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingsContent(BuildContext context, RatingsState state) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        children: [
          // قسم الإحصائيات العلوي
          _buildSummarySection(state),

          Gap(20.h),

          // قائمة التقييمات
          _buildRatingsList(context, state),

          // زر تحميل المزيد (إذا كان هناك المزيد)
          if (state.hasMore) _buildLoadMoreButton(context, state),
        ],
      ),
    );
  }

  Widget _buildSummarySection(RatingsState state) {
    final starsBreakdown = state.starsBreakdown;
    final maxStarCount = starsBreakdown[5] ?? 1; // لتجنب القسمة على صفر

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Gap(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // التقييم الكبير على اليمين
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    state.averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Gap(4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Icon(
                          Icons.star,
                          size: 20.sp,
                          color: AppColors.primary400,
                        ),
                      ),
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    '${state.totalRatings} تقييم',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  Gap(8.h),
                ],
              ),
              Gap(24.w),
              // البارات والأرقام
              Expanded(
                child: Column(
                  children: [
                    for (int i = 5; i >= 1; i--)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
                            // النجوم والرقم
                            Row(
                              children: [
                                Text(
                                  '$i',
                                  style: Styles.textStyle14.copyWith(
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                Gap(4.w),
                                Icon(
                                  Icons.star,
                                  size: 16.sp,
                                  color: AppColors.primary400,
                                ),
                              ],
                            ),
                            Gap(12.w),
                            // شريط التقدم
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: LinearProgressIndicator(
                                  value:
                                      (starsBreakdown[i] ?? 0) / maxStarCount,
                                  backgroundColor: AppColors.barGreyColor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary400,
                                  ),
                                  minHeight: 8.h,
                                ),
                              ),
                            ),
                            Gap(12.w),
                            // النسبة والنص
                            Text(
                              starsBreakdown[i] == 0
                                  ? 'لا يوجد'
                                  : '${starsBreakdown[i]} تقييم',
                              style: Styles.textStyle12.copyWith(
                                color: AppColors.primaryText,
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
        ],
      ),
    );
  }

  Widget _buildRatingsList(BuildContext context, RatingsState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.ratings.length,
      separatorBuilder: (context, index) => Gap(16.h),
      itemBuilder: (context, index) {
        final rating = state.ratings[index];

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المستخدم
              SizedBox(
                width: 60.r,
                height: 60.r,
                child: CircleAvatar(
                  backgroundImage: rating.user.image != null
                      ? NetworkImage(rating.user.image!)
                      : null,
                  child: rating.user.image == null
                      ? Icon(
                          Icons.person,
                          color: AppColors.hintText,
                          size: 24.sp,
                        )
                      : null,
                ),
              ),
              Gap(12.w),
              // محتوى التقييم
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (الاسم + التاريخ)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          rating.user.name ?? 'مستخدم',
                          style: Styles.textStyle16Bold.copyWith(
                            color: AppColors.primaryText,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          _formatDate(rating.createdAt),
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                    Gap(8.h),
                    // النجوم
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                        5,
                        (starIndex) => Padding(
                          padding: EdgeInsets.only(left: 2.w),
                          child: Icon(
                            starIndex < rating.rating
                                ? Icons.star
                                : Icons.star_border,
                            size: 18.sp,
                            color: AppColors.primary400,
                          ),
                        ),
                      ),
                    ),
                    Gap(12.h),
                    // نص التقييم
                    Text(
                      rating.review,
                      textAlign: TextAlign.right,
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreButton(BuildContext context, RatingsState state) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: SizedBox(
        width: double.infinity,
        child: state.isLoadingMore
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.kprimaryColor,
                ),
              )
            : OutlinedButton(
                onPressed: () => _loadMoreRatings(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.kprimaryColor, width: 1.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'تحميل المزيد من التقييمات',
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.kprimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      // 1️⃣ parse التاريخ بصيغته الصح
      final parsedDate = DateFormat(
        'M/d/yyyy, hh:mm:ss a',
        'en',
      ).parse(dateString);

      // 2️⃣ عرضه بالعربي ومن غير وقت
      return DateFormat('dd MMMM yyyy', 'ar').format(parsedDate);
    } catch (e) {
      return dateString;
    }
  }

  void _loadMoreRatings(BuildContext context) {
    context.read<RatingsCubit>().fetchRatings(loadMore: true);
  }
}
