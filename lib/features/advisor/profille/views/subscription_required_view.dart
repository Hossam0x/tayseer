import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_cubit.dart';
import 'package:tayseer/features/advisor/profille/views/cubit/profile/profile_state.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/boost/upgrade_button.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/dashboard/analytics_chart.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/dashboard/dashboard_analysis_loading.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/dashboard/dashboard_analysis_section.dart';
import 'package:tayseer/features/advisor/profille/views/widgets/dashboard/dashboard_chart_loading.dart';
import 'package:tayseer/my_import.dart';

/// Shown when a free user tries to access statistics.
/// After subscribing and returning, it refreshes and shows real stats.
class SubscriptionRequiredView extends StatefulWidget {
  const SubscriptionRequiredView({super.key});

  @override
  State<SubscriptionRequiredView> createState() =>
      _SubscriptionRequiredViewState();
}

class _SubscriptionRequiredViewState extends State<SubscriptionRequiredView> {
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
              height: 110.h,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AssetsData.homeBarBackgroundImage),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                child: BlocBuilder<ProfileCubit, ProfileState>(
                  buildWhen: (prev, curr) =>
                      prev.analyticsState != curr.analyticsState ||
                      prev.analytics != curr.analytics,
                  builder: (context, state) {
                    final subscriptionType =
                        state.analytics?.subscriptionType ?? 'free';
                    final isFree = subscriptionType == 'free';
                    final isLoading =
                        state.analyticsState == CubitStates.loading;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SimpleAppBar(title: ''),
                        Gap(8.h),
                        if (isFree || isLoading)
                          Expanded(
                            child: _SubscriptionRequiredContent(
                              isLoading: isLoading,
                              onUpgrade: () => _goToPackages(context),
                            ),
                          )
                        else
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isLoading
                                      ? const DashboardChartLoading()
                                      : AnalyticsChart(
                                          chartData:
                                              state.analytics?.chart ?? [],
                                        ),
                                  Gap(32.h),
                                  isLoading
                                      ? const DashboardAnalysisLoading()
                                      : DashboardAnalysisSection(
                                          overview: state.analytics?.overview,
                                        ),
                                  Gap(32.h),
                                  if (subscriptionType == 'gold')
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 30.w,
                                      ),
                                      child: UpgradeButton(
                                        text: context.tr(
                                          'upgrade_to_elite_button',
                                        ),
                                        onPressed: () => _goToPackages(
                                          context,
                                          initialPage: 2,
                                        ),
                                      ),
                                    ),
                                  Gap(20.h),
                                ],
                              ),
                            ),
                          ),
                      ],
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

  Future<void> _goToPackages(BuildContext context, {int? initialPage}) async {
    await Navigator.pushNamed(
      context,
      AppRouter.kPackagesView,
      arguments: initialPage != null ? {'initialPage': initialPage} : null,
    );
    // Refresh analytics after returning from packages
    if (mounted) {
      context.read<ProfileCubit>().fetchAnalytics();
    }
  }
}

class _SubscriptionRequiredContent extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onUpgrade;

  const _SubscriptionRequiredContent({
    required this.isLoading,
    required this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100.w,
          height: 100.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(245, 192, 3, 1),
                Color.fromRGBO(228, 78, 108, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            Icons.bar_chart_rounded,
            size: 50.sp,
            color: Colors.white,
          ),
        ),
        Gap(24.h),
        Text(
          context.tr('subscription_required_title'),
          style: Styles.textStyle24SemiBold,
          textAlign: TextAlign.center,
        ),
        Gap(12.h),
        Text(
          context.tr('subscription_required_desc'),
          style: Styles.textStyle16.copyWith(color: AppColors.secondary600),
          textAlign: TextAlign.center,
        ),
        Gap(40.h),
        if (!isLoading)
          UpgradeButton(
            text: context.tr('upgrade_button'),
            onPressed: onUpgrade,
          ),
      ],
    );
  }
}
