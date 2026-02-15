import 'package:tayseer/features/advisor/profille/views/cubit/age_range_cubit.dart';
import 'package:tayseer/my_import.dart';

class AgeRangeSelector extends StatelessWidget {
  const AgeRangeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AgeRangeCubit(),
      child: const _AgeRangeSelectorBody(),
    );
  }
}

class _AgeRangeSelectorBody extends StatelessWidget {
  const _AgeRangeSelectorBody();

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.whiteCard2Back,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الفئة العمرية',
            style: Styles.textStyle16Meduim.copyWith(
              color: AppColors.blackColor,
            ),
          ),
          Gap(6.h),
          // Custom Slider مع تكبير على التابلت فقط
          Container(
            height: isTablet ? 60.h : null, // زيادة الارتفاع على التابلت
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 8.w : 0,
              vertical: isTablet ? 12.h : 0,
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFFF18DA3),
                inactiveTrackColor: const Color(0xFFFDE4E9),
                thumbColor: Colors.white,
                overlayColor: const Color(0xFFF18DA3).withOpacity(0.2),
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: isTablet ? 16.w : 10.w, // تكبير Thumb
                ),
                overlayShape: RoundSliderOverlayShape(
                  overlayRadius: isTablet ? 24.w : 16.w, // تكبير Overlay
                ),
                trackHeight: isTablet ? 8.h : 4.h, // تكبير المسار
                trackShape: CustomTrackShape(), // لتحسين الشكل على التابلت
              ),
              child: BlocBuilder<AgeRangeCubit, RangeValues>(
                builder: (context, currentRangeValues) {
                  return RangeSlider(
                    values: currentRangeValues,
                    min: 0,
                    max: 200,
                    onChanged: (RangeValues values) {
                      context.read<AgeRangeCubit>().updateRange(values);
                    },
                  );
                },
              ),
            ),
          ),
          Gap(6.h),
          BlocBuilder<AgeRangeCubit, RangeValues>(
            builder: (context, currentRangeValues) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildValueBox(
                    'الحد الأقصى',
                    '${currentRangeValues.end.round()}',
                  ),
                  _buildValueBox(
                    'الحد الأدنى',
                    '${currentRangeValues.start.round()}',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValueBox(String label, String value) {
    return Column(
      children: [
        Text(label, style: Styles.textStyle12.copyWith(color: AppColors.text2)),
        Gap(4.h),
        Container(
          width: 80.w,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEEEEEE)),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Center(
            child: Text(
              value,
              style: Styles.textStyle14.copyWith(color: AppColors.blackColor),
            ),
          ),
        ),
      ],
    );
  }
}

// لتحسين شكل المسار على التابلت
class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight!;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
