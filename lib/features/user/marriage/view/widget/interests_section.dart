import 'package:tayseer/features/user/marriage/view/widget/build_Icon_tag.dart';
import 'package:tayseer/my_import.dart';

class InterestsSection extends StatelessWidget {
  final List<Map<String, dynamic>> interests;

  const InterestsSection({super.key, required this.interests});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr('my_interests'), style: Styles.textStyle16Bold),
        Gap(10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 8.h,
          children: interests
              .map((i) => buildIconTag(i['label'], i['icon']))
              .toList(),
        ),
      ],
    );
  }
}
