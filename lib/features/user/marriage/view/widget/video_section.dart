import 'package:tayseer/my_import.dart';

class VideoSection extends StatelessWidget {
  final String thumbnailUrl;
  const VideoSection({super.key, required this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AppImage(
            thumbnailUrl,
            width: context.width,
            height: 250.h,
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black26),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.replay_10, color: Colors.white, size: 30),
              Gap(20.w),
              const Icon(
                Icons.pause_circle_filled,
                color: Colors.white,
                size: 50,
              ),
              Gap(20.w),
              const Icon(Icons.forward_10, color: Colors.white, size: 30),
            ],
          ),
        ],
      ),
    );
  }
}
