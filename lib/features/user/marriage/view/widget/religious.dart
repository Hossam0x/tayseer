import 'package:tayseer/features/user/marriage/view/widget/build_Icon_tag.dart';
import 'package:tayseer/my_import.dart';

class ReligiousSection extends StatelessWidget {
  final List<Map<String, dynamic>> tags;

  const ReligiousSection({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr("religious"), style: Styles.textStyle16Bold),
        Gap(10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: tags
              .map((tag) => buildIconTag(tag['label'], tag['icon']))
              .toList(),
        ),
      ],
    );
  }
}
