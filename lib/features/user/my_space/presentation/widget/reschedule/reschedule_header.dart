import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RescheduleHeader extends StatelessWidget {
  final String title;
  const RescheduleHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: const Color(0xFF2D2D2D),
            size: 24.sp,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        SizedBox(width: 24.sp), // For balance
      ],
    );
  }
}
