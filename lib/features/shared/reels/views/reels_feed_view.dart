import 'package:preload_page_view/preload_page_view.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/video/video_controller_manager.dart';
import 'package:tayseer/features/shared/reels/view_model/cubit/reels_cubit.dart';
import 'package:tayseer/features/shared/reels/views/widget/reels_item.dart';
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

  static const int _loadMoreThreshold = 3;
  static const int _preloadCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController(initialPage: 0);

    // Unmute when entering reels
    GlobalMuteManager.instance.setMute(false);

    _playInitialController();
  }

  // ✅ فصل اللوجيك في دالة منفصلة
  void _playInitialController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = widget.initialController;
      if (controller != null && controller.value.isInitialized) {
        controller.play();
      }
    });
  }

  void _preloadNextVideos(List<PostModel> reels, int currentIndex) {
    final urlsToPreload = <String>[];
    final controllersToPreload = <VideoItem>[];

    for (int i = 1; i <= _preloadCount; i++) {
      final nextIndex = currentIndex + i;
      if (nextIndex < reels.length) {
        final videoUrl = reels[nextIndex].videoUrl;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          urlsToPreload.add(videoUrl);
          controllersToPreload.add(
            VideoItem(id: reels[nextIndex].postId, url: videoUrl),
          );
        }
      }
    }

    // تحميل الملفات في الكاش
    if (urlsToPreload.isNotEmpty) {
      _videoCacheManager.preloadVideosInBackground(urlsToPreload);
    }

    // تحميل الـ controllers مسبقاً — Facebook-style
    if (controllersToPreload.isNotEmpty) {
      VideoControllerManager().preloadVideos(controllersToPreload);
    }
  }

  void _onPageChanged(int index, List<PostModel> reels) {
    if (_currentIndex == index) return; // ✅ Early return

    setState(() => _currentIndex = index);
    _preloadNextVideos(reels, index);
    _checkLoadMore(index, reels.length);
  }

  // ✅ فصل اللوجيك
  void _checkLoadMore(int currentIndex, int totalReels) {
    final remainingItems = totalReels - currentIndex - 1;
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
      body: MultiBlocListener(
        listeners: [
          // Listener 1: Preload videos when reels list changes
          BlocListener<ReelsCubit, ReelsState>(
            listenWhen: (previous, current) =>
                previous.reels.length != current.reels.length,
            listener: (context, state) =>
                _preloadNextVideos(state.reels, _currentIndex),
          ),

          // Listener 2: Share action toasts
          BlocListener<ReelsCubit, ReelsState>(
            listenWhen: (previous, current) =>
                previous.shareActionState != current.shareActionState &&
                current.shareActionState == CubitStates.initial,
            listener: _handleShareToast,
          ),

          //  Listener 3: Follow action
          BlocListener<ReelsCubit, ReelsState>(
            listenWhen: (previous, current) =>
                previous.followActionState != current.followActionState &&
                current.followActionState == CubitStates.failure,
            listener: (context, state) {
              AppToast.error(
                context,
                state.followMessage ?? context.tr(AppStrings.followError),
              );
            },

            // Listener 4: save action toasts
            child: BlocListener<ReelsCubit, ReelsState>(
              listenWhen: (previous, current) =>
                  previous.saveActionState != current.saveActionState &&
                  current.saveActionState == CubitStates.initial,
              listener: _handleSaveToast,
            ),
          ),
        ],
        child: BlocBuilder<ReelsCubit, ReelsState>(
          buildWhen: _shouldBuild,
          builder: _buildContent,
        ),
      ),
    );
  }

  bool _shouldBuild(ReelsState previous, ReelsState current) {
    return previous.reelsState != current.reelsState ||
        previous.reels.length != current.reels.length ||
        previous.isLoadingMore != current.isLoadingMore;
  }

  void _handleShareToast(BuildContext context, ReelsState state) {
    switch (state.shareActionState) {
      case CubitStates.success:
        final message =
            state.shareMessage ??
            (state.isShareAdded == true
                ? context.tr(AppStrings.sharedSuccess)
                : context.tr(AppStrings.unsharedSuccess));
        state.isShareAdded == true
            ? AppToast.success(context, message)
            : AppToast.info(context, message);
        break;
      case CubitStates.failure:
        AppToast.error(
          context,
          state.shareMessage ?? context.tr(AppStrings.sharedError),
        );
        break;
      default:
        break;
    }
  }

  void _handleSaveToast(BuildContext context, ReelsState state) {
    switch (state.saveActionState) {
      case CubitStates.success:
        final String? message = state.saveMessage;
        if (message != null) {
          AppToast.success(context, message);
        }
        break;
      case CubitStates.failure:
        AppToast.error(
          context,
          state.saveMessage ?? context.tr(AppStrings.reelSaveError),
        );
        break;
      default:
        break;
    }
  }

  Widget _buildContent(BuildContext context, ReelsState state) {
    // Loading state
    if (state.reels.isEmpty && state.reelsState == CubitStates.loading) {
      return _buildLoading();
    }

    // Error state
    if (state.reels.isEmpty && state.reelsState == CubitStates.failure) {
      return _buildError(context, state.errorMessage);
    }

    // Content
    return _buildReelsList(state);
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildError(BuildContext context, String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage ?? context.tr(AppStrings.error),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ReelsCubit>().fetchReels(),
            child: Text(context.tr(AppStrings.retry)),
          ),
        ],
      ),
    );
  }

  Widget _buildReelsList(ReelsState state) {
    final itemCount = state.reels.length + (state.isLoadingMore ? 1 : 0);

    return PreloadPageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: itemCount,
      preloadPagesCount: _preloadCount,
      onPageChanged: (index) => _onPageChanged(index, state.reels),
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildReelItem(state, index),
    );
  }

  Widget _buildReelItem(ReelsState state, int index) {
    // Loading indicator at the end
    if (index >= state.reels.length) {
      return _buildLoadingMoreIndicator();
    }

    final reel = state.reels[index];
    final controllerToPass = index == 0 ? widget.initialController : null;

    return ReelsItem(
      key: ValueKey('reel_item_${reel.postId}'),
      post: reel,
      isCurrentPage: index == _currentIndex,
      sharedController: controllerToPass,
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const ColoredBox(
      color: Colors.black,
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
