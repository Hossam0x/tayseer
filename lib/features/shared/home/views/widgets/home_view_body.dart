import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/upload_post_banner.dart';
import 'package:tayseer/features/advisor/add_post/view_model/upload_post/upload_post_cubit.dart';
import 'package:tayseer/features/advisor/add_post/view_model/upload_post/upload_post_state.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/view_model/home_state.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_app_bar.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_filter_section.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_search_bar.dart';
import 'package:tayseer/features/shared/home/views/widgets/advisor_status_home_banner.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/stories_section.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/shared/home/views/widgets/session_started_listener.dart';
import 'package:tayseer/my_import.dart';

class HomeViewBody extends StatefulWidget {
  final Function(bool isScrollingDown)? onScroll;

  const HomeViewBody({super.key, this.onScroll});

  @override
  State<HomeViewBody> createState() => HomeViewBodyState();
}

class HomeViewBodyState extends State<HomeViewBody> {
  late ScrollController _scrollController;
  late ScrollController _filterScrollController;
  double _lastOffset = 0;
  double _scrollDelta = 0;
  static const double _scrollThreshold = 20.0;

  // ✅ CHANGED: int بدل DateTime object
  int _lastScrollUpdateMs = 0;

  final StoriesCubit storiesCubit = getIt<StoriesCubit>();
  final HomeCubit homeCubit = getIt<HomeCubit>();
  final UploadPostCubit uploadPostCubit = getIt<UploadPostCubit>();

  final GlobalKey _filterSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _filterScrollController = ScrollController();
    storiesCubit.fetchStories(context: context);
    if (isAdvisor) storiesCubit.fetchMyStories();
    homeCubit.initHome();
    homeCubit.sessionStart();
  }

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void scrollToFilterSection() {
    final context = _filterSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        alignment: 0.0,
      );
    }

    if (_filterScrollController.hasClients) {
      _filterScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ✅ CHANGED: int milliseconds بدل DateTime object
  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final delta = currentOffset - _lastOffset;

    _scrollDelta += delta;

    if (_scrollDelta.abs() >= _scrollThreshold) {
      widget.onScroll?.call(_scrollDelta > 0);
      _scrollDelta = 0;
    }

    _lastOffset = currentOffset;

    // ✅ CHANGED: int بدل DateTime — أقل GC pressure
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - _lastScrollUpdateMs > 100) {
      _lastScrollUpdateMs = nowMs;
      context.read<LayoutCubit>().setHomeAtTop(currentOffset <= 0);
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      homeCubit.loadMorePosts();
    }
  }

  Future<void> scrollToTopAndRefresh() async {
    if (getIt<ConnectivityCubit>().isOffline) return;
    scrollToTop();
    VideoManager.instance.stopAll();
    await Future.wait([
      storiesCubit.fetchStories(context: context),
      homeCubit.refreshHome(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: storiesCubit),
        BlocProvider.value(value: homeCubit),
        BlocProvider.value(value: getIt<ConnectivityCubit>()),
        BlocProvider.value(value: uploadPostCubit),
      ],
      child: BlocListener<ConnectivityCubit, ConnectivityState>(
        listenWhen: (prev, curr) => !prev.isConnected && curr.isConnected,
        listener: (context, connState) {
          final storiesState = storiesCubit.state;
          if (storiesState.storiesState == CubitStates.failure ||
              storiesState.storiesList.isEmpty) {
            storiesCubit.fetchStories(context: context);
          }
        },
        child: RefreshIndicator(
          color: AppColors.kprimaryColor,
          onRefresh: () async {
            if (getIt<ConnectivityCubit>().isOffline) return;
            AudioService.instance.playRefreshSound();
            VideoManager.instance.stopAll();
            await Future.wait([
              storiesCubit.fetchStories(context: context),
              if (isAdvisor) storiesCubit.fetchMyStories(),
              homeCubit.refreshHome(),
            ]);
          },
          child: Stack(
            children: [
              CustomScrollView(
                physics: const ClampingScrollPhysics(),
                cacheExtent: 300,
                controller: _scrollController,
                slivers: [
                  const HomeAppBar(),
                  const HomeSearchBar(),
                  BlocBuilder<HomeCubit, HomeState>(
                    buildWhen: (prev, curr) =>
                        prev.currentAdvisorStatus != curr.currentAdvisorStatus,
                    builder: (context, state) => AdvisorStatusHomeBanner(
                      status: state.currentAdvisorStatus,
                    ),
                  ),
                  const StoriesSection(),

                  // ✅ CHANGED: BlocListener بدل BlocConsumer
                  SliverToBoxAdapter(
                    child:
                        BlocListener<UploadPostCubit, UploadPostProgressState>(
                          listener: (context, state) {
                            if (state.status == UploadPostStatus.success) {
                              homeCubit.refreshHome();
                            }
                          },
                          child: const UploadPostBanner(),
                        ),
                  ),

                  HomeFilterSection(
                    key: _filterSectionKey,
                    scrollController: _filterScrollController,
                  ),
                  HomePostFeed(
                    homeCubit: homeCubit,
                    scrollToTopCallback: scrollToFilterSection,
                  ),
                ],
              ),
              SessionStartedListener(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _filterScrollController.dispose();
    VideoManager.instance.stopAll();
    super.dispose();
  }
}
