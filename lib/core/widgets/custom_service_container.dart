import 'package:tayseer/core/widgets/custom_show_dialog.dart';

import '../../my_import.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final bool hasDiscount;
  final String? discountValue;
  final String? discountImage;
  final Function()? onPressed;

  const ServiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.hasDiscount = false,
    this.discountValue,
    this.discountImage,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.kprimaryColor, Color(0xFFB0B0B0)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(3),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppImage(
                  icon,
                  // height: context.height * 0.07,
                  // width: context.width * 0.1,
                ),
                SizedBox(height: context.height * 0.0015),
                Text(
                  title,
                  style: Styles.textStyle10.copyWith(
                    color: AppColors.kprimaryColor,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),

                // ⭐ بدل Expanded
                Text(
                  description,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: Styles.textStyle10.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.height * 0.02),

                CustomBotton(
                  height: context.height * 0.045,
                  width: context.width,
                  title: 'التفاصيل',
                  onPressed: kIsUserGuest == false
                      ? onPressed
                      : () {
                          CustomshowDialog(context, islogIn: true);
                        },
                ),
              ],
            ),
          ),
        ),

        if (hasDiscount && discountImage != null)
          Positioned(
            top: -15,
            left: -10,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AppImage(discountImage!, height: 55),
                Text(
                  "$discountValue%",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class ServiceCardShimmer extends StatelessWidget {
  const ServiceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 16,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 12,
              color: Colors.grey.shade300,
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
