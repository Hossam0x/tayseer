import 'package:tayseer/my_import.dart';

class EducationSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const EducationSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("المؤهلات الأكاديمية والعملية", style: Styles.textStyle16Bold),
        Gap(10.h),
        Row(
          children: items
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: _buildPinkTag(item['label'], item['icon']),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildPinkTag(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: Colors.pink),
          Gap(5.w),
          Text(text, style: Styles.textStyle12SemiBold),
        ],
      ),
    );
  }
}
