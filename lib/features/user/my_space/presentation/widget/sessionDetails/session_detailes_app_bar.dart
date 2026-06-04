import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';

class SessionDetailsAppBar extends StatelessWidget {
  final String? title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const SessionDetailsAppBar({
    super.key,
    this.title,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
            onPressed: onBack ?? () => Navigator.pop(context),
          ),
          Text(
            title ?? context.tr('session_details_title'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (actions != null)
            Row(children: actions!)
          else
            SizedBox(width: 40.w),
        ],
      ),
    );
  }
}
