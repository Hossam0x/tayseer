// widgets/app_media.dart

import 'package:tayseer/core/widgets/custom_app_video.dart';
import 'package:tayseer/my_import.dart';

class AppMedia extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const AppMedia(this.url, {super.key, this.fit = BoxFit.cover});

  // ✅ امتدادات الفيديو
  static const _videoExtensions = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'm4v',
    '3gp',
    'flv',
    'wmv',
  ];

  bool get _isVideo {
    final ext = url.split('.').last.toLowerCase().split('?').first;
    return _videoExtensions.contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    if (_isVideo) {
      return AppVideo(url, fit: fit);
    }

    return AppImage(url, fit: fit);
  }
}
