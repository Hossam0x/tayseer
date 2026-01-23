// lib/features/user/my_space/presentation/widget/reschedule/reschedule_time_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/get_available_day.dart';

class RescheduleTimeSelector extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final TimeSlot? selectedTimeSlot;
  final ValueChanged<TimeSlot> onTimeSelected;

  const RescheduleTimeSelector({
    super.key,
    required this.timeSlots,
    required this.selectedTimeSlot,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (timeSlots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            'لا توجد أوقات متاحة',
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 2.5,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        final isSelected = selectedTimeSlot?.time == slot.time;
        final isAvailable = slot.isAvailable;

        return GestureDetector(
          onTap: isAvailable ? () => onTimeSelected(slot) : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFE85F78)
                  : isAvailable
                  ? Colors.white
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFE85F78)
                    : isAvailable
                    ? Colors.grey[300]!
                    : Colors.grey[300]!,
              ),
              boxShadow: isAvailable
                  ? [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                slot.timeInArabic,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isAvailable
                      ? Colors.grey[700]
                      : Colors.grey[400],
                  fontSize: 13.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
