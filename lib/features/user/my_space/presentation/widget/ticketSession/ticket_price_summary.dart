import 'package:tayseer/features/user/my_space/data/model/create_session/create_session_response.dart';
import 'package:tayseer/features/user/my_space/presentation/manager/ticket_session/ticket_session_cubit.dart';
import 'package:tayseer/my_import.dart';

class TicketPriceSummary extends StatelessWidget {
  final SessionData sessionData;
  final int discountPercentage;
  final bool isLoading;
  const TicketPriceSummary({
    super.key,
    required this.sessionData,
    this.discountPercentage = 0,
    required this.isLoading,
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
          _buildPriceRow(
            context,
            context.tr("session_price"),
            "${sessionData.price} ${sessionData.currency}",
          ),
          SizedBox(height: 10.h),

          // ضريبة القيمة المضافة
          _buildPriceRow(
            context,
            context.tr("vat"),
            "${sessionData.tax} ${sessionData.currency}",
          ),
          SizedBox(height: 10.h),

          // رسوم الخدمة
          _buildPriceRow(
            context,
            context.tr("fees"),
            "${sessionData.fees} ${sessionData.currency}",
          ),
          SizedBox(height: 10.h),

          // الخصم (يظهر فقط لو في خصم)
          if (discountPercentage > 0) ...[
            _buildPriceRow(
              context,
              "${context.tr("discount")} ($discountPercentage%)",
              "-$discountAmount ${sessionData.currency}",
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
                context.tr("total"),
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
                      "${sessionData.total} ${sessionData.currency}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  // السعر النهائي
                  Text(
                    "${finalTotal.toStringAsFixed(2)} ${sessionData.currency}",
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
          SizedBox(height: 20.h),

          // زر الدفع
          CustomBotton(
            useGradient: true,
            title: context.tr("confirm_booking"),
            onPressed: () {
              if (!isLoading) {
                context.read<TicketSessionCubit>().paySession(
                  offeringId: sessionData.offeringId,
                  context: context,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
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
