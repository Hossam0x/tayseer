// lib/features/user/my_space/presentation/widget/reschedule/day_time_wheel_picker.dart

import 'package:tayseer/my_import.dart';

class DayTimeWheelPicker extends StatefulWidget {
  final List<dynamic> days;
  final int? selectedIndex;
  final ValueChanged<int> onItemTapped;

  const DayTimeWheelPicker({
    super.key,
    required this.days,
    this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<DayTimeWheelPicker> createState() => _DayTimeWheelPickerState();
}

class _DayTimeWheelPickerState extends State<DayTimeWheelPicker> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double itemHeight = 56.h;

    return Stack(
      children: [
        // ═══ القائمة ═══
        ListView.builder(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          itemCount: widget.days.length,
          itemBuilder: (context, index) {
            final day = widget.days[index];
            final isAvailable = day.isAvailable && day.hasAvailableSlots;
            final isSelected = widget.selectedIndex == index;

            final dayText = isArabic ? day.dayName : day.dayNameEn;
            final month = isArabic ? day.monthName : day.monthNameEn;
            final time = isArabic
                ? day.firstAvailableTimeArabic
                : day.firstAvailableTime;

            return GestureDetector(
              onTap: isAvailable ? () => widget.onItemTapped(index) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                height: itemHeight,
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  // ★ الخلفية تظهر فقط عند الاختيار
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            AppColors.kprimaryColor.withOpacity(0.18),
                            AppColors.kprimaryColor.withOpacity(0.05),
                          ],
                          begin: isArabic
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          end: isArabic
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ★ الوقت
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: isSelected ? 17.sp : 13.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: _getTextColor(isAvailable, isSelected),
                        fontFamily: Styles.textStyle14.fontFamily,
                      ),
                      child: Text(time),
                    ),

                    // ★ اليوم والتاريخ
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: isSelected ? 17.sp : 13.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: _getTextColor(isAvailable, isSelected),
                        fontFamily: Styles.textStyle14.fontFamily,
                      ),
                      child: Text('$dayText, ${day.dayNumber} $month'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // ═══ تلاشي أعلى ═══
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ═══ تلاشي أسفل ═══
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getTextColor(bool isAvailable, bool isSelected) {
    if (!isAvailable) return Colors.grey.shade500;
    if (isSelected) return Colors.black;
    return Colors.black87;
  }
}
