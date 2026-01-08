import 'package:tayseer/my_import.dart';

class CircularIconButton extends StatelessWidget {
  final String icon;
  final Color backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  const CircularIconButton({
    super.key,
    required this.icon,
    this.backgroundColor = const Color(0xFFFCE9ED),
    this.iconColor,
    this.onTap,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        // خليناه Animated عشان تغيير اللون يكون ناعم
        duration: const Duration(milliseconds: 200),
        width: context.responsiveWidth(width ?? 38),
        height: context.responsiveWidth(height ?? 38),
        padding: EdgeInsets.all(
          context.responsiveWidth((width ?? 38) > 38 ? 12 : 8),
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AppImage(
            icon,
            color: iconColor,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
