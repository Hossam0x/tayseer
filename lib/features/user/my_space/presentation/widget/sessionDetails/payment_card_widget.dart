import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/core/widgets/custom_app_image.dart';
import 'package:tayseer/features/user/my_space/data/helper/session_detailes_helper.dart';

class PaymentMethodCard extends StatelessWidget {
  final String paymentMethod;

  const PaymentMethodCard({super.key, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    final paymentInfo = SessionDetailsHelper.getPaymentMethodInfo(
      paymentMethod,
    );

    final displayText = paymentInfo.displayTextKey != null
        ? context.tr(paymentInfo.displayTextKey!)
        : paymentInfo.rawText ?? paymentMethod;

    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          AppImage(
            paymentInfo.icon,
            width: 24.sp,
            color: AppColors.primaryPink,
          ),
          SizedBox(width: 10.w),
          Text(
            displayText,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
