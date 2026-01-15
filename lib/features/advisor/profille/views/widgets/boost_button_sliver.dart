import 'package:tayseer/my_import.dart';

class BoostButtonSliver extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const BoostButtonSliver({
    super.key,
    required this.onPressed,
    this.text = "تعزيز",
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
        child: BoostButton(
          onPressed: onPressed,
          text: text,
          width: width,
          height: height,
          padding: padding,
        ),
      ),
    );
  }
}

class BoostButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const BoostButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.height,
    this.padding,
  });

  @override
  State<BoostButton> createState() => _BoostButtonState();
}

class _BoostButtonState extends State<BoostButton> {
  // bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTapDown: (_) => setState(() => _isPressed = true),
      // onTapUp: (_) => setState(() => _isPressed = false),
      // onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width ?? double.infinity,
        height: widget.height ?? 56.h,
        padding:
            widget.padding ??
            EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: const [
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
              widget.text,
              style: Styles.textStyle20SemiBold.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
