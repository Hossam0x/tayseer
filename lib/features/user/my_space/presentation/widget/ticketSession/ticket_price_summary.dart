import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/my_import.dart';

class TicketPriceSummary extends StatelessWidget {
  const TicketPriceSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow("سعر الجلسة", "200 ر.س"),
          SizedBox(height: 10.h),
          _buildPriceRow("الرسوم", "10 ر.س"),
          SizedBox(height: 10.h),
          _buildPriceRow("ضريبة القيمة المضافة", "20 ر.س"),
          SizedBox(height: 10.h),
          _buildPriceRow("الخصم", "-50 ر.س", valueColor: Colors.green),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Divider(color: Colors.grey.shade200),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الإجمالي",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "240 ر.س",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD3556E),
                ),
              ),
            ],
          ),
          SizedBox(height: 25.h),
          CustomBotton(
            useGradient: true,
            title: 'حجز',
            onPressed: () {
              context.pushNamed(AppRouter.sessionticketsuccessview);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            color: valueColor ?? Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
