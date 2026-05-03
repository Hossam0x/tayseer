import 'package:preload_page_view/preload_page_view.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/core/video/reels_video_preloader.dart';
import 'package:tayseer/core/video/video_state_manager.dart';
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
      child: _ReelsFeedContent(
        initialController: initialController,
        initialPostId: post.postId, // ✅ جديد: بنمرّر الـ postId
      ),
    );
  }
}

class _ReelsFeedContent extends StatefulWidget {
  final VideoPlayerController? initialController;
  final String initialPostId; // ✅ جديد

  const _ReelsFeedContent({
    this.initialController,
    required this.initialPostId,
  });

  @override
  State<_ReelsFeedContent> createState() => _ReelsFeedContentState();
}

class _ReelsFeedContentState extends State<_ReelsFeedContent> {
  PreloadPageController? _pageController;
  final _stateManager = VideoStateManager();
  final _preloader = ReelsVideoPreloader.instance;

  int _currentIndex = 0;

  static const int _loadMoreThreshold = 3;
  static const int _preloadCount = 2;

  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController(initialPage: 0);
    _playInitialController();
  }

  void _playInitialController() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GlobalMuteManager.instance.setMute(false);

      final controller = widget.initialController;
      if (controller != null && controller.value.isInitialized) {
        controller.play();
      }
    });
  }

  void _onReelsUpdated(List<PostModel> reels) {
    _preloader.updateReels(reels);
    _preloader.onReelVisible(_currentIndex);
  }

  void _onPageChanged(int index, List<PostModel> reels) {
    if (_currentIndex == index) return;

    // احفظ الـ position للريل الحالي قبل ما نسيبه
    _saveCurrentReelPosition(reels);

    setState(() => _currentIndex = index);

    // ✅ Trigger preloader — بيعمل pre-initialize للـ controllers القادمة
    _preloader.onReelVisible(index);

    _checkLoadMore(index, reels.length);
  }

  // ✅ جديد: حفظ position الريل الحالي
  void _saveCurrentReelPosition(List<PostModel> reels) {
    if (_currentIndex < reels.length) {
      final currentReel = reels[_currentIndex];
      final controller = (_currentIndex == 0) ? widget.initialController : null;
      if (controller != null && controller.value.isInitialized) {
        final position = controller.value.position;
        if (position.inSeconds > 0) {
          _stateManager.savePosition(currentReel.postId, position);
        }
      }
    }
  }

  void _checkLoadMore(int currentIndex, int totalReels) {
    final remainingItems = totalReels - currentIndex - 1;
    if (remainingItems <= _loadMoreThreshold) {
      context.read<ReelsCubit>().fetchMoreReels();
    }
  }

  @override
  void dispose() {
    // احفظ position الفيديو الحالي قبل dispose
    _savePositionBeforeDispose();
    _preloader.pauseAll();
    _pageController?.dispose();
    super.dispose();
  }

  // ✅ جديد: حفظ الـ position لما صفحة الريلز تتقفل
  void _savePositionBeforeDispose() {
    final controller = widget.initialController;
    if (controller != null && controller.value.isInitialized) {
      final position = controller.value.position;
      if (position.inSeconds > 0) {
        _stateManager.savePosition(widget.initialPostId, position);
        debugPrint(
          '💾 Saved position ${position.inSeconds}s for ${widget.initialPostId} before dispose',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ReelsCubit, ReelsState>(
            listenWhen: (previous, current) =>
                previous.reels.length != current.reels.length,
            listener: (context, state) => _onReelsUpdated(state.reels),
          ),
          BlocListener<ReelsCubit, ReelsState>(
            listenWhen: (previous, current) =>
                previous.shareActionState != current.shareActionState &&
                current.shareActionState == CubitStates.initial,
            listener: _handleShareToast,
          ),
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
    if (state.reels.isEmpty && state.reelsState == CubitStates.loading) {
      return _buildLoading();
    }

    if (state.reels.isEmpty && state.reelsState == CubitStates.failure) {
      return _buildError(context, state.errorMessage);
    }

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

    // ✅ تأكد إن الـ preloader عنده أحدث قائمة
    _preloader.updateReels(state.reels);

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
    if (index >= state.reels.length) {
      return _buildLoadingMoreIndicator();
    }

    final reel = state.reels[index];
    final shouldInit = (index == _currentIndex || index == _currentIndex + 1);

    // ✅ استخدم الـ preloaded controller لو موجود — fast path
    // الـ index 0 بيستخدم الـ initialController اللي جاي من الـ home feed
    VideoPlayerController? controllerToPass;
    if (index == 0 && widget.initialController != null) {
      controllerToPass = widget.initialController;
    } else {
      controllerToPass = _preloader.getReadyController(reel.postId);
    }

    return ReelsItem(
      key: ValueKey('reel_item_${reel.postId}'),
      post: reel,
      isCurrentPage: index == _currentIndex,
      shouldInitialize: shouldInit,
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
