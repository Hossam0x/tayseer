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
                top: 0,
                left: 0,
                right: 0,
                height: 105.h,
                child: Image.asset(
                  AssetsData.homeBarBackgroundImage,
                  fit: BoxFit.fill,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Gap(16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SimpleAppBar(
                        title: context.tr('recharge_balance'),
                      ),
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
    return BlocConsumer<RechargeCubit, RechargeState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == RechargeStatus.success) {
          _showSuccessDialog(context);
        } else if (state.status == RechargeStatus.error &&
            state.error != null) {
          _showErrorSnackBar(context, state.error!);
          context.read<RechargeCubit>().resetStatus();
        }
        // canceled: do nothing, just reset silently
        if (state.status == RechargeStatus.canceled) {
          context.read<RechargeCubit>().resetStatus();
        }
      },
      builder: (context, state) {
        if (state.status == RechargeStatus.error && state.packages.isEmpty) {
          return CustomErrorView(
            message: state.error,
            onRetry: () => context.read<RechargeCubit>().fetchPackages(),
          );
        }

        final selected =
            state.selectedIndex != null && state.packages.isNotEmpty
            ? state.packages[state.selectedIndex!]
            : null;

        final isPurchasing = state.status == RechargeStatus.purchasing;

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
                child: isPurchasing
                    ? _PurchasingButton()
                    : CustomBotton(
                        height: 54.h,
                        width: double.infinity,
                        title: selected == null
                            ? context.tr('choose_package_to_continue')
                            : context.tr(
                                'recharge_balance_amount',
                                args: ['${selected.balance}'],
                              ),
                        onPressed: selected == null
                            ? null
                            : () => context
                                  .read<RechargeCubit>()
                                  .purchaseSelectedPackage(),
                        useGradient: selected != null,
                        backGroundcolor: selected == null
                            ? AppColors.inactiveColor
                            : null,
                      ),
              ),
              Gap(40.h),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.kWhiteColor,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary400.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header with primary gradient ──
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 32.h),
                decoration: BoxDecoration(
                  gradient: AppColors.backgroundGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28.r),
                    topRight: Radius.circular(28.r),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 96.w,
                      height: 96.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Lottie.asset(
                        AssetsData.kSuccessMarriageAnimationsLottie,
                        repeat: false,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Gap(14.h),
                    Text(
                      context.tr('recharge_success_title'),
                      style: Styles.textStyle20Bold.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // ── Body ──
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 24.h),
                child: Column(
                  children: [
                    Text(
                      context.tr('recharge_success_subtitle'),
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap(20.h),
                    Divider(color: AppColors.secondary100, thickness: 1),
                    Gap(16.h),

                    // ── Go to wallet — CustomBotton ──
                    CustomBotton(
                      height: 52.h,
                      width: double.infinity,
                      title: context.tr('recharge_success_go_to_wallet'),
                      icon: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 18.w,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      useGradient: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    AppToast.error(context, message);
  }
}

class _PurchasingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.defaultGradient,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: SizedBox(
          width: 24.w,
          height: 24.w,
          child: const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }
}
