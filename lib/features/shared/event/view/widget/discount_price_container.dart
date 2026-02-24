import 'package:tayseer/core/utils/helper/currency_helper.dart';
import 'package:tayseer/my_import.dart';

class DiscountPriceContainer extends StatelessWidget {
  final TextEditingController controller;
  final int discountPercentage;

  const DiscountPriceContainer({
    super.key,
    required this.controller,
    required this.discountPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final double originalPrice = double.tryParse(value.text.trim()) ?? 0;

        final double discountedPrice =
            originalPrice - (originalPrice * discountPercentage / 100);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.kWhiteColor, HexColor('fbf4f8')],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF3C6CF), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// النص التوضيحي
              Text(
                context.tr('after_application_discount'),
                style: Styles.textStyle16Bold.copyWith(color: Colors.grey.shade600),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    discountedPrice.toStringAsFixed(2),
                    style: Styles.textStyle16Bold.copyWith(
                      color: AppColors.kprimaryColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyHelper.getCurrencySymbolFromContext(context),
                    style: Styles.textStyle14Bold.copyWith(
                      color: AppColors.kprimaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
