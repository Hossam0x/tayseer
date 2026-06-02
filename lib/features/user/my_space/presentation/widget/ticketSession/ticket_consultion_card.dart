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
          _buildRow(
            AssetsData.calenderIcon,
            _formatDate(context, sessionData.date),
          ),
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
          _buildRow(
            AssetsData.chatIcon,
            _formatDuration(context, sessionData.duration),
          ),
          SizedBox(height: 10.h),

          // مجهول الهوية
          if (sessionData.isAnonymous)
            _buildRow(AssetsData.anonIcon, context.tr('anonymous_identity')),
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

  String _formatDate(BuildContext context, DateTime date) {
    if (isArabic) {
      final dayName = _getArabicDayName(date.weekday);
      final monthName = _getArabicMonthName(date.month);
      return '$dayName، ${date.day} $monthName';
    } else {
      final dayName = _getEnglishDayName(date.weekday);
      final monthName = _getEnglishMonthName(date.month);
      return '$dayName, ${date.day} $monthName';
    }
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
    return days[(weekday - 1).clamp(0, 6)];
  }

  String _getEnglishDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[(weekday - 1).clamp(0, 6)];
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
    return months[(month - 1).clamp(0, 11)];
  }

  String _getEnglishMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[(month - 1).clamp(0, 11)];
  }

  String _formatDuration(BuildContext context, String duration) {
    if (duration == '30') {
      return context.tr('session_30_minutes');
    } else if (duration == '60') {
      return context.tr('session_60_minutes');
    } else {
      // fallback لأي مدة تانية
      return context.tr('session_n_minutes').replaceAll('%s', duration);
    }
  }
}
