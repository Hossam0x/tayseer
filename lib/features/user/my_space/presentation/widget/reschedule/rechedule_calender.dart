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

  const RescheduleCalendar({
    super.key,
    required this.selectedDay,
    required this.month,
    required this.year,
    required this.calendarDays,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryPink = const Color(0xFFE85F78);
    final Color darkText = const Color(0xFF2D2D2D);
    final Color greyText = const Color(0xFFB0B0B0);
    final Color glassBgColor = Colors.white.withOpacity(0.35);
    final Color unselectedBgColor = Color(0xFFFFFFFF).withOpacity(0.3);

    // ✅ التأكد من أن الشهر في النطاق الصحيح (1-12)
    final safeMonth = month.clamp(1, 12);

    // حساب عدد أيام الشهر
    final daysInMonth = DateTime(year, safeMonth + 1, 0).day;

    // حساب أول يوم في الشهر
    final firstDayOfMonth = DateTime(year, safeMonth, 1).weekday % 7;

    // إنشاء Map للأيام المتاحة
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
                  // Header - اسم الشهر فقط
                  Text(
                    _getMonthName(safeMonth), // ✅ استخدام safeMonth
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18.sp,
                      color: darkText,
                      fontFamily: 'Arial',
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Divider(color: Colors.grey.withOpacity(0.1), thickness: 1),
                  SizedBox(height: 15.h),

                  // أسماء الأيام
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

                  // أيام التقويم
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
                      bool isAvailable = false;
                      String fullDate = '';

                      if (index < firstDayOfMonth) {
                        // أيام الشهر السابق
                        final prevMonthDays = DateTime(year, safeMonth, 0).day;
                        displayDay =
                            prevMonthDays - (firstDayOfMonth - 1 - index);
                        isCurrentMonth = false;
                      } else if (index >= firstDayOfMonth + daysInMonth) {
                        // أيام الشهر التالي
                        displayDay = index - firstDayOfMonth - daysInMonth + 1;
                        isCurrentMonth = false;
                      } else {
                        // أيام الشهر الحالي
                        displayDay = index - firstDayOfMonth + 1;
                        isCurrentMonth = true;

                        final calendarDay = availableDaysMap[displayDay];
                        if (calendarDay != null) {
                          isAvailable = calendarDay.isAvailable;
                          fullDate = calendarDay.date;
                        } else {
                          fullDate =
                              '$year-${safeMonth.toString().padLeft(2, '0')}-${displayDay.toString().padLeft(2, '0')}';
                        }
                      }

                      bool isSelected =
                          (displayDay == selectedDay && isCurrentMonth);

                      return GestureDetector(
                        onTap: () {
                          if (isCurrentMonth && isAvailable) {
                            onDaySelected(displayDay, fullDate);
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
                                "$displayDay",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : isCurrentMonth
                                      ? isAvailable
                                            ? darkText
                                            : greyText
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
