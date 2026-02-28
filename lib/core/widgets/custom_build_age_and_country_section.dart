// lib/features/user/marriage_filter/view/widget/custom_age_and_country_section.dart

import 'package:tayseer/my_import.dart';

class CustomAgeAndCountrySection extends StatelessWidget {
  /// نطاق العمر الحالي
  final RangeValues ageRange;

  /// callback عند تغيير نطاق العمر
  final ValueChanged<RangeValues> onAgeRangeChanged;

  /// قيمة الدولة المختارة
  final String? countryValue;

  /// قيمة الجنسية المختارة
  final String? nationalityValue;

  /// callback عند الضغط على الدولة
  final VoidCallback onCountryTap;

  /// callback عند الضغط على الجنسية
  final VoidCallback onNationalityTap;

  /// الحد الأدنى للعمر
  final double minAge;

  /// الحد الأقصى للعمر
  final double maxAge;

  /// اللون الأساسي
  final Color primaryColor;

  const CustomAgeAndCountrySection({
    super.key,
    required this.ageRange,
    required this.onAgeRangeChanged,
    this.countryValue,
    this.nationalityValue,
    required this.onCountryTap,
    required this.onNationalityTap,
    this.minAge = 18,
    this.maxAge = 60,
    this.primaryColor = const Color(0xFFE91E63),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ عنوان نطاق العمر
          Text(context.tr('age_range'), style: Styles.textStyle16Bold),
          const SizedBox(height: 10),

          // ✅ Range Slider للعمر
          _buildAgeSlider(context),

          // ✅ صف الدولة
          const Divider(height: 30, thickness: 0.8),
          _buildRow(
            context: context,
            title: context.tr('country'),
            value: countryValue,
            defaultValue: context.tr('egypt'),
            onTap: onCountryTap,
          ),

          // ✅ صف الجنسية
          const Divider(height: 30, thickness: 0.8),
          _buildRow(
            context: context,
            title: context.tr('nationality'),
            value: nationalityValue,
            defaultValue: context.tr('egyptian'),
            onTap: onNationalityTap,
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSlider(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: 12,
          elevation: 4,
          pressedElevation: 6,
        ),
        thumbColor: Colors.white,
        activeTrackColor: primaryColor,
        inactiveTrackColor: Colors.grey[200],
        showValueIndicator: ShowValueIndicator.always,
        valueIndicatorColor: primaryColor.withOpacity(0.2),
        valueIndicatorTextStyle: const TextStyle(
          color: Color(0xFF535353),
          fontWeight: FontWeight.bold,
        ),
        rangeValueIndicatorShape: const PaddleRangeSliderValueIndicatorShape(),
      ),
      child: RangeSlider(
        values: ageRange,
        min: minAge,
        max: maxAge,
        labels: RangeLabels(
          ageRange.start.round().toString(),
          ageRange.end.round().toString(),
        ),
        onChanged: onAgeRangeChanged,
      ),
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required String title,
    String? value,
    String? defaultValue,
    required VoidCallback onTap,
  }) {
    String displayValue = defaultValue ?? context.tr('no_preference');

    if (value != null && value.isNotEmpty) {
      displayValue = value.contains('_') ? context.tr(value) : value;
    }

    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Styles.textStyle16.copyWith(fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Text(
                displayValue,
                style: Styles.textStyle14.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
