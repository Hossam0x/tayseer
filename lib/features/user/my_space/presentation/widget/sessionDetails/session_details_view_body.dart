import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/features/user/my_space/data/enum/session_enum.dart';
import 'package:tayseer/features/user/my_space/data/model/booking_data.dart';
import 'package:tayseer/features/user/my_space/data/model/sessoin_model.dart';
import 'package:tayseer/my_import.dart';

class UsersessionDetailsViewBody extends StatelessWidget {
  final SessionDetailsModel session;

  const UsersessionDetailsViewBody({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(context),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel(title: "بيانات الشخص"),
                  _PersonInfoCard(session: session),
                  SizedBox(height: 20.h),

                  _SectionLabel(title: "حالة الحجز"),
                  _StatusCard(status: session.status),
                  SizedBox(height: 20.h),

                  _SectionLabel(title: "بيانات الجلسة"),
                  _SessionDataCard(date: session.date, time: session.time),
                  SizedBox(height: 20.h),

                  _SectionLabel(title: "بيانات السعر"),
                  _PriceDetailsCard(totalPrice: session.priceTotal),
                  SizedBox(height: 20.h),

                  _SectionLabel(title: "وسيلة الدفع"),
                  _PaymentMethodCard(),
                  SizedBox(height: 30.h),

                  // 3. Dynamic Buttons Section
                  _ActionButtons(status: session.status),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            "تفاصيل الجلسة",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 40.w), // To balance the back button
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// --- Helper Widgets (Clean Architecture approach) ---
// -----------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
      ),
    );
  }
}

class _PersonInfoCard extends StatelessWidget {
  final SessionDetailsModel session;
  const _PersonInfoCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundImage: NetworkImage(session.imageUrl),
          ),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.advisorName,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                session.advisorHandle,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final SessionStatus status;
  const _StatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    // Logic for styling based on status
    Color bgColor;
    Color iconColor;
    String text;
    IconData icon;

    switch (status) {
      case SessionStatus.confirmed:
        bgColor = const Color(0xFFFFF0F3); // Pinkish
        iconColor = const Color(0xFFD65A73);
        text = "مؤكدة - تم التأكيد الموعد من الاستشاري";
        icon = Icons.check_circle_outline;
        break;
      case SessionStatus.completed:
        bgColor = const Color(0xFFF0FFF4); // Greenish
        iconColor = const Color(0xFF28A745);
        text = "مكتملة";
        icon = Icons.check_circle_outline;
        break;
      case SessionStatus.pending:
        bgColor = const Color(0xFFFFFAF0); // Yellowish
        iconColor = const Color(0xFFEAA800);
        text = "قيد المراجعة - بانتظار تأكيد الطبيب للموعد";
        icon = Icons.access_time_filled_outlined;
        break;
      case SessionStatus.rejected:
        bgColor = const Color(0xFFFFF0F0); // Reddish
        iconColor = const Color(0xFFDC3545);
        text = "مرفوضة - يرجى اختيار موعد آخر";
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20.sp),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                text,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionDataCard extends StatelessWidget {
  final String date;
  final String time;
  const _SessionDataCard({required this.date, required this.time});

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
          _rowItem(Icons.calendar_today_outlined, date),
          SizedBox(height: 10.h),
          _rowItem(Icons.access_time, time),
          SizedBox(height: 10.h),
          _rowItem(Icons.video_camera_front_outlined, "مكالمة فيديو"),
        ],
      ),
    );
  }

  Widget _rowItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD65A73), size: 20.sp),
        SizedBox(width: 10.w),
        Text(
          text,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[800]),
        ),
      ],
    );
  }
}

class _PriceDetailsCard extends StatelessWidget {
  final String totalPrice;
  const _PriceDetailsCard({required this.totalPrice});

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
          _priceRow("سعر الجلسة", "180 ر.س"),
          _priceRow("الضرائب", "10 ر.س"),
          _priceRow("الرسوم", "10 ر.س"),
          _priceRow("ضريبة القيمة المضافة", "20 ر.س"),
          _priceRow("رسوم التطبيق", "-30 ر.س"),
          _priceRow("الخصم", "-50 ر.س"),
          Divider(height: 30.h, color: Colors.grey[300]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الإجمالي",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              Text(
                totalPrice,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: const Color(0xFFD65A73),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
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
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.credit_card, color: Colors.orange[800], size: 24.sp),
          SizedBox(width: 10.w),
          Text(
            "ماستركارد تنتهي بـ 4567",
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final SessionStatus status;
  const _ActionButtons({required this.status});

  @override
  Widget build(BuildContext context) {
    // 1. حالة المؤكدة: لا توجد أزرار
    if (status == SessionStatus.confirmed) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomBotton(
            useGradient: true,
            title: "إعادة جدولة",
            onPressed: () {
              BookingData myOldData = BookingData(
                day: 15,
                duration: "90 دقيقة",
                time: "10:00 ص",
                paymentMethodIndex: 1,
              );

              context.pushNamed(
                AppRouter.kUserRescheduleView,
                arguments: {
                  "oldBookingData": myOldData,
                  "title": "اعاده جدوله",
                },
              );
            },
          ),
          SizedBox(height: 10.h),

          CustomOutlineButton(
            height: 50,
            width: 339.w,
            text: status == SessionStatus.completed
                ? "تقييم الاستشاري"
                : "إلغاء الحجز",
            onTap: () {
              if (status == SessionStatus.completed) {
                context.pushNamed(AppRouter.userRatingAdvisor);
              } else {}
            },
          ),
        ],
      ),
    );
  }
}
