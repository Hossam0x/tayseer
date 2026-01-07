import '../../my_import.dart';

class CustomBotton extends StatelessWidget {
  const CustomBotton({
    super.key,
    required this.title,
    required this.onPressed,
    this.backGroundcolor,
    this.useGradient = false,
    this.titleColor,
    this.icon,
    this.radius = 16,
    this.width = 338,
    this.height = 50,
    this.elevation = 1,
    this.isLoading = false,
  });

  final String title;
  final Color? backGroundcolor;
  final bool useGradient;
  final Color? titleColor;
  final void Function()? onPressed;
  final Icon? icon;
  final double radius;
  final double width;
  final double height;
  final double elevation;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          backgroundColor: useGradient
              ? Colors.transparent
              : (backGroundcolor ?? AppColors.kprimaryColor),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: const CircularProgressIndicator(
                  padding: EdgeInsets.all(2),
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Ink(
                decoration: BoxDecoration(
                  gradient: useGradient ? AppColors.defaultGradient : null,
                  color: useGradient
                      ? null
                      : (backGroundcolor ?? AppColors.kprimaryColor),
                  borderRadius: BorderRadius.circular(radius),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: FittedBox(
                    child: Row(
                      mainAxisAlignment: icon == null
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.spaceEvenly,
                      children: [
                        if (icon != null) icon!,
                        if (icon != null) const SizedBox(width: 2),
                        Text(
                          title,
                          style: Styles.textStyle16Bold.copyWith(
                            color: titleColor ?? Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
