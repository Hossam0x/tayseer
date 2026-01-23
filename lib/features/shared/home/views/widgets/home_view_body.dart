import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/shared/home/views/widgets/anonymous_mode_banner.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_app_bar.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_filter_section.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_post_feed.dart';
import 'package:tayseer/features/shared/home/views/widgets/home_search_bar.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/stories_section.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/shared/home/views/widgets/session_started_listener.dart';
import 'package:tayseer/my_import.dart';
// تأكد من عمل import لملف SessionStartedListener إذا كان في ملف منفصل
// import 'path/to/session_started_listener.dart';

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

  final StoriesCubit storiesCubit = getIt<StoriesCubit>();
  final HomeCubit homeCubit = getIt<HomeCubit>();

  final GlobalKey _filterSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _filterScrollController = ScrollController();

    storiesCubit.fetchStories();
    homeCubit.initHome();

    // ✅ 1. تفعيل الاستماع للسوكيت عند فتح الصفحة
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

  void _scrollListener() {
    final currentOffset = _scrollController.offset;
    final delta = currentOffset - _lastOffset;

    _scrollDelta += delta;

    if (_scrollDelta.abs() >= _scrollThreshold) {
      widget.onScroll?.call(_scrollDelta > 0);
      _scrollDelta = 0;
    }

    _lastOffset = currentOffset;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      homeCubit.loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: storiesCubit),
        BlocProvider.value(value: homeCubit),
      ],
      child: RefreshIndicator(
        color: AppColors.kprimaryColor,
        onRefresh: () async {
          VideoManager.instance.stopAll();
          await Future.wait([
            storiesCubit.fetchStories(),
            homeCubit.refreshHome(),
          ]);
        },
        child: CustomScrollView(

          physics: const ClampingScrollPhysics(),
          cacheExtent: 500.0,
          controller: _scrollController,
          slivers: [
            const HomeAppBar(notificationCount: 3),
            const HomeSearchBar(),
      // ✅ 2. استخدام Stack لدمج الليسنر مع الشاشة
      child: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.kprimaryColor,
            onRefresh: () async {
              VideoManager.instance.stopAll();
              await Future.wait([
                storiesCubit.fetchStories(),
                homeCubit.refreshHome(),
              ]);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              cacheExtent: 500.0,
              controller: _scrollController,
              slivers: [
                const HomeAppBar(notificationCount: 3),
                const HomeSearchBar(),

                if (isUser)
                  const SliverToBoxAdapter(child: AnonymousModeBanner()),

                const StoriesSection(),
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
          ),

          // ✅ إضافة الليسنر هنا
          const SessionStartedListener(),
        ],
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
