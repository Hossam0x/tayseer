import 'package:tayseer/features/advisor/profille/data/models/analysis_item.dart';
import 'package:tayseer/features/advisor/profille/data/models/analytics_model.dart';
import 'package:tayseer/features/advisor/profille/views/profile_visitors_view.dart';
import 'package:tayseer/my_import.dart';

class DashboardAnalysisItem extends StatelessWidget {
  final AnalysisItem item;
  final AnalyticsOverview? overview;

  const DashboardAnalysisItem({
    super.key,
    required this.item,
    required this.overview,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.isViewProfile
          ? () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileVisitorsView()),
            )
          : null,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: item.isViewProfile ? AppColors.primary50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.kWhiteColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.title,
              style: item.isViewProfile
                  ? Styles.textStyle18SemiBold.copyWith(
                      color: AppColors.blackColor,
                    )
                  : Styles.textStyle16.copyWith(color: AppColors.secondary800),
            ),
            item.isViewProfile
                ? Row(
                    children: [
                      Text(
                        overview?.visits.toString() ?? '0',
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      Gap(8.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.secondary700,
                        size: 16.sp,
                      ),
                    ],
                  )
                : Text(
                    item.subtitle,
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.primary900,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
