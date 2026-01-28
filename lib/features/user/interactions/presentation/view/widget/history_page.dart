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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InteractionsCubit>().fetchHistory(filter: widget.selectedFilter);
    });
  }

  @override
  void didUpdateWidget(Historypage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedFilter != widget.selectedFilter) {
      context.read<InteractionsCubit>().fetchHistory(filter: widget.selectedFilter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InteractionsCubit, InteractionsState>(
      builder: (context, state) {
        // ✅ حالة التحميل مع Skeleton
        if (state.historyState == CubitStates.loading) {
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

        // ✅ عرض البيانات مع Blur والزر الثابت
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w),
              child: GridView.builder(
                padding: EdgeInsets.only(
                  top: 16.h,
                  bottom: state.isSubscribed ? 20.h : 160.h, // ✅ مساحة إضافية للزر
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.7,
                ),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return InteractionProfileCard(
                    item: data[index],
                      showFavoriteIcon: widget.selectedFilter == "المفضلة",
                    forceBlur: !state.isSubscribed, // ✅ Blur إذا لم يكن مشترك
                  );
                },
              ),
            ),
            
            // ✅ الزر الثابت (يظهر فقط للمستخدمين غير المشتركين)
            if (!state.isSubscribed)
              const SubscriptionPromptOverlay(),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonLoading() {
    final dummyData = getDummyInteractionUsers(count: 8);

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
}