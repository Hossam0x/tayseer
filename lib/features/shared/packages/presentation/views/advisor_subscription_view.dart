import 'package:flutter/gestures.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/functions/url_launcher.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_restore_conflict_dialog.dart';
import 'package:tayseer/features/shared/auth/view/widget/agreement_text.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/advisor_subscription_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/current_sub_card.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/restore_purchases_button.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/save_card_note.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/selectable_sub_card.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/subscription_purchasing_button.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/subscription_success_dialog.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/upgrade_sub_card.dart';
import 'package:tayseer/features/shared/packages/presentation/widgets/payment_method_sheet.dart';
import 'package:tayseer/features/user/questions/presentation/views/add_phone_view.dart';
import 'package:tayseer/my_import.dart';

// ── ألوان Gold ──
const _goldDark = Color(0xFF8B6914);
const _goldBg2 = Color(0xFFD4A017);

// ── ألوان Elite ──
const _eliteDark = Color(0xFF4A1A8C);
const _eliteBg2 = Color(0xFF6A1FC2);

class AdvisorSubscriptionView extends StatefulWidget {
  const AdvisorSubscriptionView({
    super.key,
    this.firstName,
    this.lastName,
    this.phone,
  });

  /// Paymob billing info collected upfront (Android only).
  /// When provided the Android payment flow starts automatically once packages load.
  final String? firstName;
  final String? lastName;
  final String? phone;

  @override
  State<AdvisorSubscriptionView> createState() =>
      _AdvisorSubscriptionViewState();
}

class _AdvisorSubscriptionViewState extends State<AdvisorSubscriptionView> {
  bool _autoTriggered = false;

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

