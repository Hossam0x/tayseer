import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/my_import.dart';

/// كارت الترقية/التخفيض — يُستخدم في advisor و user (عبر toAdvisorSubModel)
class UpgradeSubCard extends StatelessWidget {
  final NewAdvisorSubModel sub;

  /// true → upgrade (أسهم للأعلى) | false → downgrade (أسهم للأسفل)
  final bool isUpgrade;

  const UpgradeSubCard({super.key, required this.sub, this.isUpgrade = true});

  @override
  Widget build(BuildContext context) {
    final currency = sub.currency ?? getCurrency();

    final durationLabel = sub.isWeekly
        ? context.tr('weekly')
        : sub.isThreeMonths
        ? context.tr('three_months')
        : context.tr('monthly');

    // سعر الشهر
    final num? pricePerMonth =
        sub.pricePerMonth ??
        (sub.isThreeMonths && sub.price != null
            ? sub.price! / 3
            : sub.isMonthly
            ? sub.price
            : null);

    final badgeLabel = isUpgrade
        ? context.tr('upgrade')
        : context.tr('downgrade');

    final Color accentColor = isUpgrade
        ? const Color(0xFFD97706) // amber
        : const Color(0xFF3B82F6); // blue

    final Color bgColor = isUpgrade
        ? const Color(0xFFFEF3C7)
        : const Color(0xFFEFF6FF);

    final Color borderColor = isUpgrade
        ? const Color(0xFFFBBF24)
        : const Color(0xFF93C5FD);

    final IconData arrowIcon = isUpgrade
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── أيقونة الاتجاه ────────────────────────────────────────────
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(arrowIcon, color: accentColor, size: 20.sp),
          ),
          Gap(14.w),

          // ── المعلومات ─────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      durationLabel,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Gap(8.w),
                    // badge upgrade/downgrade
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(5.h),
                // سعر الشهر
                if (pricePerMonth != null && !sub.isWeekly)
                  Text(
                    '${pricePerMonth.toStringAsFixed(0)} $currency / ${context.tr('month')}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                // السعر الإجمالي
                if (sub.price != null)
                  Text(
                    '${context.tr('total')}: ${sub.price!.toStringAsFixed(0)} $currency',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Text(
                    context.tr('price_not_available'),
                    style: TextStyle(fontSize: 12.sp, color: Colors.black45),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
