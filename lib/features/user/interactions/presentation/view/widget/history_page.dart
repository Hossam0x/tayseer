import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/user/interactions/presentation/Interactions_cubit/interactions_state.dart';
import 'package:tayseer/features/user/interactions/presentation/view/get_dummy_interaction.dart';
import 'package:tayseer/features/user/interactions/presentation/view/subscription_prompt_overlay.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/empty_History.dart';
import 'package:tayseer/features/user/interactions/presentation/view/widget/interaction_profilecard.dart';
import 'package:tayseer/my_import.dart';
import '../../Interactions_cubit/interactions_cubit.dart';

class Historypage extends StatefulWidget {
  final String selectedFilter;
  const Historypage({super.key, this.selectedFilter = ""});

  @override
  State<Historypage> createState() => HistorypageState();
}

class HistorypageState extends State<Historypage> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final filterKey = widget.selectedFilter.isEmpty 
            ? "liked_you" 
            : widget.selectedFilter;
        
        context.read<InteractionsCubit>().fetchHistory(filter: filterKey);
      }
    });
  }

  // ✅ إضافة هذه الدالة
  @override
  void didUpdateWidget(Historypage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // ✅ لو الفلتر اتغير، اعمل reload
    if (oldWidget.selectedFilter != widget.selectedFilter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final filterKey = widget.selectedFilter.isEmpty 
              ? "liked_you" 
              : widget.selectedFilter;
          
          context.read<InteractionsCubit>().fetchHistory(filter: filterKey);
          
          // ✅ اعمل scroll to top
          scrollToTop();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToTop() {
    if (!mounted) return;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // void scrollToTop() {
  //   if (!mounted) return;
  //   if (_scrollController.hasClients) {
  //     if (_scrollController.position.maxScrollExtent > 0 || 
  //         _scrollController.position.pixels > 0) {
  //       _scrollController.animateTo(
  //         0,
  //         duration: const Duration(milliseconds: 500),
  //         curve: Curves.easeInOut,
  //       );
  //     }
  //   } else {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted && _scrollController.hasClients) {
  //         _scrollController.jumpTo(0);
  //       }
  //     });
  //   }
  // }

  void _onScroll() {
    if (_isLoadingMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = 200.0;
    if (currentScroll >= (maxScroll - delta)) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    final cubit = context.read<InteractionsCubit>();
    final hasMore = cubit.state.historyHasMore[widget.selectedFilter] ?? false;
    if (!hasMore) return;

    setState(() => _isLoadingMore = true);
    await cubit.loadMoreHistory(filter: widget.selectedFilter);
    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

Future<void> _onRefresh() async {
    final cubit = context.read<InteractionsCubit>();
    // ✅ مقارنة بالمفتاح
    if (widget.selectedFilter == "favorites") {
      await cubit.refreshFavorites();
    } else {
      await cubit.fetchHistory(filter: widget.selectedFilter);
    }
  }

  // ✅ دالة لتحديد عدد الأعمدة حسب نوع الجهاز
  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600; // تحديد التابلت
    return isTablet ? 3 : 2; // 3 أعمدة للتابلت، 2 للموبايل
  }

  // ✅ دالة لتحديد childAspectRatio حسب عدد الأعمدة
  double _getChildAspectRatio(int crossAxisCount) {
    return crossAxisCount == 3 ? 0.65 : 0.7;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      builder: (context, state) {
        if (state.historyState == CubitStates.loading &&
            (state.historyData[widget.selectedFilter]?.isEmpty ?? true)) {
          return _buildSkeletonLoading();
        }

        if (state.historyState == CubitStates.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.historyErrorMessage ?? context.tr("error_occurred"),
                  style: Styles.textStyle16,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                CustomBotton(
                  title: context.tr("retry"),
                  onPressed: () {
                    context.read<InteractionsCubit>().fetchHistory(
                          filter: widget.selectedFilter,
                        );
                  },
                ),
              ],
            ),
          );
        }

        final data = state.historyData[widget.selectedFilter] ?? [];
        if (data.isEmpty) {
          return RefreshIndicator.adaptive(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyHistory(selectedFilter: widget.selectedFilter),
                ),
              ],
            ),
          );
        }

        // ✅ حساب عدد الأعمدة
        final crossAxisCount = _getCrossAxisCount(context);
        final childAspectRatio = _getChildAspectRatio(crossAxisCount);

        return Stack(
          children: [
            RefreshIndicator.adaptive(
              onRefresh: _onRefresh,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // ✅ Top Spacing
                    SliverPadding(
                      padding: EdgeInsets.only(top: 16.h),
                      sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                    ),

                    // ✅ Grid Items - Responsive
                    SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount, // ✅ ديناميكي
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: childAspectRatio, // ✅ ديناميكي
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= data.length) {
                            return _buildLoadingCard();
                          }
                          return
                           InteractionProfileCard(
                            item: data[index],
                            showFavoriteIcon: widget.selectedFilter == "favorites",
                            forceBlur: !state.isSubscribed,
                            showRibbon: widget.selectedFilter != "met_them",
                          );
                        },
                        childCount: data.length + (_isLoadingMore ? 2 : 0),
                      ),
                    ),

                    // ✅ Bottom Spacing
                    SliverPadding(
                      padding: EdgeInsets.only(
                        bottom: state.isSubscribed ? 80.h : 160.h,
                      ),
                      sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
                    ),
                  ],
                ),
              ),
            ),
            if (!state.isSubscribed) const SubscriptionPromptOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonLoading() {
    final dummyData = getDummyInteractionUsers(count: 6);
    final crossAxisCount = _getCrossAxisCount(context);
    final childAspectRatio = _getChildAspectRatio(crossAxisCount);

    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(top: 16.h),
              sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // ✅ ديناميكي
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: childAspectRatio, // ✅ ديناميكي
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return InteractionProfileCard(item: dummyData[index]);
                },
                childCount: dummyData.length,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.only(bottom: 20.h),
              sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Skeletonizer(
      enabled: true,
      child: InteractionProfileCard(
        item: getDummyInteractionUsers(count: 1).first,
      ),
    );
  }
}