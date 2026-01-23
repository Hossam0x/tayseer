// lib/features/user/my_space/presentation/widget/reschedule/reschedule_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RescheduleHeader extends StatelessWidget {
  final String title;

  const RescheduleHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: EdgeInsets.all(8.r),

            child: Icon(
              Icons.arrow_back_ios,
              size: 20.sp,
              color: const Color(0xFF2D2D2D),
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D2D2D),
          ),
        ),
      ],
    );
  }
}
