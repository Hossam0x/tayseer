import '../../my_import.dart';

// ignore: must_be_immutable
class CustomOutlineButton extends StatelessWidget {
  CustomOutlineButton({
    super.key,
    required this.text,
    this.textColor,
    this.corectIcons,
    this.normalIcon,
    this.onTap,
    this.isCorrectIcon = false,
    this.isSocialLinkButton = false,
    this.height = 60,
    this.width = 100,
  });

  final String text;
  final Color? textColor;
  final IconData? corectIcons;
  final IconData? normalIcon;
  void Function()? onTap;
  final bool isCorrectIcon;
  final bool isSocialLinkButton;
  final double? height;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.kprimaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.kprimaryTextColor),
      ),
      // margin: const EdgeInsets.only(right: 10, left: 10, bottom: 15),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: (corectIcons == null && normalIcon == null)
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceBetween,
          children: [
            if (corectIcons != null)
              Icon(corectIcons, size: 20, color: AppColors.kprimaryColor),

            Text(
              text,
              style: Styles.textStyle14.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.kprimaryTextColor,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),

            if (normalIcon != null)
              Icon(normalIcon, size: 20, color: AppColors.kprimaryColor),
          ],
        ),
      ),
    );
  }
}
