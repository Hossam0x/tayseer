import 'package:tayseer/core/enum/advisor_status.dart';
import 'package:tayseer/my_import.dart';

class AdvisorStatusHomeBanner extends StatelessWidget {
  final AdvisorStatus? status;

  const AdvisorStatusHomeBanner({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (!isAdvisor) return const SliverToBoxAdapter(child: SizedBox.shrink());

    if (status != AdvisorStatus.pending &&
        status != AdvisorStatus.disapproved) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final isPending = status == AdvisorStatus.pending;

    final title = isPending
        ? context.tr(AppStrings.yourAccountUnderReview)
        : context.tr(AppStrings.yourAccountDisapproved);

    final message = isPending
        ? context.tr(AppStrings.accountUnderReviewDescription)
        : context.tr(AppStrings.accountDisapprovedDescription);

    final color = isPending ? Colors.orange : Colors.red;
    final bgColor = isPending
        ? Colors.orange.withOpacity(0.1)
        : Colors.red.withOpacity(0.1);
    final icon = isPending
        ? Icons.access_time_rounded
        : Icons.info_outline_rounded;

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    message,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: color, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
