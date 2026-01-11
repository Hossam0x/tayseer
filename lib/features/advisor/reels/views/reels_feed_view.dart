import 'package:preload_page_view/preload_page_view.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/reels/view_model/cubit/reels_cubit.dart';
import 'package:tayseer/features/advisor/reels/views/widget/reels_item.dart';
import 'package:tayseer/my_import.dart';

class ReelsFeedView extends StatelessWidget {
  final PostModel post;
  final VideoPlayerController? initialController;

  const ReelsFeedView({super.key, required this.post, this.initialController});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReelsCubit>(
      create: (context) => getIt<ReelsCubit>(param1: post)..fetchReels(),
      child: _ReelsFeedContent(initialController: initialController),
    );
  }
}

class _ReelsFeedContent extends StatefulWidget {
  final VideoPlayerController? initialController;

  const _ReelsFeedContent({this.initialController});

  @override
  State<_ReelsFeedContent> createState() => _ReelsFeedContentState();
}

class _ReelsFeedContentState extends State<_ReelsFeedContent> {
  PreloadPageController? _pageController;
  final _videoCacheManager = VideoCacheManager();
  int _currentIndex = 0;
  int _lastKnownReelsCount = 0;

  // Threshold to trigger loading more reels
  static const int _loadMoreThreshold = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController(initialPage: 0);

    // Auto-play the shared controller when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialController != null &&
          widget.initialController!.value.isInitialized) {
        widget.initialController!.play();
      }
    });
  }

  void _preloadNextVideos(List<PostModel> reels, int currentIndex) {
    for (int i = 1; i <= 2; i++) {
      final nextIndex = currentIndex + i;
      if (nextIndex < reels.length) {
        final videoUrl = reels[nextIndex].videoUrl;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          _videoCacheManager.preloadVideoInBackground(videoUrl);
        }
      }
    }
  }

  void _onPageChanged(int index, List<PostModel> reels) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
    }
    _preloadNextVideos(reels, index);

    // Check if we need to load more reels
    final remainingItems = reels.length - index - 1;
    if (remainingItems <= _loadMoreThreshold) {
      context.read<ReelsCubit>().fetchMoreReels();
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<ReelsCubit, ReelsState>(
        listenWhen: (previous, current) {
          // Listen when reels count changes to handle PageView update
          // OR when share action state changes
          return previous.reels.length != current.reels.length ||
              (previous.shareActionState != current.shareActionState &&
                  current.shareActionState != CubitStates.initial);
        },
        buildWhen: (previous, current) {
          // Rebuild when state changes, reels change, or loading state changes
          return previous.reelsState != current.reelsState ||
              previous.reels.length != current.reels.length ||
              previous.isLoadingMore != current.isLoadingMore;
        },
        listener: (context, state) {
          // Force update when new reels are loaded
          if (state.reels.length != _lastKnownReelsCount) {
            _lastKnownReelsCount = state.reels.length;
            // Preload videos for next items
            _preloadNextVideos(state.reels, _currentIndex);
          }

          // ✅ Handle Share Action Toast
          if (state.shareActionState == CubitStates.success) {
            if (state.isShareAdded == true) {
              AppToast.success(
                context,
                state.shareMessage ?? 'تمت المشاركة بنجاح',
              );
            } else {
              AppToast.info(context, state.shareMessage ?? 'تم إلغاء المشاركة');
            }
          } else if (state.shareActionState == CubitStates.failure) {
            AppToast.error(
              context,
              state.shareMessage ?? 'حدث خطأ أثناء المشاركة',
            );
          }
        },
        builder: (context, state) {
          // Show loading only if no reels and still loading
          if (state.reels.isEmpty && state.reelsState == CubitStates.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          // Show error only if no reels to display
          if (state.reels.isEmpty && state.reelsState == CubitStates.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.errorMessage ?? 'حدث خطأ',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ReelsCubit>().fetchReels(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              PreloadPageView.builder(
                // Remove ValueKey to prevent rebuild on list change
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: state.reels.length + (state.isLoadingMore ? 1 : 0),
                preloadPagesCount: 2,
                onPageChanged: (index) => _onPageChanged(index, state.reels),
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  if (index >= state.reels.length) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  // Pass controller only for the first reel (initial post)
                  final controllerToPass = index == 0
                      ? widget.initialController
                      : null;

                  return ReelsItem(
                    key: ValueKey('reel_item_${state.reels[index].postId}'),
                    post: state.reels[index],
                    isCurrentPage: index == _currentIndex,
                    sharedController: controllerToPass,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
