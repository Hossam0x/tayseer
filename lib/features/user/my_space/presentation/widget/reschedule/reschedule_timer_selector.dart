import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RescheduleTimeSelector extends StatelessWidget {
  final String selectedTime;
  final ValueChanged<String> onTimeSelected;

  const RescheduleTimeSelector({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final times = [
      "11:00 ص",
      "10:00 ص",
      "09:00 ص",
      "12:00 م",
      "03:00 ص",
      "02:00 م",
      "01:00 م",
      "05:00 م",
      "04:00 م",
    ];

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: times.map((time) {
        bool isSelected = time == selectedTime;
        return GestureDetector(
          onTap: () => onTimeSelected(time),
          child: Container(
            width: 100.w,
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD65A73) : Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Text(
                time,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
