import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/custom_app_image.dart';

class BankAccountField extends StatelessWidget {
  final String accountNumber;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const BankAccountField({
    super.key,
    required this.accountNumber,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          AppImage(AssetsData.bankAccountIcon, width: 24.w),
          SizedBox(width: 10.w),
          Expanded(
            child: TextFormField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: accountNumber,
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(color: Colors.black, fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}
