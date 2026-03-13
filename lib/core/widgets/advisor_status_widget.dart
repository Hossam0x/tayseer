import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/enum/advisor_status.dart';

class AdvisorStatusWidget extends StatelessWidget {
  const AdvisorStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String subtitle = '';
    String imageUrl = '';

    if (advisorStatus == AdvisorStatus.pending) {
      title = context.tr(AppStrings.accountUnderReview);
      subtitle = context.tr(AppStrings.accountUnderReviewMessage);
      imageUrl = AssetsData.pendingIcon;
    } else if (advisorStatus == AdvisorStatus.disapproved) {
      title = context.tr(AppStrings.cannotDoThisAction);
      subtitle = context.tr(AppStrings.accountDisApprovedMessage);
      imageUrl = AssetsData.appErrorIcon;
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppImage(imageUrl, height: 120.h, width: 120.w),
          SizedBox(height: 24.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 22.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
