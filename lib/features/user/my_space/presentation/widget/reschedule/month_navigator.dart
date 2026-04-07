// lib/features/user/my_space/presentation/widget/reschedule/month_navigator.dart

import 'package:tayseer/my_import.dart';

class MonthNavigator extends StatelessWidget {
  final int month;
  final int year;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const MonthNavigator({
    super.key,
    required this.month,
    required this.year,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ★ سهم يسار (السابق)
          _ArrowButton(icon: Icons.chevron_left, onTap: onPrevious),

          SizedBox(width: 8.w),

          // ★ سهم يمين (التالي)
          _ArrowButton(icon: Icons.chevron_right, onTap: onNext),

          SizedBox(width: 16.w),

          // ★ اسم الشهر والسنة
          Text(
            '${isArabic ? _getMonthNameAr(month) : _getMonthNameEn(month)}، $year',
            style: Styles.textStyle16.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.kprimaryColor,
            ),
          ),

          SizedBox(width: 8.w),

          // ★ أيقونة التقويم
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.kprimaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              color: AppColors.kprimaryColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthNameAr(int month) {
    const months = [
      '',
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
    if (month >= 1 && month <= 12) return months[month];
    return '';
  }

  String _getMonthNameEn(int month) {
    const months = [
      '',
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
    if (month >= 1 && month <= 12) return months[month];
    return '';
  }
}

// ════════════════════════════════════════
// ★ Arrow Button
// ════════════════════════════════════════
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade100,
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Icon(icon, size: 18, color: Colors.grey.shade600),
      ),
    );
  }
}
