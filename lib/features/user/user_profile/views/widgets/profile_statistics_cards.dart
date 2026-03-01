import 'package:tayseer/my_import.dart';

class ProfileStatisticsCards extends StatelessWidget {
  final int upgradesCount;
  final int resultsCount;
  final VoidCallback? onUpgradesTap;
  final VoidCallback? onResultsTap;

  const ProfileStatisticsCards({
    super.key,
    required this.upgradesCount,
    required this.resultsCount,
    this.onUpgradesTap,
    this.onResultsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: IntrinsicHeight(  // ✅ lets both cards match height dynamically
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ⭐ Right Card - Upgrades (Remaining likes count)
            Expanded(
              child: _buildStatCard(
                context: context,
                number: upgradesCount,
                title: context.tr('remaining_likes_count'),
                description: context.tr('go_unlimited_with_effort'),
                buttonText: context.tr('upgrade'),
                onTap: onUpgradesTap,
              ),
            ),
            SizedBox(width: 12.w),
            // ⭐ Left Card - Results (Greeting)
            Expanded(
              child: _buildStatCard(
                context: context,
                number: resultsCount,
                title: context.tr('greeting'),
                description: context.tr('get_free_credit_daily_with_gold'),
                buttonText: context.tr('upgrade'),
                onTap: onResultsTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildStatCard({
    required BuildContext context,
    required int number,
    required String title,
    required String description,
    required String buttonText,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primary50.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.primary100.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max, // ✅ يملأ الارتفاع الكامل
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ⭐ Number
          Text(
            '$number',
            textAlign: TextAlign.start,
            style: Styles.textStyle32Bold.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          // ⭐ Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: Styles.textStyle16Meduim,
          ),
          SizedBox(height: 8.h),
          // ⭐ Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: Styles.textStyle12SemiBold.copyWith(
              color: AppColors.secondary400,
            ),
          ),
          Expanded(child: SizedBox()), // ✅ يدفع الزر للأسفل
          SizedBox(height: 12.h),
          CustomBotton(title: buttonText, height: 48.h, onPressed: onTap),
        ],
      ),
    );
  }
}