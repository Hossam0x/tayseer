// lib/features/user/my_space/presentation/widget/reschedule/reschedule_calender.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/get_available_day.dart';

class RescheduleCalendar extends StatelessWidget {
  final int? selectedDay;
  final int month;
  final int year;
  final List<CalendarDay> calendarDays;
  final Function(int day, String date) onDaySelected;
  final VoidCallback onNextMonth;
  final VoidCallback onPreviousMonth;

  const RescheduleCalendar({
    super.key,
    required this.selectedDay,
    required this.month,
    required this.year,
    required this.calendarDays,
    required this.onDaySelected,
    required this.onNextMonth,
    required this.onPreviousMonth,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryPink = const Color(0xFFE85F78);
    final Color darkText = const Color(0xFF2D2D2D);
    final Color greyText = const Color(0xFFB0B0B0);
    final Color glassBgColor = Colors.white.withOpacity(0.35);
    final Color unselectedBgColor = Color(0xFFFFFFFF).withOpacity(0.3);

    final safeMonth = month.clamp(1, 12);

    final daysInMonth = DateTime(year, safeMonth + 1, 0).day;

    const allDayNames = ["س", "ح", "ن", "ث", "ر", "خ", "ج"];

    final firstDayOffset = (DateTime(year, safeMonth, 1).weekday + 1) % 7;

    final rotatedDayNames = [
      ...allDayNames.sublist(firstDayOffset),
      ...allDayNames.sublist(0, firstDayOffset),
    ];
    final availableDaysMap = <int, CalendarDay>{};
    for (var day in calendarDays) {
      availableDaysMap[day.dayNumber] = day;
    }

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
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: onNextMonth,
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                        color: darkText,
                      ),
                      Text(
                        "${_getMonthName(safeMonth)} $year",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18.sp,
                          color: darkText,
                          fontFamily: 'Arial',
                        ),
                      ),
                      IconButton(
                        onPressed: onPreviousMonth,
                        icon: const Icon(Icons.arrow_forward_ios, size: 20),
                        color: darkText,
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  Divider(color: Colors.grey.withOpacity(0.1), thickness: 1),
                  SizedBox(height: 15.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: rotatedDayNames
                        .map(
                          (e) => SizedBox(
                            width: 38.w,
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
                    itemCount: daysInMonth,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1,
                      crossAxisSpacing: 5.w,
                      mainAxisSpacing: 5.h,
                    ),
                    itemBuilder: (context, index) {
                      final dayNumber = index + 1;
                      bool isAvailable = false;
                      String fullDate = '';

                      final calendarDay = availableDaysMap[dayNumber];
                      if (calendarDay != null) {
                        isAvailable = calendarDay.isAvailable;
                        fullDate = calendarDay.date;
                      } else {
                        fullDate =
                            '$year-${safeMonth.toString().padLeft(2, '0')}-${dayNumber.toString().padLeft(2, '0')}';
                      }

                      bool isSelected = (dayNumber == selectedDay);

                      return GestureDetector(
                        onTap: () {
                          if (isAvailable) {
                            onDaySelected(dayNumber, fullDate);
                          }
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
                                "$dayNumber",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : isAvailable
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

  String _getMonthName(int month) {
    const months = [
      'يناير', // 1
      'فبراير', // 2
      'مارس', // 3
      'أبريل', // 4
      'مايو', // 5
      'يونيو', // 6
      'يوليو', // 7
      'أغسطس', // 8
      'سبتمبر', // 9
      'أكتوبر', // 10
      'نوفمبر', // 11
      'ديسمبر', // 12
    ];

    // ✅ التأكد من أن الـ index في النطاق الصحيح
    final safeIndex = (month - 1).clamp(0, 11);
    return months[safeIndex];
  }
}
