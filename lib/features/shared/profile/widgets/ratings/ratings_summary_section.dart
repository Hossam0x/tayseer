import 'package:tayseer/features/shared/profile/cubit/ratings/ratings_state.dart';
import 'package:tayseer/my_import.dart';

class RatingsSummarySection extends StatelessWidget {
  final RatingsState state;

  const RatingsSummarySection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final starsBreakdown = state.starsBreakdown;
    final maxStarCount = starsBreakdown[5] ?? 0;
    final safeMaxStarCount = maxStarCount > 0 ? maxStarCount : 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Gap(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RatingsAverageColumn(state: state),
              Gap(24.w),
              Expanded(
                child: _RatingsStarBars(
                  starsBreakdown: starsBreakdown,
                  safeMaxStarCount: safeMaxStarCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RatingsAverageColumn extends StatelessWidget {
  final RatingsState state;

  const _RatingsAverageColumn({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          '${state.totalRatings} ${context.tr('reviews')}',
          style: Styles.textStyle14.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
        Gap(8.h),
      ],
    );
  }
}

class _RatingsStarBars extends StatelessWidget {
  final Map<int, int> starsBreakdown;
  final int safeMaxStarCount;

  const _RatingsStarBars({
    required this.starsBreakdown,
    required this.safeMaxStarCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 5; i >= 1; i--)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _StarBarRow(
              starCount: i,
              count: starsBreakdown[i] ?? 0,
              safeMaxStarCount: safeMaxStarCount,
            ),
          ),
      ],
    );
  }
}

class _StarBarRow extends StatelessWidget {
  final int starCount;
  final int count;
  final int safeMaxStarCount;

  const _StarBarRow({
    required this.starCount,
    required this.count,
    required this.safeMaxStarCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Row(
          children: [
            Text(
              '$starCount',
              style: Styles.textStyle14.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            Gap(4.w),
            Icon(Icons.star, size: 16.sp, color: AppColors.primary400),
          ],
        ),
        Gap(12.w),
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: safeMaxStarCount > 0 ? count / safeMaxStarCount : 0,
              backgroundColor: AppColors.barGreyColor,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary400),
              minHeight: 8.h,
            ),
          ),
        ),
        Gap(12.w),
        Text(
          count == 0 ? '' : '$count ${context.tr('reviews')}',
          style: Styles.textStyle12.copyWith(color: AppColors.primaryText),
        ),
      ],
    );
  }
}
