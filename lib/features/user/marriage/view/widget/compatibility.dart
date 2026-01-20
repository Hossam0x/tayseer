import 'package:tayseer/my_import.dart';

class CompatibilitySection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> tags;

  const CompatibilitySection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [HexColor('e5eef9'), HexColor('f9e1e8')],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Styles.textStyle16Bold),
          Text(
            subtitle,
            style: Styles.textStyle12.copyWith(color: AppColors.kGreyColor),
          ),
          Gap(10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: tags.map((tag) => _buildTag(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),

      decoration: BoxDecoration(
        color: HexColor('f8f7fb'),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: AppColors.kWhiteColor),
      ),
      child: Text(text, style: Styles.textStyle12SemiBold),
    );
  }
}
