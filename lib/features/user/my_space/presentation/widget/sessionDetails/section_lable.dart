import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionLabel extends StatelessWidget {
  final String title;
  final double? fontSize;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const SectionLabel({
    super.key,
    required this.title,
    this.fontSize,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSize ?? 12.sp,
          color: color ?? Colors.grey[600],
        ),
      ),
    );
  }
}
