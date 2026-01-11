import 'package:tayseer/my_import.dart';

class AgeRangeSelector extends StatefulWidget {
  const AgeRangeSelector({super.key});

  @override
  State<AgeRangeSelector> createState() => _AgeRangeSelectorState();
}

class _AgeRangeSelectorState extends State<AgeRangeSelector> {
  RangeValues _currentRangeValues = const RangeValues(170, 180);
  final double minValue = 0;
  final double maxValue = 200;

  @override
  Widget build(BuildContext context) {
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
          // Custom Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFF18DA3),
              inactiveTrackColor: const Color(0xFFFDE4E9),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFFF18DA3).withOpacity(0.2),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10.w),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16.w),
              trackHeight: 4.h,
            ),
            child: RangeSlider(
              values: _currentRangeValues,
              min: minValue,
              max: maxValue,
              onChanged: (RangeValues values) {
                setState(() {
                  _currentRangeValues = values;
                });
              },
            ),
          ),
          Gap(6.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildValueBox(
                'الحد الأقصى',
                '${_currentRangeValues.end.round()}',
              ),
              _buildValueBox(
                'الحد الأدنى',
                '${_currentRangeValues.start.round()}',
              ),
            ],
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
