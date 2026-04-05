import 'package:tayseer/my_import.dart';

class SubscriptionPurchasingButton extends StatelessWidget {
  const SubscriptionPurchasingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.defaultGradient,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }
}
