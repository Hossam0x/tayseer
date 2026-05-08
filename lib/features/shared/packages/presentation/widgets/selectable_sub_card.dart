import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/my_import.dart';

/// كارت اختيار مدة الاشتراك — يُستخدم في advisor و user (عبر toAdvisorSubModel)
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

  // ── ألوان Gold ──────────────────────────────────────────────────────────────
  static const _goldDark = Color(0xFF8B6914);
  static const _goldMid = Color(0xFFB8860B);
  static const _goldSelected = Color(0xFFF5EDD0);
  static const _goldBorder = Color(0xFFD4A017);
  static const _goldBadge = Color(0xFF7A5C10);

  // ── ألوان Elite ─────────────────────────────────────────────────────────────
  static const _eliteDark = Color(0xFF4A1A8C);
  static const _eliteMid = Color(0xFF7B3FD4);
  static const _eliteSelected = Color(0xFFEDE0FF);
  static const _eliteBorder = Color(0xFF9B59D4);
  static const _eliteBadge = Color(0xFF3D1578);

  Color get _accentDark => isGoldTheme ? _goldDark : _eliteDark;
  Color get _accentMid => isGoldTheme ? _goldMid : _eliteMid;
  Color get _selectedBg => isGoldTheme ? _goldSelected : _eliteSelected;
  Color get _borderColor => isGoldTheme ? _goldBorder : _eliteBorder;
  Color get _badgeColor => isGoldTheme ? _goldBadge : _eliteBadge;

  @override
  Widget build(BuildContext context) {
    final currency = sub.currency ?? getCurrency();

    final durationLabel = sub.isWeekly
        ? context.tr('weekly')
        : sub.isThreeMonths
        ? context.tr('three_months')
        : context.tr('monthly');

    final durationUnit = sub.isThreeMonths
        ? context.tr('months')
        : sub.isWeekly
        ? context.tr('week')
        : context.tr('month');

    final durationNumber = sub.isThreeMonths ? '3' : '1';

    final isMostPopular = index == 1 && totalCount >= 3;
    final isBestValue =
        index == totalCount - 1 && totalCount >= 2 && !isMostPopular;

    // سعر الشهر
    final num? pricePerMonth =
        sub.pricePerMonth ??
        (sub.isThreeMonths && sub.price != null
            ? sub.price! / 3
            : sub.isMonthly
            ? sub.price
            : null);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? _selectedBg : Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected ? _borderColor : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _borderColor.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── رقم + وحدة المدة ──────────────────────────────────────────
            Container(
              width: 52.w,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? _accentDark.withOpacity(0.12)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    durationNumber,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? _accentDark : Colors.white,
                      height: 1,
                    ),
                  ),
                  Gap(2.h),
                  Text(
                    durationUnit,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? _accentMid
                          : Colors.white.withOpacity(0.75),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Gap(14.w),

            // ── الاسم + الأسعار ───────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    durationLabel,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.black87 : Colors.white,
                    ),
                  ),
                  Gap(5.h),
                  // سعر الشهر (للشهري والـ 3 أشهر)
                  if (pricePerMonth != null && !sub.isWeekly)
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 11.sp,
                          color: isSelected
                              ? _accentMid
                              : Colors.white.withOpacity(0.7),
                        ),
                        Gap(3.w),
                        Text(
                          '${pricePerMonth.toStringAsFixed(0)} $currency / ${context.tr('month')}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isSelected
                                ? _accentMid
                                : Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  Gap(3.h),
                  // السعر الإجمالي
                  if (sub.price != null)
                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 11.sp,
                          color: isSelected
                              ? Colors.black54
                              : Colors.white.withOpacity(0.6),
                        ),
                        Gap(3.w),
                        Text(
                          '${context.tr('total')}: ${sub.price!.toStringAsFixed(0)} $currency',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isSelected
                                ? Colors.black54
                                : Colors.white.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      context.tr('price_not_available'),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
            ),

            // ── يمين: labels + badge التوفير + check ─────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isMostPopular)
                  _LabelBadge(
                    label: context.tr('most_popular'),
                    color: isSelected ? _accentMid : Colors.white,
                  ),
                if (isBestValue)
                  _LabelBadge(
                    label: context.tr('best_value'),
                    color: isSelected ? _accentMid : Colors.white,
                  ),
                if (sub.savePercentage != null) ...[
                  Gap(4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? _badgeColor : Colors.white24,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      context
                          .tr('save_percent')
                          .replaceAll('{percent}', '${sub.savePercentage}'),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                Gap(8.h),
                // دائرة الاختيار
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
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

// ── Label badge صغير ──────────────────────────────────────────────────────────
class _LabelBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _LabelBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10.sp,
        color: color,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
