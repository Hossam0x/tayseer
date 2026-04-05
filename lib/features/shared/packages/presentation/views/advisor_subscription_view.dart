import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/advisor_subscription_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/current_sub_card.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/selectable_sub_card.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/subscription_purchasing_button.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/subscription_success_dialog.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/upgrade_sub_card.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSubscriptionView extends StatelessWidget {
  const AdvisorSubscriptionView({super.key});

  static final _skeletonSub = NewAdvisorSubModel(
    id: '',
    appleProductId: '',
    subscriptionType: 'gold',
    subscriptionDurationType: 'weekly',
    isCurrentSub: false,
    numberOfSessions: 5,
    sessionsAppInterestPercentage: 20,
    numberOfChatRooms: -1,
    numberOfMonthlyReinforcements: 4,
    numberOfMonthlyEvents: 1,
    eventsAppInterestPercentage: 20,
    price: 99,
    currency: 'EGP',
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdvisorSubscriptionCubit, AdvisorSubscriptionState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == AdvisorSubStatus.success) {
          showSubscriptionSuccessDialog(context);
        } else if (state.status == AdvisorSubStatus.error &&
            state.error != null) {
          AppToast.error(context, state.error!);
          context.read<AdvisorSubscriptionCubit>().resetStatus();
        } else if (state.status == AdvisorSubStatus.canceled) {
          context.read<AdvisorSubscriptionCubit>().resetStatus();
        }
      },
      builder: (context, subState) {
        final cubit = context.read<AdvisorSubscriptionCubit>();
        final isPurchasing = subState.status == AdvisorSubStatus.purchasing;
        final packageTypeName = subState.packageType == SelectedPackage.elite
            ? context.tr('elite_package')
            : context.tr('pro_package');

        return BlocConsumer<PackagesCubit, PackagesState>(
          listenWhen: (p, c) => p.isLoading && !c.isLoading,
          listener: (context, packagesState) =>
              cubit.initSelection(packagesState.subscriptions),
          builder: (context, packagesState) {
            final isLoading = packagesState.isLoading;
            final subs = cubit.getSubscriptionsForPackage(
              packagesState.subscriptions,
            );
            final currentSub = isLoading
                ? null
                : cubit.getCurrentSub(packagesState.subscriptions);
            final upgradeSub = isLoading
                ? null
                : cubit.getUpgradeSub(packagesState.subscriptions);
            final hasCurrentSub = currentSub != null;

            return Scaffold(
              body: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      AssetsData.boostBackground,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.primaryPink.withOpacity(0.7),
                            AppColors.primary100,
                          ],
                          stops: const [0.0, 0.4, 0.65],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10.h, right: 10.w),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                color: AppColors.kWhiteColor,
                                size: 24.w,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              children: [
                                Gap(10.h),
                                AppImage(
                                  AssetsData.logoIcon,
                                  width: 190.h,
                                  color: AppColors.primary100,
                                ),
                                Gap(40.h),
                                Text(
                                  hasCurrentSub
                                      ? context.tr('change_subscription')
                                      : '${context.tr('subscribe_in')} $packageTypeName',
                                  style: Styles.textStyle24Bold.copyWith(
                                    color: AppColors.secondary800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Gap(8.h),
                                Text(
                                  context.tr('subscribe_with_us_opportunity'),
                                  style: Styles.textStyle16.copyWith(
                                    color: AppColors.secondary800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Gap(30.h),
                                if (hasCurrentSub) ...[
                                  Skeletonizer(
                                    enabled: isLoading,
                                    child: CurrentSubCard(sub: currentSub),
                                  ),
                                  if (upgradeSub != null) ...[
                                    Gap(16.h),
                                    UpgradeSubCard(sub: upgradeSub),
                                  ],
                                ] else
                                  Skeletonizer(
                                    enabled: isLoading,
                                    child: Column(
                                      children: List.generate(
                                        isLoading ? 2 : subs.length,
                                        (i) {
                                          final sub = isLoading
                                              ? _skeletonSub
                                              : subs[i];
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom: 16.h,
                                            ),
                                            child: SelectableSubCard(
                                              sub: sub,
                                              isSelected:
                                                  !isLoading &&
                                                  subState.selectedDurationIndex ==
                                                      i,
                                              onTap: isLoading
                                                  ? null
                                                  : () => cubit.selectDuration(
                                                      i,
                                                      packagesState
                                                          .subscriptions,
                                                    ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                Gap(30.h),
                                if (isPurchasing)
                                  const SubscriptionPurchasingButton()
                                else if (!(hasCurrentSub && upgradeSub == null))
                                  CustomBotton(
                                    height: 54.h,
                                    width: double.infinity,
                                    title: _buttonLabel(
                                      context,
                                      hasCurrentSub,
                                      upgradeSub,
                                      subState,
                                      subs,
                                    ),
                                    onPressed:
                                        (isLoading ||
                                            (!hasCurrentSub && subs.isEmpty))
                                        ? null
                                        : () => cubit.purchaseSubscription(
                                            packagesState.subscriptions,
                                          ),
                                    useGradient: true,
                                  ),
                                Gap(30.h),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _buttonLabel(
    BuildContext context,
    bool hasCurrentSub,
    NewAdvisorSubModel? upgradeSub,
    AdvisorSubscriptionState state,
    List<NewAdvisorSubModel> subs,
  ) {
    if (hasCurrentSub && upgradeSub != null) {
      final label = upgradeSub.isMonthly
          ? context.tr('monthly')
          : context.tr('weekly');
      return '${context.tr('change_to')} $label';
    }
    return context.tr('pay');
  }
}
