import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/my_import.dart';

class TicketConsultationCard extends StatelessWidget {
  const TicketConsultationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF4F6).withOpacity(0.6),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildRow(AssetsData.doctorIcon, "د. رفعت جميل"),
          SizedBox(height: 10.h),
          _buildRow(AssetsData.calenderIcon, "السبت، 1 فبراير"),
          SizedBox(height: 10.h),
          _buildRow(AssetsData.sessionChatTimeIcon, "03:00 م - 04:00 م"),
          SizedBox(height: 10.h),
          _buildRow(AssetsData.chatIcon, "محادثة لمدة يوم كامل"),
          SizedBox(height: 10.h),
          _buildRow(AssetsData.anonIcon, "مجهول الهوية"),
        ],
      ),
    );
  }

  Widget _buildRow(String icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        AppImage(icon, color: const Color(0xFFD3556E), width: 20.sp),
        SizedBox(width: 10.w),

        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
