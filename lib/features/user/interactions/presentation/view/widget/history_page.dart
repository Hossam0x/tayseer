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

  const Historypage({super.key, this.selectedFilter = "نال إعجابك"});

  @override
  State<Historypage> createState() => HistorypageState(); // ✅ جعل الكلاس عام
}

class HistorypageState extends State<Historypage> { // ✅ جعل الكلاس عام
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InteractionsCubit>().fetchHistory(filter: widget.selectedFilter);
    });
  }

  @override
  void didUpdateWidget(Historypage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilter != widget.selectedFilter) {
      context.read<InteractionsCubit>().fetchHistory(filter: widget.selectedFilter);
      
      // ✅ scroll to top بعد تحميل الداتا بقليل
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
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

  // ✅ دالة عامة للـ scroll to top
  void scrollToTop() {
    if (!mounted) return;
    
    if (_scrollController.hasClients) {
      // ✅ التحقق من أن هناك محتوى للـ scroll
      if (_scrollController.position.maxScrollExtent > 0 || 
          _scrollController.position.pixels > 0) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    } else {
      // ✅ إذا الـ controller مش متصل بعد، نحاول تاني بعد frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

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

  // ✅ دالة الـ Refresh
  Future<void> _onRefresh() async {
    final cubit = context.read<InteractionsCubit>();
    
    if (widget.selectedFilter == "المفضلة") {
      // ✅ للمفضلة: نستخدم refreshFavorites اللي هيحذف المعلق ويعمل fetch
      await cubit.refreshFavorites();
    } else {
      // ✅ باقي الفلاتر: refresh عادي
      await cubit.fetchHistory(filter: widget.selectedFilter);
    }
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
                  state.historyErrorMessage ?? context.tr("error_occurred"), // ✅ ترجمة
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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: EmptyHistory(selectedFilter: widget.selectedFilter),
              ),
            ),
          );
        }

        return Stack(
          children: [
            RefreshIndicator.adaptive(
              onRefresh: _onRefresh,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                child: GridView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: 16.h,
                    bottom: state.isSubscribed ? 80.h : 160.h,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: data.length + (_isLoadingMore ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index >= data.length) {
                      return _buildLoadingCard();
                    }

                    return InteractionProfileCard(
                      item: data[index],
                      showFavoriteIcon: widget.selectedFilter == "المفضلة",
                      forceBlur: !state.isSubscribed,
                      showRibbon: widget.selectedFilter != "صادفتهم", // ✅ إخفاء الشعار في صفحة صادفتهم
                    );
                  },
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

    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 22.w),
        child: GridView.builder(
          padding: EdgeInsets.only(top: 16.h, bottom: 20.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.7,
          ),
          itemCount: dummyData.length,
          itemBuilder: (context, index) {
            return InteractionProfileCard(item: dummyData[index]);
          },
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