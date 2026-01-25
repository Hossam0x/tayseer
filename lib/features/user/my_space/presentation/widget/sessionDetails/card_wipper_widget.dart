import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? blurStrength;
  final double? borderRadius;

  const CardWrapper({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.blurStrength,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurStrength ?? 15,
          sigmaY: blurStrength ?? 15,
        ),
        child: Container(
          padding: padding ?? EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(0.50),
            borderRadius: BorderRadius.circular(borderRadius ?? 20.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
