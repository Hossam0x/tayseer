import 'package:tayseer/features/user/marriage/view/widget/build_Icon_tag.dart';
import 'package:tayseer/my_import.dart';

class EducationSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const EducationSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr("academic_qualifications"),
          style: Styles.textStyle16Bold,
        ),
        Gap(10.h),
        Row(
          children: items
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: buildIconTag(item['label'], item['icon']),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
