import 'package:flutter/foundation.dart';

class VideoManager {
  static final VideoManager instance = VideoManager._internal();
  
  VideoManager._internal();

  // نستخدم ValueNotifier لنخبر الجميع من هو البوست الذي يعمل حالياً
  final ValueNotifier<String?> currentlyPlayingPostId = ValueNotifier(null);

  void playVideo(String postId) {
    if (currentlyPlayingPostId.value != postId) {
      currentlyPlayingPostId.value = postId;
    }
  }

  void stopAll() {
    currentlyPlayingPostId.value = null;
  }
}