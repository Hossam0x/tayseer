import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:video_player/video_player.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/reels/views/widget/reels_item.dart';

class ReelsFeedView extends StatefulWidget {
  final List<PostModel> posts;
  final int initialIndex;
  final VideoPlayerController? initialController;

  const ReelsFeedView({
    super.key,
    required this.posts,
    this.initialIndex = 0,
    this.initialController,
  });

  @override
  State<ReelsFeedView> createState() => _ReelsFeedViewState();
}

class _ReelsFeedViewState extends State<ReelsFeedView> {
  late PreloadPageController _pageController;
  final _videoCacheManager = VideoCacheManager();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PreloadPageController(initialPage: widget.initialIndex);
    _preloadNextVideos(_currentIndex);
  }

  void _preloadNextVideos(int currentIndex) {
    for (int i = 1; i <= 2; i++) {
      final nextIndex = currentIndex + i;
      if (nextIndex < widget.posts.length) {
        final videoUrl = widget.posts[nextIndex].videoUrl;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          _videoCacheManager.preloadVideoInBackground(videoUrl);
        }
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _preloadNextVideos(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PreloadPageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length,
        preloadPagesCount: 1,
        onPageChanged: _onPageChanged,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          // نمرر الكنترولر فقط للبوست الأول اللي ضغطنا عليه
          final controllerToPass = (index == widget.initialIndex)
              ? widget.initialController
              : null;

          return ReelsItem(
            post: widget.posts[index],
            isCurrentPage: index == _currentIndex,
            sharedController: controllerToPass,
          );
        },
      ),
    );
  }
}
