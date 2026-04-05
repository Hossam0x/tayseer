import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tayseer/core/utils/styles.dart';

/// زرار الأكشن (Delete / Report / Block)
class SlidableActionButton extends StatelessWidget {
  final String? svgIcon;
  final IconData? icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const SlidableActionButton({
    super.key,
    this.svgIcon,
    this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildIcon(
              svgIcon: svgIcon,
              icon: icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 4),
            buildLabel(
              label: label,
              color: color,
              fontSize: 9,
            ),
          ],
        ),
      ),
    );
  }

  /// Build icon widget (SVG or Icon)
  static Widget buildIcon({
    String? svgIcon,
    IconData? icon,
    required Color color,
    required double size,
  }) {
    if (svgIcon != null) {
      return SvgPicture.asset(
        svgIcon,
        height: size,
        width: size,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } else if (icon != null) {
      return Icon(icon, size: size, color: color);
    }
    return const SizedBox.shrink();
  }

  /// Build label widget
  static Widget buildLabel({
    required String label,
    required Color color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return Text(
      label,
      style: Styles.textStyle10.copyWith(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
