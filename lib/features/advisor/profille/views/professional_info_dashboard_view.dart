import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/dashboard/analytics_chart.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/upgrade_button.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/dashboard/dashboard_analysis_loading.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/dashboard/dashboard_analysis_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/dashboard/dashboard_chart_loading.dart';
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
              child: DecoratedBox(
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
                  buildWhen: (prev, curr) =>
                      prev.analyticsState != curr.analyticsState ||
                      prev.analytics != curr.analytics,
                  builder: (context, state) {
                    final isLoading =
                        state.analyticsState == CubitStates.loading;
                    final subscriptionType =
                        state.analytics?.subscriptionType ?? 'free';
                    final isUltra = subscriptionType == 'ultra';
                    final isGold = subscriptionType == 'gold';

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SimpleAppBar(
                            title: context.tr('professional_info_dashboard'),
                            isLargeTitle: true,
                          ),
                          Gap(24.h),
                          isLoading
                              ? const DashboardChartLoading()
                              : AnalyticsChart(
                                  chartData: state.analytics?.chart ?? [],
                                ),
                          Gap(32.h),
                          isLoading
                              ? const DashboardAnalysisLoading()
                              : DashboardAnalysisSection(
                                  overview: state.analytics?.overview,
                                ),
                          Gap(32.h),
                          if (!isUltra)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.w),
                              child: UpgradeButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRouter.kPackagesView,
                                  arguments: isGold ? {'initialPage': 2} : null,
                                ),
                                text: isGold
                                    ? context.tr('upgrade_to_elite_button')
                                    : context.tr('upgrade_button'),
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
}
