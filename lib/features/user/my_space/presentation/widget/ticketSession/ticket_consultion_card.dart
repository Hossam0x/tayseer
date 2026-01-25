// lib/features/user/my_space/presentation/widget/ticketSession/ticket_consultion_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:tayseer/features/user/my_space/data/model/create_session/create_session_response.dart';
import 'package:tayseer/my_import.dart';

class TicketConsultationCard extends StatelessWidget {
  final SessionData sessionData;

  const TicketConsultationCard({super.key, required this.sessionData});

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
          // اسم المستشار
          _buildRow(AssetsData.doctorIcon, sessionData.advisor.name),
          SizedBox(height: 10.h),

          // التاريخ
          _buildRow(AssetsData.calenderIcon, _formatDate(sessionData.date)),
          SizedBox(height: 10.h),

          // الوقت
          _buildRow(
            AssetsData.sessionChatTimeIcon,
            sessionData.displayTime.isNotEmpty
                ? sessionData.displayTime
                : '${sessionData.fromTime} - ${sessionData.toTime}',
          ),
          SizedBox(height: 10.h),

          // المدة
          _buildRow(AssetsData.chatIcon, _formatDuration(sessionData.duration)),
          SizedBox(height: 10.h),

          // مجهول الهوية
          if (sessionData.anonymous)
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

  String _formatDate(DateTime date) {
    // تنسيق التاريخ بالعربي
    final dayName = _getArabicDayName(date.weekday);
    final day = date.day;
    final monthName = _getArabicMonthName(date.month);
    return '$dayName، $day $monthName';
  }

  String _getArabicDayName(int weekday) {
    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[weekday - 1];
  }

  String _getArabicMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }

  String _formatDuration(String duration) {
    // تحويل المدة لنص عربي
    if (duration == '30') {
      return 'جلسة 30 دقيقة';
    } else if (duration == '60') {
      return 'جلسة ساعة كاملة';
    } else {
      return 'جلسة $duration دقيقة';
    }
  }
}
