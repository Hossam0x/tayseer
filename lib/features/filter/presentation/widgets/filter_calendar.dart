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
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.secondary50,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            children: [
              _buildHeader(context, selectedDate),
              Gap(10.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: 35,
                itemBuilder: (context, index) {
                  int day = index - 3;
                  if (day < 1 || day > 31) return const SizedBox.shrink();
                  bool isSelected = day == selectedDate.day;
                  return GestureDetector(
                    onTap: () {
                      context.read<AdvisorFilterCubit>().updateDate(
                        DateTime(selectedDate.year, selectedDate.month, day),
                      );
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
                                  color: AppColors.kprimaryColor.withOpacity(
                                    0.3,
                                  ),
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

  Widget _buildHeader(BuildContext context, DateTime selectedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => context.read<AdvisorFilterCubit>().previousMonth(),
        ),
        Text(
          "${selectedDate.year} - ${_getMonthName(selectedDate.month)}",
          style: Styles.textStyle16Bold,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => context.read<AdvisorFilterCubit>().nextMonth(),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
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
}
