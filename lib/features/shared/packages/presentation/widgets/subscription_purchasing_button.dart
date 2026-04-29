import 'package:tayseer/my_import.dart';

class SubscriptionPurchasingButton extends StatelessWidget {
  final Color? backgroundColor;
  final double? borderRadius;

  const SubscriptionPurchasingButton({
    super.key,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 28.r;
    final bgColor = backgroundColor;

    return Container(
      height: 54.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        gradient: bgColor == null ? AppColors.defaultGradient : null,
        borderRadius: BorderRadius.circular(radius),
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
