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

// ── ألوان Gold ──
const _goldDark = Color(0xFF8B6914);
const _goldBg2 = Color(0xFFD4A017);

// ── ألوان Elite ──
const _eliteDark = Color(0xFF4A1A8C);
const _eliteBg2 = Color(0xFF6A1FC2);

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
        final isElite = subState.packageType == SelectedPackage.elite;
        final isGold = !isElite;
        final packageTypeName = isElite
            ? context.tr('elite_package')
            : context.tr('pro_package');

        // ألوان حسب النوع
        final accentDark = isGold ? _goldDark : _eliteDark;
        final gradientBg2 = isGold ? _goldBg2 : _eliteBg2;

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
                  // ── خلفية الصورة ──
                  Positioned.fill(
                    child: Image.asset(
                      AssetsData.boostBackground,
                      fit: BoxFit.fill,
                    ),
                  ),
                  // ── gradient حسب النوع ──
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            gradientBg2.withOpacity(0.55),
                            gradientBg2.withOpacity(0.80),
                            gradientBg2,
                          ],
                          stops: const [0.0, 0.45, 0.70],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Column(
                      children: [
                        // ── زر الإغلاق ──
                        Padding(
                          padding: EdgeInsets.only(top: 10.h, right: 10.w),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
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
                                // ── أيقونة حسب النوع ──
                                _buildTypeIcon(isGold),
                                Gap(20.h),
                                Text(
                                  hasCurrentSub
                                      ? context.tr('change_subscription')
                                      : '${context.tr('subscribe_in')} $packageTypeName',
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Gap(8.h),
                                Text(
                                  context.tr('subscribe_with_us_opportunity'),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white.withOpacity(0.85),
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
                                              index: i,
                                              totalCount: isLoading
                                                  ? 2
                                                  : subs.length,
                                              isGoldTheme: isGold,
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
                                  SubscriptionPurchasingButton(
                                    backgroundColor: accentDark,
                                    borderRadius: 28.r,
                                  )
                                else if (!(hasCurrentSub && upgradeSub == null))
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54.h,
                                    child: ElevatedButton(
                                      onPressed:
                                          (isLoading ||
                                              (!hasCurrentSub && subs.isEmpty))
                                          ? null
                                          : () => cubit.purchaseSubscription(
                                              packagesState.subscriptions,
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: accentDark,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            28.r,
                                          ),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        _buttonLabel(
                                          context,
                                          hasCurrentSub,
                                          upgradeSub,
                                          subState,
                                          subs,
                                        ),
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                Gap(12.h),
                                Text(
                                  context.tr('auto_renew_note'),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
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

  Widget _buildTypeIcon(bool isGold) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppImage(
            isGold ? AssetsData.goldIcon : AssetsData.eliteIcon,
            width: 32.w,
            height: 32.w,
          ),
          SizedBox(width: 8.w),
          Text(
            isGold ? 'Gold' : 'Elite',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
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
