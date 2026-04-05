// ════════════════════════════════════════════════════════
// filter_calendar.dart — زر الرجوع معطل لو في الشهر الحالي
// ════════════════════════════════════════════════════════

import '../../../../my_import.dart';
import '../cubit/advisor_filter_cubit.dart';
import '../cubit/advisor_filter_state.dart';

class FilterCalendar extends StatelessWidget {
  const FilterCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AdvisorFilterCubit, AdvisorFilterState, DateTime>(
      selector: (state) => state.selectedDate,
      builder: (context, selectedDate) {
        final today = DateTime.now();
        final todayOnly = DateTime(today.year, today.month, today.day);

        final int displayYear = selectedDate.year;
        final int displayMonth = selectedDate.month;

        final int firstWeekday =
            DateTime(displayYear, displayMonth, 1).weekday % 7;
        final int daysInMonth =
            DateTime(displayYear, displayMonth + 1, 0).day;

        // ✅ مينفعش ترجع لشهر سابق أو الشهر الحالي
    final bool canGoPrevious =
    DateTime(displayYear, displayMonth)
        .isAfter(DateTime(today.year, today.month));
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.secondary50,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              _buildHeader(context, selectedDate, canGoPrevious),
              Gap(10.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: 42,
                itemBuilder: (context, index) {
                  final int day = index - firstWeekday + 1;
                  final bool isCurrentMonth = day >= 1 && day <= daysInMonth;

                  if (!isCurrentMonth) return const SizedBox.shrink();

                  final cellDate = DateTime(displayYear, displayMonth, day);
                  final bool isPast = cellDate.isBefore(todayOnly);
                  final bool isSelected = day == selectedDate.day &&
                      selectedDate.month == displayMonth &&
                      selectedDate.year == displayYear;

                  return GestureDetector(
                    onTap: isPast
                        ? null
                        : () {
                            context
                                .read<AdvisorFilterCubit>()
                                .updateDate(cellDate);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.kprimaryColor
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      AppColors.kprimaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          day.toString(),
                          style: Styles.textStyle14.copyWith(
                            color: isSelected
                                ? Colors.white
                                : isPast
                                    ? AppColors.secondary200
                                    : AppColors.secondary800,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(
      BuildContext context, DateTime selectedDate, bool canGoPrevious) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ✅ رمادي ومعطل لو مش قادر يرجع
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: canGoPrevious
                ? AppColors.secondary800
                : AppColors.secondary200,
          ),
          onPressed: canGoPrevious
              ? () => context
                  .read<AdvisorFilterCubit>()
                  .previousMonth(selectedDate)
              : null,
        ),
        Text(
          "${selectedDate.year} - ${_getMonthName(selectedDate.month, isArabic)}",
          style: Styles.textStyle16Bold,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () =>
              context.read<AdvisorFilterCubit>().nextMonth(selectedDate),
        ),
      ],
    );
  }

  String _getMonthName(int month, bool isArabic) {
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    const englishMonths = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return isArabic ? arabicMonths[month - 1] : englishMonths[month - 1];
  }
}