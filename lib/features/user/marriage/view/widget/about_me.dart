import 'package:tayseer/features/user/marriage/view/widget/build_Icon_tag.dart';
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
              .map((item) => buildIconTag(item['label'], item['icon']))
              .toList(),
        ),
      ],
    );
  }
}
