import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/subscription_expiry_badge.dart';
import 'package:tayseer/my_import.dart';

class CurrentSubCard extends StatelessWidget {
  final NewAdvisorSubModel sub;
  const CurrentSubCard({super.key, required this.sub});

  @override
  Widget build(BuildContext context) {
    final currency = sub.currency ?? getCurrency();
    final durationLabel = sub.isWeekly
        ? context.tr('weekly')
        : context.tr('monthly');
    final priceText = sub.price != null ? '${sub.price} $currency' : '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary500.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary500, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                            color: AppColors.primary600,
                          ),
                        ),
                        Gap(8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary500,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            context.tr('current_subscription'),
                            style: Styles.textStyle10.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (priceText.isNotEmpty) ...[
                      Gap(4.h),
                      Text(
                        priceText,
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.primary600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary500,
                size: 22.sp,
              ),
            ],
          ),
          if (sub.subscriptionExpiresAt != null) ...[
            Gap(10.h),
            SubscriptionExpiryBadge(expiresAt: sub.subscriptionExpiresAt!),
          ],
        ],
      ),
    );
  }
}
