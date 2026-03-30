import 'package:tayseer/my_import.dart';

class RechargeHeader extends StatelessWidget {
  const RechargeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteCardBack,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.kWhiteColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('choose_recharge_package'),
            style: Styles.textStyle20Bold.copyWith(
              color: AppColors.primaryText,
            ),
          ),
          Gap(4.h),
          Text(
            context.tr('balance_added_after_payment'),
            style: Styles.textStyle14.copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
