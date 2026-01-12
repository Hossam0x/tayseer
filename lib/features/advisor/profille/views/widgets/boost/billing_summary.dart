import 'package:tayseer/my_import.dart';

class BillingSummary extends StatelessWidget {
  const BillingSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      color: AppColors.whiteCardBack,
      child: Column(
        children: [
          _billingRow('السعر', '180 ر.س'),
          _billingRow('الرسوم', '10 ر.س'),
          _billingRow('ضريبة القيمة المضافة', '20 ر.س'),
          _billingRow('الخصم', '-50 ر.س'),
          Gap(30.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي',
                style: Styles.textStyle16.copyWith(color: AppColors.secondary),
              ),
              Text(
                '180 ر.س',
                style: Styles.textStyle20Bold.copyWith(
                  color: AppColors.primary300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _billingRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Styles.textStyle16.copyWith(color: AppColors.secondary),
          ),
          Text(
            value,
            style: Styles.textStyle16.copyWith(color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}
