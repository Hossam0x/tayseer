import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/recharge_cubit.dart';
import 'package:tayseer/features/advisor/wallet/view/cubit/recharge_state.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/recharge_header.dart';
import 'package:tayseer/features/advisor/wallet/view/widgets/recharge_packages_grid.dart';
import 'package:tayseer/my_import.dart';

class RechargeView extends StatelessWidget {
  const RechargeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RechargeCubit>()..fetchPackages(),
      child: Scaffold(
        backgroundColor: AppColors.kScaffoldColor,
        body: AdvisorBackground(
          child: Stack(
            children: [
              Positioned(
                top: 0, left: 0, right: 0,
                height: 105.h,
                child: Image.asset(AssetsData.homeBarBackgroundImage, fit: BoxFit.fill),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Gap(16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SimpleAppBar(title: context.tr('recharge_balance')),
                    ),
                    Gap(16.h),
                    const Expanded(child: _RechargeBody()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RechargeBody extends StatelessWidget {
  const _RechargeBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RechargeCubit, RechargeState>(
      builder: (context, state) {
        if (state.status == RechargeStatus.error) {
          return CustomErrorView(
            message: state.error,
            onRetry: () => context.read<RechargeCubit>().fetchPackages(),
          );
        }

        final selected = state.selectedIndex != null && state.packages.isNotEmpty
            ? state.packages[state.selectedIndex!]
            : null;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              const RechargeHeader(),
              Gap(20.h),
              const RechargePackagesGrid(),
              Gap(24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomBotton(
                  height: 54.h,
                  width: double.infinity,
                  title: selected == null
                      ? context.tr('choose_package_to_continue')
                      : context.tr('recharge_balance_amount', args: ['${selected.balance}']),
                  onPressed: selected == null ? null : () {},
                  useGradient: selected != null,
                  backGroundcolor: selected == null ? AppColors.inactiveColor : null,
                ),
              ),
              Gap(40.h),
            ],
          ),
        );
      },
    );
  }
}
