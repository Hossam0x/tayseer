import 'package:tayseer/my_import.dart';

class UpgradeButtonSliver extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const UpgradeButtonSliver({
    super.key,
    required this.onPressed,
    this.text = "upgrade_button",
    this.margin,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: margin ?? EdgeInsets.symmetric(horizontal: 50.w),
        child: UpgradeButton(
          onPressed: onPressed,
          text: context.tr(text),
          width: width,
          height: height,
          padding: padding,
        ),
      ),
    );
  }
}

class UpgradeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const UpgradeButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: width ?? double.infinity,
        height: height ?? 56.h,
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(245, 192, 3, 1),
              Color.fromRGBO(228, 78, 108, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.boostIcon, width: 26.w, height: 26.h),
            Gap(12.w),
            Text(
              text,
              style: Styles.textStyle20SemiBold.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
