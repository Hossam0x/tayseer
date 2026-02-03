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
  State<Historypage> createState() => _HistorypageState();
}

class _HistorypageState extends State<Historypage> {
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
      _scrollController.jumpTo(0); // ✅ Reset scroll position
      context.read<InteractionsCubit>().fetchHistory(filter: widget.selectedFilter);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ دالة مراقبة الـ Scroll
  void _onScroll() {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = 200.0; // ✅ ابدأ التحميل قبل الوصول للنهاية بـ 200 بكسل

    if (currentScroll >= (maxScroll - delta)) {
      _loadMore();
    }
  }

  // ✅ دالة تحميل المزيد من البيانات
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      builder: (context, state) {
        // ✅ حالة التحميل مع Skeleton
        if (state.historyState == CubitStates.loading && 
            (state.historyData[widget.selectedFilter]?.isEmpty ?? true)) {
          return _buildSkeletonLoading();
        }

        // ✅ حالة الخطأ
        if (state.historyState == CubitStates.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.historyErrorMessage ?? 'حدث خطأ ما',
                  style: Styles.textStyle16,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                CustomBotton(
                  title: 'إعادة المحاولة',
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

        // ✅ جلب البيانات
        final data = state.historyData[widget.selectedFilter] ?? [];

        // ✅ حالة البيانات الفارغة
        if (data.isEmpty) {
          return EmptyHistory(selectedFilter: widget.selectedFilter);
        }

        // ✅ عرض البيانات مع Pagination
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              child: GridView.builder(
                controller: _scrollController, // ✅ ربط الـ ScrollController
                padding: EdgeInsets.only(
                  top: 16.h,
                  bottom: state.isSubscribed ? 80.h : 160.h, // ✅ مساحة للـ loader
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.7,
                ),
                itemCount: data.length + (_isLoadingMore ? 2 : 0), // ✅ إضافة skeleton loaders
                itemBuilder: (context, index) {
                  // ✅ عرض loader في النهاية
                  if (index >= data.length) {
                    return _buildLoadingCard();
                  }

                  return InteractionProfileCard(
                    item: data[index],
                    showFavoriteIcon: widget.selectedFilter == "المفضلة",
                    forceBlur: !state.isSubscribed,
                  );
                },
              ),
            ),
            
            // ✅ الزر الثابت للمستخدمين غير المشتركين
            if (!state.isSubscribed) const SubscriptionPromptOverlay(),
          ],
        );
      },
    );
  }

  // ✅ Skeleton loader للتحميل الأولي
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

  // ✅ Loading card أثناء Pagination
  Widget _buildLoadingCard() {
    return Skeletonizer(
      enabled: true,
      child: InteractionProfileCard(
        item: getDummyInteractionUsers(count: 1).first,
      ),
    );
  }
}