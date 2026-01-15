import 'package:tayseer/my_import.dart';

class InterestsSection extends StatelessWidget {
  final List<String> interests;

  const InterestsSection({super.key, required this.interests});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("اهتماماتي", style: Styles.textStyle16Bold),
        Gap(10.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 8.h,
          children: interests.map((i) => _buildInterest(i)).toList(),
        ),
      ],
    );
  }

  Widget _buildInterest(String text) {
    return Chip(
      avatar: const Icon(Icons.favorite, color: Colors.pink, size: 16),
      label: Text(text, style: Styles.textStyle12),
      backgroundColor: Colors.pink.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
