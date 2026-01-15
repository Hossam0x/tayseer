import 'package:tayseer/my_import.dart';

class AboutMeSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const AboutMeSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('about_me'), style: Styles.textStyle16Bold),
        Gap(10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: items
              .map((item) => _buildIconTag(item['label'], item['icon']))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildIconTag(String text, String icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppImage(icon, gradientColorSvg: AppColors.linearGradientIcon),
          Gap(5.w),
          Text(text, style: Styles.textStyle12),
        ],
      ),
    );
  }
}