  /// Called once packages have loaded — triggers Android Paymob flow directly
  /// when name/phone were collected upfront from the payment sheet.
  void _maybeAutoTriggerAndroid(
    BuildContext context,
    List<NewAdvisorSubModel> allSubs,
  ) {
    if (_autoTriggered) return;
    if (!Platform.isAndroid) return;
    if (widget.firstName == null ||
        widget.lastName == null ||
        widget.phone == null)
      return;
    _autoTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AdvisorSubscriptionCubit>().purchaseSubscriptionAndroid(
        allSubs,
        context: context,
        firstName: widget.firstName,
        lastName: widget.lastName,
        phone: widget.phone,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdvisorSubscriptionCubit, AdvisorSubscriptionState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == AdvisorSubStatus.success) {
          final isGold = state.packageType != SelectedPackage.elite;
          showSubscriptionSuccessDialog(context, isGold: isGold);
        } else if (state.status == AdvisorSubStatus.needsTransfer) {
          // ✅ الاشتراك على account تاني — اعرض dialog للـ transfer
          final purchaseId = state.transferPurchaseId ?? '';
          showRestoreConflictDialog(
            context,
            message: context.tr('restore_conflict_desc'),
            onTransfer: () => context
                .read<AdvisorSubscriptionCubit>()
                .transferSubscription(purchaseId),
          );
        } else if (state.status == AdvisorSubStatus.profileIncomplete) {
          // ✅ الـ profile ناقص → روح لصفحة إضافة رقم الموبايل
          context.read<AdvisorSubscriptionCubit>().resetStatus();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final navContext = context;
            Navigator.push(
              navContext,
              MaterialPageRoute(
                builder: (_) => AddPhoneViewFromTicket(
                  onPhoneAdded: () {
                    final allSubs = navContext
                        .read<PackagesCubit>()
                        .state
                        .subscriptions;
                    navContext
                        .read<AdvisorSubscriptionCubit>()
                        .purchaseSubscriptionAndroid(
                          allSubs,
                          context: navContext,
                        );
                  },
                ),
              ),
            );
          });
        } else if (state.status == AdvisorSubStatus.error &&
            state.error != null) {
          AppToast.error(context, context.tr(state.error!));
          context.read<AdvisorSubscriptionCubit>().resetStatus();
        } else if (state.status == AdvisorSubStatus.canceled) {
          AppToast.show(
            context,
            message: context.tr('purchase_cancelled'),
            type: ToastType.info,
          );
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
          listener: (context, packagesState) {
            cubit.initSelection(packagesState.subscriptions);
            // ✅ Auto-trigger Android Paymob when name/phone were pre-collected
            _maybeAutoTriggerAndroid(context, packagesState.subscriptions);
          },
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
            final downgradeSub = isLoading
                ? null
                : cubit.getDowngradeSub(packagesState.subscriptions);
            final changeSub = Platform.isAndroid
                ? null
                : (upgradeSub ?? downgradeSub);
            final isUpgradeAction = upgradeSub != null;
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
                                  if (changeSub != null) ...[
                                    Gap(16.h),
                                    UpgradeSubCard(
                                      sub: changeSub,
                                      isUpgrade: isUpgradeAction,
                                    ),
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
                                // ── Save Card Note (Android only) ──
                                if (Platform.isAndroid &&
                                    !isPurchasing &&
                                    !(hasCurrentSub && changeSub == null)) ...[
                                  const SaveCardNote(),
                                  Gap(16.h),
                                ],
                                if (isPurchasing)
                                  SubscriptionPurchasingButton(
                                    backgroundColor: accentDark,
                                    borderRadius: 28.r,
                                  )
                                else if (!(hasCurrentSub && changeSub == null))
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54.h,
                                    child: ElevatedButton(
                                      onPressed:
                                          (isLoading ||
                                              (!hasCurrentSub && subs.isEmpty))
                                          ? null
                                          : () => showPaymentMethodSheet(
                                              context,
                                              onInAppPurchase: () =>
                                                  cubit.purchaseSubscription(
                                                    packagesState.subscriptions,
                                                  ),
                                              onPaymobSelected: (fn, ln, ph) =>
                                                  cubit
                                                      .purchaseSubscriptionAndroid(
                                                        packagesState
                                                            .subscriptions,
                                                        context: context,
                                                        firstName: fn,
                                                        lastName: ln,
                                                        phone: ph,
                                                      ),
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
                                          changeSub,
                                          isUpgradeAction,
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
                                // ── auto-renew note + EULA (iOS only) ──
                                if (Platform.isIOS) ...[
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
                                  // ── EULA link مطلوب من Apple لـ auto-renewable subscriptions ──
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                    ),
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: context.tr(
                                              'subscription_eula_prefix',
                                            ),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.white.withOpacity(
                                                0.85,
                                              ),
                                            ),
                                          ),
                                          TextSpan(
                                            text: context.tr(
                                              'subscription_eula_link',
                                            ),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.white,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                ApplaunchUrl(
                                                  Uri.parse(
                                                    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                                                  ),
                                                );
                                              },
                                          ),
                                          TextSpan(
                                            text: context.tr(
                                              'subscription_eula_separator',
                                            ),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.white.withOpacity(
                                                0.85,
                                              ),
                                            ),
                                          ),
                                          TextSpan(
                                            text: context.tr(
                                              'subscription_privacy_link',
                                            ),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.white,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                ApplaunchUrl(
                                                  Uri.parse(
                                                    'https://m.tayser-app.com/privacy-policy-2/',
                                                  ),
                                                );
                                              },
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Gap(8.h),
                                ],
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
    NewAdvisorSubModel? changeSub,
    bool isUpgrade,
    AdvisorSubscriptionState state,
    List<NewAdvisorSubModel> subs,
  ) {
    if (hasCurrentSub && changeSub != null) {
      final String durationLabel;
      if (changeSub.isWeekly) {
        durationLabel = context.tr('weekly');
      } else if (changeSub.isMonthly) {
        durationLabel = context.tr('monthly');
      } else {
        durationLabel = context.tr('three_months');
      }
      final action = isUpgrade
          ? context.tr('upgrade')
          : context.tr('downgrade');
      return '$action ${context.tr('to')} $durationLabel';
    }
    return context.tr('pay');
  }
}
