import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/my_import.dart';

class SelectableSubCard extends StatelessWidget {
  final NewAdvisorSubModel sub;
  final bool isSelected;
  final VoidCallback? onTap;
  final int index;
  final int totalCount;

  /// gold → ألوان ذهبية | ultra → ألوان بنفسجية/ماسية
  final bool isGoldTheme;

  const SelectableSubCard({
    super.key,
    required this.sub,
    required this.isSelected,
    this.onTap,
    this.index = 0,
    this.totalCount = 1,
    this.isGoldTheme = true,
  });

  // ── ألوان Gold ──
  static const _goldDark = Color(0xFF8B6914);
  static const _goldMid = Color(0xFFB8860B);
  static const _goldSelected = Color(0xFFF0E8D0);
  static const _goldBorder = Color(0xFFD4A017);

  // ── ألوان Elite (بنفسجي/ماسي) ──
  static const _eliteDark = Color(0xFF4A1A8C);
  static const _eliteMid = Color(0xFF7B3FD4);
  static const _eliteSelected = Color(0xFFEDE0FF);
  static const _eliteBorder = Color(0xFF9B59D4);

  Color get _accentDark => isGoldTheme ? _goldDark : _eliteDark;
  Color get _accentMid => isGoldTheme ? _goldMid : _eliteMid;
  Color get _selectedBg => isGoldTheme ? _goldSelected : _eliteSelected;
  Color get _borderColor => isGoldTheme ? _goldBorder : _eliteBorder;

  @override
  Widget build(BuildContext context) {
    final currency = sub.currency ?? getCurrency();

    final durationLabel = sub.isWeekly
        ? context.tr('weekly')
        : sub.isThreeMonths
        ? context.tr('three_months')
        : context.tr('monthly');

    // الوحدة تحت الرقم: أسبوع، شهر، أشهر
    final durationUnit = sub.isWeekly
        ? context.tr('weekly')
        : sub.isThreeMonths
        ? context.tr('months')
        : context.tr('monthly');

    // رقم المدة: أسبوع=1، شهر=1، 3 أشهر=3
    final durationNumber = sub.isThreeMonths ? '3' : '1';

    final isMostPopular = index == 1 && totalCount >= 3;
    final isBestValue =
        index == totalCount - 1 && totalCount >= 2 && !isMostPopular;

    // سعر الشهر: للشهري هو نفس السعر، للـ 3 أشهر من الـ API، للأسبوعي لا يُعرض
    final num? pricePerMonth =
        sub.pricePerMonth ?? (sub.isMonthly ? sub.price : null);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected ? _selectedBg : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? _borderColor : Colors.white.withOpacity(0.4),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── رقم + وحدة المدة ──
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  durationNumber,
                  style: TextStyle(
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? _accentDark : Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  durationUnit,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? _accentMid
                        : Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            SizedBox(width: 14.w),

            // ── الاسم + السعر ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    durationLabel,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.black87 : Colors.white,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // سعر الشهر (للشهري والـ 3 أشهر)
                  if (pricePerMonth != null &&
                      (sub.isMonthly || sub.isThreeMonths)) ...[
                    Text(
                      '${context.tr('price_per_month')}: ${pricePerMonth.toStringAsFixed(0)} $currency',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected ? _accentMid : Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                  ],
                  // السعر الإجمالي دايماً
                  if (sub.price != null)
                    Text(
                      '${context.tr('total')}: ${sub.price!.toStringAsFixed(0)} $currency',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected
                            ? Colors.black54
                            : Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    Text(
                      context.tr('price_not_available'),
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                    ),
                ],
              ),
            ),

            // ── يمين: labels + badge التوفير + check ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMostPopular)
                  Text(
                    context.tr('most_popular'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isSelected ? _accentMid : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (isBestValue)
                  Text(
                    context.tr('best_value'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isSelected ? _accentMid : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (sub.savePercentage != null) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? _accentDark : Colors.white24,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      context
                          .tr('save_percent')
                          .replaceAll('{percent}', '${sub.savePercentage}'),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 6.h),
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? _accentDark : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? _accentDark : Colors.white54,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 13.w, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
