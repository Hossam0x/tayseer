import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/subscription_purchasing_button.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/subscription_success_dialog.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/user/user_profile/data/models/new_user_sub_model.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_packages_cubit.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_subscription_cubit.dart';
import 'package:tayseer/features/user/user_profile/presentation/widgets/user_current_sub_card.dart';
import 'package:tayseer/features/user/user_profile/presentation/widgets/user_selectable_sub_card.dart';
import 'package:tayseer/features/user/user_profile/presentation/widgets/user_upgrade_sub_card.dart';
import 'package:tayseer/my_import.dart';

class UserSubscriptionView extends StatelessWidget {
  const UserSubscriptionView({super.key});

  static final _skeletonSub = NewUserSubModel(
    id: '',
    appleProductId: '',
    subscriptionType: 'gold',
    subscriptionDurationType: 'weekly',
    isCurrentSub: false,
    numberOfChatRooms: 6,
    numberOfChatRoomMins: 60,
    numberOfLikes: 10,
    numberOfDailyGreetings: 3,
    numberOfFreeWeeklyReinforcements: 2,
    numberOfFreeMatchingRenables: 1,
    price: 99,
    currency: 'EGP',
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserSubscriptionCubit, UserSubscriptionState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == UserSubStatus.success) {
          showSubscriptionSuccessDialog(context);
        } else if (state.status == UserSubStatus.error && state.error != null) {
          AppToast.error(context, state.error!);
          context.read<UserSubscriptionCubit>().resetStatus();
        } else if (state.status == UserSubStatus.canceled) {
          context.read<UserSubscriptionCubit>().resetStatus();
        }
      },
      builder: (context, subState) {
        final cubit = context.read<UserSubscriptionCubit>();
        final isPurchasing = subState.status == UserSubStatus.purchasing;
        final packageTypeName = subState.packageType == SelectedPackage.elite
            ? context.tr('elite_package')
            : context.tr('pro_package');

        return BlocConsumer<UserPackagesCubit, UserPackagesState>(
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
                                    child: UserCurrentSubCard(sub: currentSub),
                                  ),
                                  if (upgradeSub != null) ...[
                                    Gap(16.h),
                                    UserUpgradeSubCard(sub: upgradeSub),
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
                                            child: UserSelectableSubCard(
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
    NewUserSubModel? upgradeSub,
    UserSubscriptionState state,
    List<NewUserSubModel> subs,
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
