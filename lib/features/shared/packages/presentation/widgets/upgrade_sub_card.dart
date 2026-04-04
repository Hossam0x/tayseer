import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/my_import.dart';

class UpgradeSubCard extends StatelessWidget {
  final NewAdvisorSubModel sub;
  const UpgradeSubCard({super.key, required this.sub});

  @override
  Widget build(BuildContext context) {
    final currency = sub.currency ?? getCurrency();
    final durationLabel = sub.isWeekly
        ? context.tr('weekly')
        : context.tr('monthly');
    final priceText = sub.price != null
        ? '${sub.price} $currency'
        : context.tr('price_not_available');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary200,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      durationLabel,
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: AppColors.blackColor,
                      ),
                    ),
                    Gap(8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF5C003), Color(0xFFE44E6C)],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        context.tr('upgrade'),
                        style: Styles.textStyle10.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Gap(4.h),
                Text(
                  priceText,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.secondary700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_upward_rounded,
            color: AppColors.primary600,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
