// lib/features/user/my_space/presentation/widget/reschedule/reschedule_duration.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/get_available_day.dart';

class RescheduleDurationSelector extends StatelessWidget {
  final List<DurationOption> durations;
  final DurationOption? selectedDuration;
  final ValueChanged<DurationOption> onDurationChanged;

  const RescheduleDurationSelector({
    super.key,
    required this.durations,
    required this.selectedDuration,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (durations.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            'لا توجد مدد متاحة',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      );
    }

    return Row(
      children: durations.asMap().entries.map((entry) {
        final index = entry.key;
        final duration = entry.value;
        final isSelected = selectedDuration?.type == duration.type;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 5.w,
              right: index == durations.length - 1 ? 0 : 5.w,
            ),
            child: GestureDetector(
              onTap: () => onDurationChanged(duration),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD65A73) : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    duration.durationInArabic,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
