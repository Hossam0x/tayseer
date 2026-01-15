import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/custom_app_image.dart';

class ReschedulePaymentMethods extends StatelessWidget {
  final int selectedMethodIndex;
  final ValueChanged<int> onMethodChanged;

  const ReschedulePaymentMethods({
    super.key,
    required this.selectedMethodIndex,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOption("حساب بنكي", AssetsData.bankAccountIcon, 0, isImage: true),

        SizedBox(height: 10.h),
        _buildOption("فودافون كاش", AssetsData.vodacasheIcon, 2, isImage: true),
      ],
    );
  }

  Widget _buildOption(
    String title,
    String icon,
    int index, {
    bool isImage = false,
  }) {
    bool isSelected = selectedMethodIndex == index;
    final Color primaryPink = const Color(0xFFD65A73);

    return GestureDetector(
      onTap: () => onMethodChanged(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        decoration: BoxDecoration(
          color: isSelected ? primaryPink.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? Border.all(color: primaryPink)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            AppImage(icon, width: 24.sp),
            SizedBox(width: 15.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFF2D2D2D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
