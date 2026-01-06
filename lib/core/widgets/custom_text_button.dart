
// ignore_for_file: must_be_immutable

import '../../my_import.dart';

class CustomTextButton extends StatelessWidget {
  CustomTextButton(
      {super.key,
      this.normalText,
      required this.textButton,
      required this.onPressed,
      this.spaceBetween = false,
      this.normalTextstyle,
      this.textButtonstyle,
      this.underLineTextButton = false,
      this.mainAxisAlignment = MainAxisAlignment.center});

  String? normalText;
  final String textButton;
  void Function()? onPressed;
  final bool spaceBetween;
  final TextStyle? normalTextstyle;
  final TextStyle? textButtonstyle;
  final bool underLineTextButton;
  MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: [
          Text(
            normalText ?? "",
            style: normalTextstyle ??
                Styles.textStyle14.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          if (spaceBetween == true) const Spacer(),
          TextButton(
            onPressed: onPressed,
            child: underLineTextButton
                ? Text(
                    textButton,
                    style: textButtonstyle ??
                        Styles.textStyle14.copyWith(
                          color: AppColors.kBlueColor,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                  )
                : Text(
                    textButton,
                    style: textButtonstyle ??
                        Styles.textStyle14.copyWith(
                          // color: AppColors.kBlueButtonTextColor,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kBlueColor,
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}
