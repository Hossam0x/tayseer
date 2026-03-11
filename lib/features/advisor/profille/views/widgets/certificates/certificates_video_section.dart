import 'package:tayseer/features/advisor/profille/views/widgets/video/video_player_widget.dart';
import 'package:tayseer/my_import.dart';

class CertificatesVideoSection extends StatelessWidget {
  final String videoUrl;

  const CertificatesVideoSection({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 300.h,
      child: VideoPlayerWidget(videoUrl: videoUrl, showFullScreenButton: true),
    );
  }
}
