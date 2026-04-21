import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/features/advisor/membership/presentation/cubit/membership_cubit.dart';
import 'package:tayseer/features/advisor/membership/presentation/cubit/membership_state.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_action_buttons.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_cancel_dialog.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_info_card.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_status_banner.dart';
import 'package:tayseer/features/advisor/membership/presentation/widgets/membership_success_dialog.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/advisor/membership/data/models/my_subscription_model.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_membership_cubit.dart';

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
            return false;
          },
          listener: _onStateChanged,
          child: Stack(
            children: [
              const _BackgroundBar(),
              SafeArea(
                child: Column(
                  children: [
                    const _Header(),
                    const Expanded(child: _MembershipBody()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onStateChanged(BuildContext context, MembershipState state) {
    if (state is! MembershipLoaded) return;
    if (state.actionSuccess != null) {
      showMembershipSuccessDialog(context, messageKey: state.actionSuccess!);
      context.read<MembershipCubit>().clearMessages();
    } else if (state.actionError != null) {
      AppToast.error(context, state.actionError!);
      context.read<MembershipCubit>().clearMessages();
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
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: SimpleAppBar(title: context.tr('membership_management')),
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
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
      child: Column(
        children: [
          MembershipStatusBanner(sub: sub),
          Gap(20.h),
          MembershipInfoCard(sub: sub),
          Gap(32.h),
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
  const _NoSubscriptionBody();

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
                onPressed: () {
                  final isUserMembership =
                      context.read<MembershipCubit>() is UserMembershipCubit;
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
