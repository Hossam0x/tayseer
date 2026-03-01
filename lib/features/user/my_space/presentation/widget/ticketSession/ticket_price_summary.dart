// lib/features/user/my_space/presentation/widget/ticketSession/ticket_price_summary.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/create_session_response.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_cubit.dart';
import 'package:tayseer/my_import.dart';

class TicketPriceSummary extends StatelessWidget {
  final SessionData sessionData;
  final int discountPercentage;

  const TicketPriceSummary({
    super.key,
    required this.sessionData,
    this.discountPercentage = 0,
  });

  @override
  Widget build(BuildContext context) {
    // حساب قيمة الخصم
    final discountAmount = discountPercentage > 0
        ? (sessionData.total * discountPercentage / 100).round()
        : 0;

    // حساب الإجمالي بعد الخصم
    final finalTotal = sessionData.total - discountAmount;

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
          // سعر الجلسة
          _buildPriceRow("سعر الجلسة", "${sessionData.price} ر.س"),
          SizedBox(height: 10.h),

          // // الرسوم
          // _buildPriceRow("الرسوم", "${sessionData.fees} ر.س"),
          // SizedBox(height: 10.h),

          // ضريبة القيمة المضافة
          _buildPriceRow("ضريبة القيمة المضافة", "${sessionData.tax} ر.س"),
          SizedBox(height: 10.h),

          // الخصم (يظهر فقط لو في خصم)
          if (discountPercentage > 0) ...[
            _buildPriceRow(
              "الخصم ($discountPercentage%)",
              "-$discountAmount ر.س",
              valueColor: Colors.green,
            ),
            SizedBox(height: 10.h),
          ],

          Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h),
            child: Divider(color: Colors.grey.shade200),
          ),

          // الإجمالي
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // السعر الأصلي (مشطوب) لو في خصم
                  if (discountPercentage > 0)
                    Text(
                      "${sessionData.total} ر.س",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  // السعر النهائي
                  Text(
                    "$finalTotal ر.س",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD3556E),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 25.h),

          // زر الدفع
          CustomBotton(
            useGradient: true,
            title: 'تأكيد الحجز',
            onPressed: () {
              context.read<TicketSessionCubit>().paySession(
                sessionId: sessionData.id,
              );
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
