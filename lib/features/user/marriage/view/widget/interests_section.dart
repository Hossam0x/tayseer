import 'package:tayseer/features/user/marriage/view/widget/build_Icon_tag.dart';
import 'package:tayseer/my_import.dart';

class InterestsSection extends StatelessWidget {
  final List<Map<String, dynamic>> interests;
final String ?title;
  const InterestsSection({super.key, required this.interests,  this.title='my_interests'});

  @override
  Widget build(BuildContext context) {
    final filteredInterests = interests
        .where(
          (i) =>
              i['label'] != null &&
              i['label'].toString().trim().isNotEmpty &&
              i['label'].toString().toLowerCase() != 'null',
        )
        .toList();

    if (filteredInterests.isEmpty) {
      return const SizedBox.shrink(); // 👈 مفيش اهتمامات = السيكشن يختفي
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr(title!), style: Styles.textStyle16Bold),
        Gap(10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 8.h,
          children: filteredInterests
              .map((i) => buildIconTag(i['label']))
              .toList(),
        ),
      ],
    );
  }
}
