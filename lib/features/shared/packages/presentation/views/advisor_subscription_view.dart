import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/core/functions/country_helper.dart';
import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/advisor_subscription_cubit.dart';
import 'package:tayseer/features/shared/packages/presentation/view_model/packages_cubit.dart';
import 'package:tayseer/my_import.dart';

class AdvisorSubscriptionView extends StatelessWidget {
  const AdvisorSubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdvisorSubscriptionCubit, AdvisorSubscriptionState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (context, state) {
        if (state.status == AdvisorSubStatus.success) {
          _showSuccessDialog(context);
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

                                // ── حالة مشترك: current card + upgrade card ──
                                if (hasCurrentSub) ...[
                                  Skeletonizer(
                                    enabled: isLoading,
                                    child: _CurrentSubCard(sub: currentSub),
                                  ),
                                  if (upgradeSub != null) ...[
                                    Gap(16.h),
                                    _UpgradeCard(sub: upgradeSub),
                                  ],
                                ]
                                // ── حالة مش مشترك: اختيار من الكارتين ──
                                else
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
                                            child: _SelectableCard(
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
                                  _PurchasingButton()
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  gradient: AppColors.backgroundGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28.r),
                    topRight: Radius.circular(28.r),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 120.w,
                      child: Lottie.asset(
                        AssetsData.kSuccessMarriageAnimationsLottie,
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Gap(14.h),
                    Text(
                      context.tr('subscription_success_title'),
                      style: Styles.textStyle20Bold.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 22.h, 24.w, 24.h),
                child: Column(
                  children: [
                    Text(
                      context.tr('subscription_success_subtitle'),
                      style: Styles.textStyle14.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Gap(16.h),
                    CustomBotton(
                      height: 52.h,
                      width: double.infinity,
                      title: context.tr('done'),
                      onPressed: () {
                        Navigator.pop(context);
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
}

// ─── Current Sub Card (مشترك حالياً) ─────────────────────────────────────────
class _CurrentSubCard extends StatelessWidget {
  final NewAdvisorSubModel sub;
  const _CurrentSubCard({required this.sub});

  @override
  Widget build(BuildContext context) {
    final currency = sub.currency ?? getCurrency();
    final durationLabel = sub.isWeekly
        ? context.tr('weekly')
        : context.tr('monthly');
    final priceText = sub.price != null ? '${sub.price} $currency' : '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary500.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary500, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          durationLabel,
                          style: Styles.textStyle16SemiBold.copyWith(
                            color: AppColors.primary600,
                          ),
                        ),
                        Gap(8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary500,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            context.tr('current_subscription'),
                            style: Styles.textStyle10.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (priceText.isNotEmpty) ...[
                      Gap(4.h),
                      Text(
                        priceText,
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.primary600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary500,
                size: 22.sp,
              ),
            ],
          ),
          if (sub.subscriptionExpiresAt != null) ...[
            Gap(10.h),
            _ExpiryBadge(expiresAt: sub.subscriptionExpiresAt!),
          ],
        ],
      ),
    );
  }
}

// ─── Upgrade Card (الترقية المتاحة) ──────────────────────────────────────────
class _UpgradeCard extends StatelessWidget {
  final NewAdvisorSubModel sub;
  const _UpgradeCard({required this.sub});

  @override
  Widget build(BuildContext context) {
    final currency = sub.currency ?? getCurrency();
    final durationLabel = sub.isWeekly
        ? context.tr('weekly')
        : context.tr('monthly');
    final priceText = sub.price != null
        ? '${sub.price} $currency'
        : context.tr('price_not_available');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary200,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      durationLabel,
                      style: Styles.textStyle16SemiBold.copyWith(
                        color: AppColors.blackColor,
                      ),
                    ),
                    Gap(8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF5C003), Color(0xFFE44E6C)],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        context.tr('upgrade'),
                        style: Styles.textStyle10.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Gap(4.h),
                Text(
                  priceText,
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.secondary700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_upward_rounded,
            color: AppColors.primary600,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}

// ─── Selectable Card (لما مفيش اشتراك حالي) ──────────────────────────────────
class _SelectableCard extends StatelessWidget {
  final NewAdvisorSubModel sub;
  final bool isSelected;
  final VoidCallback? onTap;
  const _SelectableCard({
    required this.sub,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currency = sub.currency ?? getCurrency();
    final durationLabel = sub.isWeekly
        ? context.tr('weekly')
        : context.tr('monthly');
    final priceText = sub.price != null
        ? '${sub.price} $currency'
        : context.tr('price_not_available');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary200
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    durationLabel,
                    style: Styles.textStyle16SemiBold.copyWith(
                      color: isSelected
                          ? AppColors.blackColor
                          : AppColors.secondary700,
                    ),
                  ),
                  Gap(4.h),
                  Text(
                    priceText,
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.secondary700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary600
                      : AppColors.secondary700,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check,
                        size: 16.sp,
                        color: AppColors.primary600,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Expiry Badge ─────────────────────────────────────────────────────────────
class _ExpiryBadge extends StatelessWidget {
  final String expiresAt;
  const _ExpiryBadge({required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final expiry = DateTime.tryParse(expiresAt)?.toLocal();
    if (expiry == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final diff = expiry.difference(now);
    final daysLeft = diff.inDays;

    final Color badgeColor;
    final String timeText;

    if (diff.isNegative) {
      timeText = context.tr('subscription_expired');
      badgeColor = Colors.red.shade400;
    } else if (daysLeft == 0) {
      timeText = context.tr('expires_today');
      badgeColor = Colors.orange.shade400;
    } else if (daysLeft <= 3) {
      timeText = '${context.tr('expires_in')} $daysLeft ${context.tr('days')}';
      badgeColor = Colors.orange.shade400;
    } else {
      timeText = '${context.tr('expires_in')} $daysLeft ${context.tr('days')}';
      badgeColor = AppColors.primary500;
    }

    final day = expiry.day.toString().padLeft(2, '0');
    final month = expiry.month.toString().padLeft(2, '0');
    final dateStr = '$day/$month/${expiry.year}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: badgeColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 14.sp, color: badgeColor),
          Gap(6.w),
          Text(
            '$timeText  •  $dateStr',
            style: Styles.textStyle12SemiBold.copyWith(color: badgeColor),
          ),
        ],
      ),
    );
  }
}

// ─── Purchasing Button ────────────────────────────────────────────────────────
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
