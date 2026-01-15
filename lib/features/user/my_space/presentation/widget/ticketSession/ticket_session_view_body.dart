import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_consultion_card.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_header.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_price_summary.dart';
import 'package:tayseer/features/user/my_space/presentation/widget/ticketSession/ticket_promo_code.dart';

class TicketSessionViewBody extends StatelessWidget {
  const TicketSessionViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  const TicketHeader(title: "تفاصيل الحجز"),
                  SizedBox(height: 25.h),
                  Text(
                    "تفاصيل الاستشارة",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  const TicketConsultationCard(),
                  SizedBox(height: 25.h),
                  Text(
                    "كود الخصم",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  const TicketPromoCode(),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            const Spacer(),
            const TicketPriceSummary(),
          ],
        ),
      ),
    );
  }
}
