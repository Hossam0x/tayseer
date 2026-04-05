import 'package:tayseer/my_import.dart';

class SubscriptionExpiryBadge extends StatelessWidget {
  final String expiresAt;
  const SubscriptionExpiryBadge({super.key, required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final expiry = DateTime.tryParse(expiresAt)?.toLocal();
    if (expiry == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final diff = expiry.difference(now);
    final daysLeft = diff.inDays;

    final Color badgeColor;
    final String timeText;

    if (diff.isNegative) {
      timeText = context.tr('subscription_expired');
      badgeColor = Colors.red.shade400;
    } else if (daysLeft == 0) {
      timeText = context.tr('expires_today');
      badgeColor = Colors.orange.shade400;
    } else if (daysLeft <= 3) {
      timeText = '${context.tr('expires_in')} $daysLeft ${context.tr('days')}';
      badgeColor = Colors.orange.shade400;
    } else {
      timeText = '${context.tr('expires_in')} $daysLeft ${context.tr('days')}';
      badgeColor = AppColors.primary500;
    }

    final day = expiry.day.toString().padLeft(2, '0');
    final month = expiry.month.toString().padLeft(2, '0');
    final dateStr = '$day/$month/${expiry.year}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: badgeColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 14.sp, color: badgeColor),
          Gap(6.w),
          Text(
            '$timeText  •  $dateStr',
            style: Styles.textStyle12SemiBold.copyWith(color: badgeColor),
          ),
        ],
      ),
    );
  }
}
