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
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffEB7A91).withOpacity(0.3),
              Color(0xffAC1A37).withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xff85142B)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: GradientText(text: text, style: Styles.textStyle20Bold),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isCorrectIcon || isSocialLinkButton)
                  Icon(corectIcons, size: 20, color: AppColors.kprimaryColor)
                else
                  const SizedBox(width: 20),

                if (!isCorrectIcon || isSocialLinkButton)
                  Icon(normalIcon, size: 20, color: AppColors.kprimaryColor)
                else
                  const SizedBox(width: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
