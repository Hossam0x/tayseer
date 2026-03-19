// lib/features/user/consultation_filtter/presentation/consultation_view.dart
//
// ✅ الصفحة الرئيسية للاستشارة — تعرض المستشارين وتستقبل نتيجة الفلتر

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
  const ConsultationStandalonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConsultationCubit(repo: ConsultationFiltterRepoImpl()),
      child: const ConsultationView(),
    );
  }
}

// ✅ الـ view الفعلية — محتاجة ConsultationCubit فوقها
class ConsultationView extends StatefulWidget {
  const ConsultationView({super.key});

  @override
  State<ConsultationView> createState() => _ConsultationViewState();
}

class _ConsultationViewState extends State<ConsultationView> {
  final ScrollController _scrollController = ScrollController();

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
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ConsultationCubit>().loadMore();
    }
  }

  @override
  void dispose() {
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
    return AdvisorBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            context.tr("consultation"),
            style: Styles.textStyle24Meduim.copyWith(
              color: AppColors.secondary700,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: SearchBarWithFilter(
                onTap: () => _openFilter(),
                isReadOnly: true,
                onFilterTap: _openFilter,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                // ✅ هنا برا BlocBuilder
                onRefresh: () => context.read<ConsultationCubit>().refresh(),
                child: BlocBuilder<ConsultationCubit, ConsultationState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.isFailure) {
                      // ✅ لازم يكون ListView عشان الـ RefreshIndicator يشتغل
                      return ListView(
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
                      );
                    }

                    if (state.isEmpty) {
                      return ListView(
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
                      );
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(), // ✅ مهم
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
