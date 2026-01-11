import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/my_import.dart';

class EventBottomBar extends StatelessWidget {
  const EventBottomBar({
    super.key,
    this.onBoostPressed,
    this.onEditPressed,
    required this.priceAfterDiscount,
  });
  final VoidCallback? onBoostPressed;
  final VoidCallback? onEditPressed;
  final String priceAfterDiscount;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('session_price_label'),
                  style: Styles.textStyle10,
                ),
                Text(
                  priceAfterDiscount,
                  style: Styles.textStyle18Bold.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            CustomBotton(
              width: context.width * .3,
              useGradient: true,
              onPressed: onBoostPressed,
              title: context.tr('boost_button'),
            ),
            Gap(context.responsiveWidth(12)),
            CustomOutlineButton(
              height: 50,
              isSocialLinkButton: true,
              width: context.width * .3,
              onTap: onEditPressed,
              text: context.tr('edit_button'),
            ),
          ],
        ),
      ),
    );
  }
}
