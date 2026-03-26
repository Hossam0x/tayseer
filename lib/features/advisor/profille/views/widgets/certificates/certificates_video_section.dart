import 'package:tayseer/core/widgets/advisor_video_player/advisor_video_player_widget.dart';
import 'package:tayseer/my_import.dart';

class CertificatesVideoSection extends StatelessWidget {
  final String videoUrl;

  const CertificatesVideoSection({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 300.h,
      child: AdvisorVideoPlayerWidget(
        videoUrl: videoUrl,
        showFullScreenButton: true,
      ),
    );
  }
}
