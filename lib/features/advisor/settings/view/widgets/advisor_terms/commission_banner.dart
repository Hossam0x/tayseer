import 'package:tayseer/my_import.dart';

class CommissionBanner extends StatelessWidget {
  final double percentage;
  final bool canReduce;
  final bool isLoading;

  const CommissionBanner({
    super.key,
    required this.percentage,
    required this.canReduce,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kprimaryColor.withOpacity(0.12),
            AppColors.kprimaryColor.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.kprimaryColor.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.kprimaryColor,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                context.tr('current_commission_label'),
                style: Styles.textStyle12.copyWith(
                  color: AppColors.kprimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Gap(8.h),
          isLoading
              ? SizedBox(
                  height: 32.h,
                  width: 32.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.kprimaryColor,
                  ),
                )
              : Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: Styles.textStyle24.copyWith(
                    color: AppColors.kprimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          if (!isLoading) ...[
            Gap(6.h),
            Text(
              canReduce
                  ? context.tr('commission_reduce_hint')
                  : context.tr('commission_subscribe_hint'),
              textAlign: TextAlign.center,
              style: Styles.textStyle10.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}
