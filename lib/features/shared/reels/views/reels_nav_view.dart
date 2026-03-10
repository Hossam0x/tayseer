import 'package:preload_page_view/preload_page_view.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/core/utils/video_cache_manager.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/reels/view_model/cubit/reels_cubit.dart';
import 'package:tayseer/features/shared/reels/views/widget/reels_item.dart';
import 'package:tayseer/features/shared/reels/views/widget/reels_shimmer.dart';
import 'package:tayseer/my_import.dart';

/// ✅ ريلز مستقلة للناف بار — بتحمل ريلز من الـ API مباشرة بدون initialPost
class ReelsNavView extends StatelessWidget {
  final int tabIndex;
  const ReelsNavView({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReelsCubit>(
      create: (context) => getIt<ReelsCubit>(param1: null),
      child: _ReelsNavContent(tabIndex: tabIndex),
    );
  }
}

class _ReelsNavContent extends StatefulWidget {
  final int tabIndex;
  const _ReelsNavContent({required this.tabIndex});

  @override
  State<_ReelsNavContent> createState() => _ReelsNavContentState();
}

class _ReelsNavContentState extends State<_ReelsNavContent> {
  PreloadPageController? _pageController;
  final _videoCacheManager = VideoCacheManager();

  int _currentIndex = 0;
  bool _isTabActive = false;
  bool _hasFetched = false;

  static const int _loadMoreThreshold = 3;
  static const int _preloadCount = 2;

  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController(initialPage: 0);
  }

  void _preloadNextVideos(List<PostModel> reels, int currentIndex) {
    for (int i = 1; i <= _preloadCount; i++) {
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
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);
    _preloadNextVideos(reels, index);
    _checkLoadMore(index, reels.length);
  }

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

          // Listener 3: Follow action
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
        child: BlocListener<LayoutCubit, LayoutState>(
          listenWhen: (previous, current) =>
              previous.currentIndex != current.currentIndex,
          listener: (context, layoutState) {
            final isActive = layoutState.currentIndex == widget.tabIndex;
            if (isActive != _isTabActive) {
              setState(() => _isTabActive = isActive);
              if (isActive) {
                GlobalMuteManager.instance.setMute(false);
                if (!_hasFetched) {
                  _hasFetched = true;
                  context.read<ReelsCubit>().fetchReels();
                }
              }
            }
          },
          child: BlocBuilder<ReelsCubit, ReelsState>(
            buildWhen: _shouldBuild,
            builder: _buildContent,
          ),
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
    // ✅ Loading state — شيمر
    if (state.reels.isEmpty && state.reelsState == CubitStates.loading) {
      return const ReelsShimmer();
    }

    // ✅ Error state
    if (state.reels.isEmpty && state.reelsState == CubitStates.failure) {
      return _buildError(context, state.errorMessage);
    }

    // ✅ Empty state
    if (state.reels.isEmpty && state.reelsState == CubitStates.success) {
      return _buildEmpty(context);
    }

    // ✅ Content
    return _buildReelsList(state);
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

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, color: Colors.grey[600], size: 64),
          Gap(16.h),
          Text(
            context.tr(AppStrings.noReelsAvailable),
            style: TextStyle(color: Colors.grey[400], fontSize: 16.sp),
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
    final shouldInit = (index == _currentIndex || index == _currentIndex + 1);

    return ReelsItem(
      key: ValueKey('reel_nav_${reel.postId}'),
      post: reel,
      isCurrentPage: index == _currentIndex && _isTabActive,
      shouldInitialize: shouldInit && _isTabActive,
      onClose: () {
        final layoutCubit = context.read<LayoutCubit>();
        layoutCubit.changeIndex(0);
        layoutCubit.setNavVisibility(true);
      },
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const ColoredBox(
      color: Colors.black,
      child: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
