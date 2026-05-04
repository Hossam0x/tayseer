import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/shared/auth/view/widget/agreement_text.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/advisor_subscription_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/current_sub_card.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/restore_purchases_button.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/selectable_sub_card.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/subscription_purchasing_button.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/subscription_success_dialog.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/upgrade_sub_card.dart';
import 'package:tayseer/my_import.dart';

// ── ألوان Gold ──
const _goldDark = Color(0xFF8B6914);
const _goldBg2 = Color(0xFFD4A017);

// ── ألوان Elite ──
const _eliteDark = Color(0xFF4A1A8C);
const _eliteBg2 = Color(0xFF6A1FC2);

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
        final isElite = subState.packageType == SelectedPackage.elite;
        final isGold = !isElite;
        final packageTypeName = isElite
            ? context.tr('elite_package')
            : context.tr('pro_package');

        // ألوان حسب النوع
        final accentDark = isGold ? _goldDark : _eliteDark;
        final gradientBg2 = isGold ? _goldBg2 : _eliteBg2;

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
                              icon: Icon(
                                Icons.close,
                                color: Colors.white,
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
                                // ── أيقونة حسب النوع ──
                                _buildTypeIcon(isGold, accentDark),
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
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: Text(
                                    context.tr('auto_renew_note'),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Gap(10.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: const AgreementText(
                                    onWhiteBackground: false,
                                  ),
                                ),
                                if (Platform.isIOS) ...[
                                  Gap(4.h),
                                  const RestorePurchasesButton(),
                                ],
                                Gap(16.h),
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

  Widget _buildTypeIcon(bool isGold, Color accentDark) {
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
    NewAdvisorSubModel? upgradeSub,
    AdvisorSubscriptionState state,
    List<NewAdvisorSubModel> subs,
  ) {
    if (hasCurrentSub && upgradeSub != null) {
      final String label;
      if (upgradeSub.isWeekly) {
        label = context.tr('weekly');
      } else if (upgradeSub.isMonthly) {
        label = context.tr('monthly');
      } else {
        label = context.tr('three_months');
      }
      return '${context.tr('change_to')} $label';
    }
    return context.tr('pay');
  }
}
