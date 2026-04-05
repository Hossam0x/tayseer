import 'package:tayseer/features/advisor/membership/data/models/my_subscription_model.dart';
import 'package:tayseer/my_import.dart';

class MembershipStatusBanner extends StatelessWidget {
  final MySubscriptionModel sub;

  const MembershipStatusBanner({super.key, required this.sub});

  @override
  Widget build(BuildContext context) {
    final packageName = sub.isGold ? 'Gold' : 'Elite';
    final isActive = sub.isActive && !sub.isCancelled;
    final isUltra = sub.isUltra;

    final bgColor = isUltra ? const Color(0xFFE8F1FF) : const Color(0xFFFFF8E1);
    final borderColor = isUltra
        ? AppColors.kBlueColor
        : const Color(0xFFFFB300);
    final labelColor = isUltra
        ? const Color(0xFF1A3A6B)
        : const Color(0xFF795548);
    final nameColor = isUltra ? AppColors.kBlueColor : const Color(0xFFFFB300);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            isActive
                ? context.tr('subscribed_in')
                : context.tr('subscription_ended_in'),
            style: Styles.textStyle14.copyWith(color: labelColor),
            textAlign: TextAlign.center,
          ),
          Gap(4.h),
          Text(
            packageName,
            style: Styles.textStyle20Bold.copyWith(color: nameColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
