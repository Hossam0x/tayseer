import 'package:tayseer/my_import.dart';

class ReligiousSection extends StatelessWidget {
  final String title;
  final List<String> tags;

  const ReligiousSection({super.key, required this.title, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Styles.textStyle16Bold),
        Gap(10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: tags.map((tag) => _buildTag(tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.pink, size: 14),
          Gap(5.w),
          Text(text, style: Styles.textStyle12),
        ],
      ),
    );
  }
}
