import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RescheduleDurationSelector extends StatelessWidget {
  final String selectedDuration;
  final ValueChanged<String> onDurationChanged;

  const RescheduleDurationSelector({
    super.key,
    required this.selectedDuration,
    required this.onDurationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildItem("90 دقيقة")),
        SizedBox(width: 10.w),
        Expanded(child: _buildItem("45 دقيقة")),
      ],
    );
  }

  Widget _buildItem(String text) {
    bool isSelected = selectedDuration == text;
    return GestureDetector(
      onTap: () => onDurationChanged(text),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD65A73) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}
