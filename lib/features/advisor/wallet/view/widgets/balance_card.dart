import 'package:tayseer/my_import.dart';

class BalanceCard extends StatelessWidget {
  final double? customBalance;

  const BalanceCard({super.key, this.customBalance});

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'الرصيد الحالي',
            style: Styles.textStyle20.copyWith(color: AppColors.secondaryText),
          ),
          Text(
            '3250 ر.س',
            style: Styles.textStyle32Bold.copyWith(color: AppColors.primary400),
          ),
        ],
      ),
    );
  }
}
