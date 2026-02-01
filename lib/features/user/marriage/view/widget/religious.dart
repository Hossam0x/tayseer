import 'package:tayseer/features/user/marriage/view/widget/build_Icon_tag.dart';
import 'package:tayseer/my_import.dart';

class ReligiousSection extends StatelessWidget {
  final List<Map<String, dynamic>> tags;

  const ReligiousSection({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    final filteredTags = tags
        .where(
          (tag) =>
              tag['label'] != null &&
              tag['label'].toString().trim().isNotEmpty &&
              tag['label'].toString().toLowerCase() != 'null',
        )
        .toList();

    if (filteredTags.isEmpty) {
      return const SizedBox.shrink(); // 👈 السيكشن كله يختفي
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr("religious"), style: Styles.textStyle16Bold),
        Gap(10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: filteredTags
              .map((tag) => buildIconTag(tag['label']))
              .toList(),
        ),
      ],
    );
  }
}
