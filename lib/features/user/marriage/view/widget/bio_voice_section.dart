import 'package:tayseer/my_import.dart';

class BioVoiceSection extends StatelessWidget {
  final String bioText;
  final String duration;

  const BioVoiceSection({
    super.key,
    required this.bioText,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("السيرة الذاتية", style: Styles.textStyle16Bold),
            const Spacer(),
            const Icon(Icons.mic, color: Colors.grey),
          ],
        ),
        Gap(10.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: [
              Text(
                bioText,
                style: Styles.textStyle12.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              Gap(20.h),
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.pinkAccent,
                    child: Icon(Icons.play_arrow, color: Colors.white),
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Container(height: 4.h, color: Colors.grey.shade400),
                  ),
                  Gap(10.w),
                  Text(duration, style: Styles.textStyle12SemiBold),
                  Gap(5.w),
                  const Icon(Icons.volume_up, size: 20),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
