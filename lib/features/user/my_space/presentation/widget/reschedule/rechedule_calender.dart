import 'dart:ui'; // ضروري عشان ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RescheduleCalendar extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  const RescheduleCalendar({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryPink = const Color(0xFFE85F78);
    final Color darkText = const Color(0xFF2D2D2D);
    final Color greyText = const Color(0xFFB0B0B0);

    final Color glassBgColor = Colors.white.withOpacity(0.35);

    final Color unselectedBgColor = Color(0xFFFFFFFF).withOpacity(0.3);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE0E0E0).withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 15.w),
              decoration: BoxDecoration(
                color: glassBgColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildArrowButton(Icons.arrow_back_ios),
                        Text(
                          "يناير",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18.sp,
                            color: darkText,
                            fontFamily: 'Arial',
                          ),
                        ),
                        _buildArrowButton(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Divider(color: Colors.grey.withOpacity(0.1), thickness: 1),
                  SizedBox(height: 15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ["س", "ح", "ن", "ث", "ر", "خ", "ج"]
                        .map(
                          (e) => SizedBox(
                            width: 40.w,
                            child: Center(
                              child: Text(
                                e,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                  color: darkText,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 10.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 42,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                      crossAxisSpacing: 5.w,
                      mainAxisSpacing: 5.h,
                    ),
                    itemBuilder: (context, index) {
                      int displayDay;
                      bool isCurrentMonth = true;

                      if (index < 5) {
                        displayDay = 27 + index;
                        isCurrentMonth = false;
                      } else if (index >= 36) {
                        displayDay = index - 35;
                        isCurrentMonth = false;
                      } else {
                        displayDay = index - 4;
                        isCurrentMonth = true;
                      }

                      bool isSelected =
                          (displayDay == selectedDay && isCurrentMonth);

                      return GestureDetector(
                        onTap: () {
                          if (isCurrentMonth) onDaySelected(displayDay);
                        },
                        child: Center(
                          child: Container(
                            width: 30.r,
                            height: 30.r,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryPink
                                  : unselectedBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "$displayDay",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : isCurrentMonth
                                      ? darkText
                                      : greyText,
                                  fontSize: 14.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowButton(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: Icon(icon, size: 16.sp, color: Colors.grey[600]),
      ),
    );
  }
}
