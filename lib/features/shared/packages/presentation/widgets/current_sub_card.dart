import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/subscription_expiry_badge.dart';
import 'package:tayseer/my_import.dart';

/// كارت الاشتراك الحالي — يُستخدم في advisor و user (عبر toAdvisorSubModel)
class CurrentSubCard extends StatelessWidget {
  final NewAdvisorSubModel sub;
  const CurrentSubCard({super.key, required this.sub});

  @override
  Widget build(BuildContext context) {
    final currency = sub.currency ?? getCurrency();

    final durationLabel = sub.isWeekly
        ? context.tr('weekly')
        : sub.isThreeMonths
        ? context.tr('three_months')
        : context.tr('monthly');

    // سعر الشهر — للشهري هو نفس السعر، للـ 3 أشهر من الـ API
    final num? pricePerMonth =
        sub.pricePerMonth ?? (sub.isMonthly ? sub.price : null);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F2E42), Color(0xFF2D4060)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2E42).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: العنوان + badge الحالة ──────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المدة + badge "اشتراكك الحالي"
                    Row(
                      children: [
                        Text(
                          durationLabel,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Gap(8.w),
                        _CurrentBadge(),
                      ],
                    ),
                    Gap(6.h),
                    // سعر الشهر
                    if (pricePerMonth != null && !sub.isWeekly)
                      Text(
                        '${pricePerMonth.toStringAsFixed(0)} $currency / ${context.tr('month')}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withOpacity(0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    // السعر الإجمالي
                    if (sub.price != null) ...[
                      Gap(2.h),
                      Text(
                        '${context.tr('total')}: ${sub.price!.toStringAsFixed(0)} $currency',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // أيقونة الحالة
              _StatusDot(sub: sub),
            ],
          ),

          Gap(14.h),
          // ── Divider ────────────────────────────────────────────────────
          Divider(color: Colors.white.withOpacity(0.12), height: 1),
          Gap(12.h),

          // ── Row 2: badge الحالة + تاريخ الانتهاء ──────────────────────
          Row(
            children: [
              _StatusBadge(sub: sub),
              const Spacer(),
              if (sub.subscriptionExpiresAt != null)
                SubscriptionExpiryBadge(
                  expiresAt: sub.subscriptionExpiresAt!,
                  onColoredBackground: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Badge "اشتراكك الحالي" ────────────────────────────────────────────────────
class _CurrentBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Text(
        context.tr('current_subscription'),
        style: TextStyle(
          fontSize: 10.sp,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── نقطة الحالة (أيقونة صغيرة) ───────────────────────────────────────────────
class _StatusDot extends StatelessWidget {
  final NewAdvisorSubModel sub;
  const _StatusDot({required this.sub});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;

    if (sub.isActiveInApple) {
      color = const Color(0xFF22C55E);
      icon = Icons.check_circle_rounded;
    } else if (sub.isCancelledButActive) {
      color = const Color(0xFFF97316);
      icon = Icons.pause_circle_rounded;
    } else {
      color = const Color(0xFFEF4444);
      icon = Icons.cancel_rounded;
    }

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Icon(icon, color: color, size: 18.sp),
    );
  }
}

// ── Badge الحالة النصي ────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final NewAdvisorSubModel sub;
  const _StatusBadge({required this.sub});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    final String label;

    if (sub.isActiveInApple) {
      color = const Color(0xFF22C55E);
      icon = Icons.check_circle_outline_rounded;
      label = context.tr('subscription_active');
    } else if (sub.isCancelledButActive) {
      color = const Color(0xFFF97316);
      icon = Icons.pause_circle_outline_rounded;
      label = context.tr('subscription_cancelled_still_active');
    } else {
      color = const Color(0xFFEF4444);
      icon = Icons.block_rounded;
      label = context.tr('subscription_expired');
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          Gap(5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
