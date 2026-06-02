// lib/features/user/consultation_filtter/presentation/consultation_view.dart
//
// ✅ الصفحة الرئيسية للاستشارة — تعرض المستشارين وتستقبل نتيجة الفلتر

import 'dart:async';
import 'package:tayseer/core/utils/subscription_event_bus.dart';
import 'package:tayseer/features/filter/data/models/advisor_filter_request_model.dart';
import 'package:tayseer/features/filter/presentation/view/advisor_filter_view.dart';
import 'package:tayseer/features/user/consultation_filtter/data/consultation_repo/consultation_repo.dart';
import 'package:tayseer/features/user/consultation_filtter/data/models/advisor_model.dart';
import 'package:tayseer/features/user/consultation_filtter/presentation/consultation_filtter_cubit/consultation_filtter_cubit.dart';
import 'package:tayseer/features/user/consultation_filtter/presentation/consultation_filtter_cubit/consultation_filtter_state.dart';
import 'package:tayseer/features/user/consultation_filtter/presentation/widgets/advisor_consultation_card.dart';
import 'package:tayseer/features/user/consultation_filtter/presentation/widgets/search_bar_with_filter.dart';
import 'package:tayseer/my_import.dart';

// ✅ هذا الـ widget هو نقطة الدخول — بيوفر الـ BlocProvider
// استخدمه في الـ layout بدل ConsultationView مباشرة
class ConsultationStandalonePage extends StatelessWidget {
  /// لما بييجي من الـ settings يبقى true عشان يظهر زرار الرجوع
  final bool showBackButton;

  const ConsultationStandalonePage({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConsultationCubit(repo: ConsultationFiltterRepoImpl()),
      child: ConsultationView(showBackButton: showBackButton),
    );
  }
}

// ✅ الـ view الفعلية — محتاجة ConsultationCubit فوقها
class ConsultationView extends StatefulWidget {
  final bool showBackButton;

  const ConsultationView({super.key, this.showBackButton = false});

  @override
  State<ConsultationView> createState() => _ConsultationViewState();
}

class _ConsultationViewState extends State<ConsultationView> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription?
  _subscriptionSubscription; // ✅ للاستماع للتغييرات في الاشتراك

  @override
  void initState() {
    super.initState();
    // ✅ جيب أول صفحة عند الفتح بـ default request
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ConsultationCubit>().applyFilter(
          const AdvisorFilterRequestModel(page: 1),
        );
      }
    });
    _scrollController.addListener(_onScroll);

    // ✅ استمع للتغييرات في الاشتراك
    _subscriptionSubscription = SubscriptionEventBus
        .instance
        .onSubscriptionChanged
        .listen((_) {
          if (!mounted) return;
          // ✅ حدّث البيانات عند تغيير الاشتراك
          context.read<ConsultationCubit>().applyFilter(
            const AdvisorFilterRequestModel(page: 1),
          );
        });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ConsultationCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _subscriptionSubscription?.cancel(); // ✅ إلغاء الاستماع
    _scrollController.dispose();
    super.dispose();
  }

  // ✅ فتح شاشة الفلتر واستقبال الـ request الناتج
  Future<void> _openFilter() async {
    final request = await Navigator.push<AdvisorFilterRequestModel>(
      context,
      MaterialPageRoute(builder: (_) => const AdvisorFilterView()),
    );
    if (request != null && mounted) {
      context.read<ConsultationCubit>().applyFilter(request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: SizedBox(
                height: kToolbarHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        context.tr("consultation"),
                        style: Styles.textStyle24Meduim.copyWith(
                          color: AppColors.secondary700,
                        ),
                      ),
                    ),
                    Positioned(
                      left: isArabic ? 20.w : null,
                      right: isArabic ? null : 20.w,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRouter.kUserSessionsView,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.kprimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: AppImage(
                              AssetsData.consultatIcon,
                              width: 24.w,
                              height: 24.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.showBackButton)
                      Positioned(
                        left: isArabic ? null : 20.w,
                        right: isArabic ? 20.w : null,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20.w,
                              color: AppColors.secondary700,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: SearchBarWithFilter(
                onTap: () => _openFilter(),
                isReadOnly: true,
                onFilterTap: _openFilter,
              ),
            ),
            Expanded(
              child: BlocBuilder<ConsultationCubit, ConsultationState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.isFailure) {
                    return RefreshIndicator(
                      // ✅ هنا جوا
                      onRefresh: () =>
                          context.read<ConsultationCubit>().refresh(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 200.h),
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  state.errorMessage ??
                                      context.tr("something_went_wrong"),
                                  style: Styles.textStyle14.copyWith(
                                    color: AppColors.secondary400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16.h),
                                CustomBotton(
                                  title: context.tr("retry"),
                                  onPressed: () => context
                                      .read<ConsultationCubit>()
                                      .applyFilter(
                                        state.lastRequest ??
                                            const AdvisorFilterRequestModel(
                                              page: 1,
                                            ),
                                      ),
                                  width: 120.w,
                                  height: 44.h,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.isEmpty) {
                    return RefreshIndicator(
                      // ✅ هنا جوا
                      onRefresh: () =>
                          context.read<ConsultationCubit>().refresh(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: 200.h),
                          Center(
                            child: Text(
                              context.tr("no_advisors_found"),
                              style: Styles.textStyle16Bold.copyWith(
                                color: AppColors.secondary400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    // ✅ هنا جوا
                    onRefresh: () =>
                        context.read<ConsultationCubit>().refresh(),
                    child: ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      itemCount:
                          state.advisors.length + (state.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, __) => SizedBox(height: 16.h),
                      itemBuilder: (context, index) {
                        if (index == state.advisors.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final AdvisorFilterModel advisor =
                            state.advisors[index];
                        return AdvisorConsultationCard(
                          advisor: advisor,
                          isSelected: index == 0,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
