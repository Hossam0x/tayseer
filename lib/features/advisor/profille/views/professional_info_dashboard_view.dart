import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/data/models/analysis_item.dart';
import 'package:tayseer/features/advisor/profille/data/models/analytics_model.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile_state.dart';
import 'package:tayseer/features/advisor/profille/views/profile_visitors_view.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/analytics_chart.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost_button_sliver.dart';
import 'package:tayseer/my_import.dart';

class ProfessionalInfoDashboardView extends StatefulWidget {
  const ProfessionalInfoDashboardView({super.key});

  @override
  State<ProfessionalInfoDashboardView> createState() =>
      _ProfessionalInfoDashboardViewState();
}

class _ProfessionalInfoDashboardViewState
    extends State<ProfessionalInfoDashboardView> {
  @override
  void initState() {
    super.initState();
    // تحميل البيانات عند فتح الصفحة إذا لم تكن موجودة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ProfileCubit>();
      if (cubit.state.analyticsState == CubitStates.initial) {
        cubit.fetchAnalytics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              child: SafeArea(
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SimpleAppBar(
                            title: context.tr('professional_info_dashboard'),
                            isLargeTitle: true,
                          ),
                          Gap(24.h),

                          // مخطط التحليلات
                          state.analyticsState == CubitStates.loading
                              ? _buildChartLoading()
                              : AnalyticsChart(
                                  chartData: state.analytics?.chart ?? [],
                                ),
                          Gap(32.h),

                          // قسم التحليلات السفلية
                          state.analyticsState == CubitStates.loading
                              ? _buildAnalysisLoading()
                              : _buildAnalysisSection(
                                  state.analytics?.overview,
                                ),
                          Gap(32.h),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: BoostButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.kPackagesView,
                                );
                              },
                              text: context.tr('boost_button'),
                            ),
                          ),
                        ],
                      ),
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

  // Loading للرسم البياني
  Widget _buildChartLoading() {
    return Column(
      children: [
        // Legend Loading
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return Container(
              width: 60.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        ),
        Gap(16.h),

        // Chart Loading
        Container(
          height: 160.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary50),
          ),
        ),
      ],
    );
  }

  // Loading للتحليلات السفلية
  Widget _buildAnalysisLoading() {
    return Column(
      children: List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Container(
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      }),
    );
  }

  // قسم التحليلات السفلية
  Widget _buildAnalysisSection(AnalyticsOverview? overview) {
    final analysisItems = [
      AnalysisItem(
        title: context.tr('who_viewed_profile'),
        subtitle: '${overview?.views ?? 0}',
        isViewProfile: true,
      ),
      AnalysisItem(
        title: context.tr('views'),
        subtitle: '${overview?.views ?? 0}',
      ),
      AnalysisItem(
        title: context.tr('visits'),
        subtitle: '${overview?.visits ?? 0}',
      ),
      AnalysisItem(
        title: context.tr('new_followers'),
        subtitle: '${overview?.newFollowers ?? 0}',
      ),
      AnalysisItem(
        title: context.tr('interactions'),
        subtitle: '${overview?.interactions ?? 0}',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: analysisItems.map((item) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildAnalysisItem(item, overview),
            );
          }).toList(),
        ),
      ],
    );
  }

  // عنصر التحليل
  Widget _buildAnalysisItem(AnalysisItem item, AnalyticsOverview? overview) {
    return InkWell(
      onTap: item.isViewProfile
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileVisitorsView(),
                ),
              );
            }
          : null,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: item.isViewProfile ? AppColors.primary50 : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.kWhiteColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.title,
              style: item.isViewProfile
                  ? Styles.textStyle18SemiBold.copyWith(
                      color: AppColors.blackColor,
                    )
                  : Styles.textStyle16.copyWith(color: AppColors.secondary800),
            ),
            item.isViewProfile
                ? Row(
                    children: [
                      Text(
                        item.isViewProfile
                            ? overview?.visits.toString() ?? '0'
                            : item.subtitle,
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      Gap(8.w),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.secondary700,
                        size: 16.sp,
                      ),
                    ],
                  )
                : Text(
                    item.subtitle,
                    style: Styles.textStyle16.copyWith(
                      color: AppColors.primary900,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
