import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';

class PriceDetailsCard extends StatelessWidget {
  final PricingModelResponse pricing;
  final String currency;

  const PriceDetailsCard({
    super.key,
    required this.pricing,
    this.currency = "ر.س",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _PriceRow(
            label: "سعر الجلسة",
            value: "${pricing.sessionPrice} $currency",
          ),
          _PriceRow(label: "الضرائب", value: "${pricing.taxes} $currency"),

          // _PriceRow(label: "الرسوم", value: "${pricing.fees} $currency"),
          _PriceRow(
            label: "الخصم",
            value: "-${pricing.discount} $currency",
            isDiscount: true,
          ),
          _buildDivider(),
          _buildTotalRow(),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 30.h, color: Colors.grey[300]);
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "الإجمالي",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        Text(
          "${pricing.total} $currency",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: const Color(0xFFD65A73),
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDiscount;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDiscount ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
