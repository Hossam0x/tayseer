import 'package:tayseer/core/utils/video_playback_manager.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/home/views/widgets/home_app_bar.dart';
import 'package:tayseer/features/advisor/home/views/widgets/home_filter_section.dart';
import 'package:tayseer/features/advisor/home/views/widgets/home_post_feed.dart';
import 'package:tayseer/features/advisor/home/views/widgets/home_search_bar.dart';
import 'package:tayseer/features/advisor/stories/presentation/views/widgets/stories_section.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/my_import.dart';

class HomeViewBody extends StatefulWidget {
  final Function(bool isScrollingDown)? onScroll;

  const HomeViewBody({super.key, this.onScroll});

  @override
  State<HomeViewBody> createState() => HomeViewBodyState();
}

class HomeViewBodyState extends State<HomeViewBody> {
  late ScrollController _scrollController;
  double _lastOffset = 0;
  double _scrollDelta = 0;
  static const double _scrollThreshold = 20.0;
  final StoriesCubit storiesCubit = getIt<StoriesCubit>();
  final HomeCubit homeCubit = getIt<HomeCubit>();

  /// ميثود عشان نعمل scroll لفوق (زي فيسبوك)
  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    storiesCubit.fetchStories();
    homeCubit.fetchPosts();
    homeCubit.fetchNameAndImage();
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

    // Handle pagination
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      homeCubit.fetchPosts(loadMore: true);
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
          // ✅ التعديل هنا: نوقف أي فيديو شغال قبل ما نعمل ريفريش
          // ده بيضمن اننا نفضي الـ Decoders عشان نتجنب Error -12 والشاشة السودة
          VideoManager.instance.stopAll();

          await Future.wait([
            storiesCubit.fetchStories(),
            homeCubit.fetchPosts(),
          ]);
        },
        child: CustomScrollView(
          cacheExtent: 500.0,
          controller: _scrollController,
          slivers: [
            const HomeAppBar(notificationCount: 3),
            const HomeSearchBar(),
            const StoriesSection(),
            const HomeFilterSection(),
            HomePostFeed(homeCubit: homeCubit),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // ✅ يفضل كمان نوقف الفيديوهات لو خرجنا من الصفحة دي نهائياً
    VideoManager.instance.stopAll();
    super.dispose();
  }
}
