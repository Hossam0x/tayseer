import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/enum/advisor_status.dart';

class AdvisorStatusWidget extends StatelessWidget {
  const AdvisorStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (prev, curr) =>
          prev.currentAdvisorStatus != curr.currentAdvisorStatus,
      builder: (context, homeState) {
        final status = homeState.currentAdvisorStatus ?? advisorStatus;
        return _buildContent(context, status);
      },
    );
  }

  Widget _buildContent(BuildContext context, AdvisorStatus? status) {
    String title = '';
    String subtitle = '';
    String imageUrl = '';
    bool showContactSupport = false;

    if (status == AdvisorStatus.pending) {
      title = context.tr(AppStrings.accountUnderReview);
      subtitle = context.tr(AppStrings.accountUnderReviewMessage);
      imageUrl = AssetsData.pendingIcon;
    } else if (status == AdvisorStatus.disapproved) {
      title = context.tr(AppStrings.contentNotAvailable);
      subtitle = context.tr(AppStrings.accountDisApprovedMessage);
      imageUrl = AssetsData.appErrorIcon;
      showContactSupport = true;
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
          if (showContactSupport) ...[
            SizedBox(height: 24.h),
            CustomBotton(
              title: context.tr(AppStrings.contactSupport),
              onPressed: () => context.pushNamed(AppRouter.kHelpSupportView),
              width: double.infinity,
              height: 50.h,
              useGradient: true,
            ),
          ],
        ],
      ),
    );
  }
}
