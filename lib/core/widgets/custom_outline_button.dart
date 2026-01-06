
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
    this.width = 70,
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.kprimaryColor),
      ),
      // margin: const EdgeInsets.only(right: 10, left: 10, bottom: 15),
      child: InkWell(
        onTap: onTap,
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (isCorrectIcon == true || isSocialLinkButton == true)
              Icon(corectIcons, size: 20, color: AppColors.kprimaryColor),
            Expanded(
              child: Text(
                text,
                style: Styles.textStyle14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.kprimaryColor,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            if (isCorrectIcon == false || isSocialLinkButton == true)
              Icon(normalIcon, size: 20, color: AppColors.kprimaryColor),
          ],
        ),
      ),
    );
  }
}
