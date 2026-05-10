import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/advisor/membership/presentation/cubit/membership_cubit.dart';
import 'package:tayseer/features/advisor/membership/presentation/cubit/membership_state.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_action_buttons.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_cancel_dialog.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_info_card.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_restore_conflict_dialog.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_status_banner.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_success_dialog.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/membership/data/models/my_subscription_model.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_membership_cubit.dart';

// ── ألوان Gold ──
const _goldGradient1 = Color(0xFFD4A017);
const _goldGradient2 = Color(0xFF8B6914);

// ── ألوان Elite ──
const _eliteGradient1 = Color(0xFF6A1FC2);
const _eliteGradient2 = Color(0xFF4A1A8C);

class MembershipManagementView extends StatelessWidget {
  const MembershipManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AdvisorBackground(
        child: BlocListener<MembershipCubit, MembershipState>(
          listenWhen: (prev, curr) {
            if (curr is MembershipLoaded && prev is MembershipLoaded) {
              return curr.timestamp != prev.timestamp;
            }
            if (curr is MembershipRestoreConflict) return true;
            if (curr is MembershipNoSubscriptionWithMessage) return true;
            return false;
          },
          listener: _onStateChanged,
          child: BlocBuilder<MembershipCubit, MembershipState>(
            buildWhen: (prev, curr) =>
                (prev is MembershipLoaded) != (curr is MembershipLoaded) ||
                (prev is MembershipLoaded &&
                    curr is MembershipLoaded &&
                    prev.sub.subscriptionType != curr.sub.subscriptionType),
            builder: (context, state) {
              final sub = state is MembershipLoaded ? state.sub : null;
              final isGold = sub?.isGold ?? false;
              final isUltra = sub?.isUltra ?? false;
              final hasTheme = isGold || isUltra;

              return Stack(
                children: [
                  const _BackgroundBar(),
                  // ── Gradient overlay حسب نوع الاشتراك ──────────────────
                  if (hasTheme)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                (isGold ? _goldGradient1 : _eliteGradient1)
                                    .withOpacity(0.18),
                                (isGold ? _goldGradient2 : _eliteGradient2)
                                    .withOpacity(0.08),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.25, 0.55],
                            ),
                          ),
                        ),
                      ),
                    ),
                  SafeArea(
                    child: Column(
                      children: [
                        _Header(sub: sub),
                        const Expanded(child: _MembershipBody()),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, MembershipState state) {
    // Loaded state messages
    if (state is MembershipLoaded) {
      if (state.actionSuccess != null) {
        if (state.actionSuccess == 'cancel_auto_renew_success') {
          // بعد ما يرجع من Apple sheet — reload بيحصل تلقائياً في الـ cubit
          // نعرض toast بسيط بس
          AppToast.info(context, context.tr(state.actionSuccess!));
        } else {
          showMembershipSuccessDialog(
            context,
            messageKey: state.actionSuccess!,
          );
        }
        context.read<MembershipCubit>().clearMessages();
      } else if (state.actionError != null) {
        AppToast.error(context, context.tr(state.actionError!));
        context.read<MembershipCubit>().clearMessages();
      }
      return;
    }

    // Restore: conflict — show transfer dialog
    if (state is MembershipRestoreConflict) {
      showRestoreConflictDialog(
        context,
        message: state.message,
        onTransfer: () => context.read<MembershipCubit>().transferSubscription(
          state.purchaseId,
        ),
      );
      return;
    }

    // Restore: result message (NO_SUBSCRIPTION or NEW_LINK)
    if (state is MembershipNoSubscriptionWithMessage) {
      if (state.isSuccess) {
        showMembershipSuccessDialog(
          context,
          messageKey: 'restore_membership_success',
        );
      } else {
        AppToast.error(context, state.message);
      }
    }
  }
}

// ── Background bar ────────────────────────────────────────────────────────────
class _BackgroundBar extends StatelessWidget {
  const _BackgroundBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 105.h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AssetsData.homeBarBackgroundImage),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final MySubscriptionModel? sub;
  const _Header({this.sub});

  @override
  Widget build(BuildContext context) {
    final isGold = sub?.isGold ?? false;
    final isUltra = sub?.isUltra ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          Expanded(
            child: SimpleAppBar(title: context.tr('membership_management')),
          ),
          // أيقونة الباقة في الـ app bar
          if (isGold || isUltra)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: AppImage(
                isGold ? AssetsData.goldIcon : AssetsData.eliteIcon,
                width: 28.w,
                height: 28.w,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Body dispatcher ───────────────────────────────────────────────────────────
class _MembershipBody extends StatelessWidget {
  const _MembershipBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MembershipCubit, MembershipState>(
      builder: (context, state) {
        if (state is MembershipLoading || state is MembershipInitial) {
          return const _SkeletonBody();
        }
        if (state is MembershipError) {
          return _ErrorBody(message: state.message);
        }
        if (state is MembershipNoSubscription) {
          return const _NoSubscriptionBody();
        }
        if (state is MembershipNoSubscriptionRestoring) {
          return const _NoSubscriptionBody(isRestoring: true);
        }
        if (state is MembershipNoSubscriptionWithMessage) {
          // After restore attempt — show no-subscription screen
          // (listener already showed toast/dialog)
          return const _NoSubscriptionBody();
        }
        if (state is MembershipRestoreConflict) {
          // Listener shows the dialog; keep showing no-subscription screen
          return const _NoSubscriptionBody();
        }
        if (state is MembershipLoaded) {
          return _LoadedBody(state: state);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ── Loaded ────────────────────────────────────────────────────────────────────
class _LoadedBody extends StatelessWidget {
  final MembershipLoaded state;
  const _LoadedBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final MySubscriptionModel sub = state.sub;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 32.h),
      child: Column(
        children: [
          MembershipStatusBanner(sub: sub),
          Gap(20.h),
          MembershipInfoCard(sub: sub),
          Gap(24.h),

          // ── Apple Policy Info Card ─────────────────────────────────────
          if (Platform.isIOS) _ApplePolicyCard(),
          if (Platform.isIOS) Gap(24.h),

          // ── Action Buttons ─────────────────────────────────────────────
          if (state.isCancelLoading)
            _LoadingButton()
          else
            MembershipActionButtons(
              sub: sub,
              onCancelTap: () => _showCancelDialog(context),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext ctx) {
    showMembershipCancelDialog(
      ctx,
      onConfirm: () => ctx.read<MembershipCubit>().cancelMembership(),
    );
  }
}

// ── Apple Policy Info Card ────────────────────────────────────────────────────
class _ApplePolicyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.apple, size: 18.sp, color: Colors.black54),
          Gap(10.w),
          Expanded(
            child: Text(
              context.tr('apple_subscription_policy_info'),
              style: Styles.textStyle12.copyWith(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading Button ────────────────────────────────────────────────────────────
class _LoadingButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.kprimaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.kprimaryColor,
          ),
        ),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────
const _dummySub = MySubscriptionModel(
  subscriptionType: 'gold',
  subscriptionDurationType: 'monthly',
  subscriptionActivatedAt: '2025-01-01T00:00:00Z',
  subscriptionExpiresAt: '2025-12-01T00:00:00Z',
  subscriptionStatus: 'active',
);

class _SkeletonBody extends StatelessWidget {
  const _SkeletonBody();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
        child: Column(
          children: [
            MembershipStatusBanner(sub: _dummySub),
            Gap(20.h),
            MembershipInfoCard(sub: _dummySub),
            Gap(32.h),
            MembershipActionButtons(sub: _dummySub, onCancelTap: () {}),
          ],
        ),
      ),
    );
  }
}

// ── No subscription ───────────────────────────────────────────────────────────
class _NoSubscriptionBody extends StatelessWidget {
  final bool isRestoring;
  const _NoSubscriptionBody({this.isRestoring = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.card_membership_rounded,
              size: 72.sp,
              color: AppColors.kprimaryColor.withOpacity(0.4),
            ),
            Gap(16.h),
            Text(
              context.tr('no_active_membership'),
              style: Styles.textStyle20Bold.copyWith(color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            Gap(8.h),
            Text(
              context.tr('no_active_membership_desc'),
              style: Styles.textStyle14.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            Gap(28.h),
            // Browse packages button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kprimaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: isRestoring
                    ? null
                    : () {
                        final isUserMembership =
                            context.read<MembershipCubit>()
                                is UserMembershipCubit;
                        final packagesRoute = isUserMembership
                            ? AppRouter.kUserPackagesView
                            : AppRouter.kPackagesView;
                        Navigator.pushNamed(context, packagesRoute).then((_) {
                          if (context.mounted) {
                            context.read<MembershipCubit>().loadMembership();
                          }
                        });
                      },
                child: Text(
                  context.tr('browse_packages'),
                  style: Styles.textStyle16SemiBold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Gap(12.h),
            // Restore purchase button (iOS only)
            if (Platform.isIOS)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(
                      color: AppColors.kprimaryColor.withOpacity(0.6),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: isRestoring
                      ? null
                      : () => context.read<MembershipCubit>().restorePurchase(),
                  child: isRestoring
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.kprimaryColor,
                          ),
                        )
                      : Text(
                          context.tr('restore_membership'),
                          style: Styles.textStyle16SemiBold.copyWith(
                            color: AppColors.kprimaryColor,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────
class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade300),
          Gap(12.h),
          Text(
            message,
            style: Styles.textStyle14.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          Gap(16.h),
          TextButton(
            onPressed: () => context.read<MembershipCubit>().loadMembership(),
            child: Text(
              context.tr('retry'),
              style: TextStyle(color: AppColors.kprimaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
