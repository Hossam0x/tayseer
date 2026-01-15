import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/my_import.dart';

class BookingSuccessView extends StatelessWidget {
  const BookingSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: const Color(0xFF530D1D),
                      size: 30.sp,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                Text(
                  "تم حجز الاستشارة بنجاح",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kprimaryTextColor,
                    fontFamily: 'Arial',
                  ),
                ),
                const Spacer(),
                Image.asset(
                  AssetsData.ratingSuccessIcon,
                  width: 250.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20.h),
                Text(
                  ". شكراً لك سيتم مراجعته والنظر فيه",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
