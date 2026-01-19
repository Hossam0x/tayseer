// lib/features/user/my_space/presentation/widget/rating/feedback_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FeedbackTextField extends StatelessWidget {
  final TextEditingController? controller;

  const FeedbackTextField({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16.r),
          hintText:
              "يساعد رأيك المرضى الآخرين في اختيار المعالج المناسب، كما يساعد المعالج على تحسين خدماته",
          hintStyle: TextStyle(color: Colors.black26, fontSize: 14.sp),
        ),
      ),
    );
  }
}
