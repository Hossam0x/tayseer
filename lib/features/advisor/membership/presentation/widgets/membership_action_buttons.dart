import 'package:tayseer/features/advisor/membership/data/models/my_subscription_model.dart';
import 'package:tayseer/features/advisor/membership/presentation/cubit/membership_cubit.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_membership_cubit.dart';
import 'package:tayseer/my_import.dart';

class MembershipActionButtons extends StatelessWidget {
  final MySubscriptionModel sub;
  final VoidCallback onCancelTap;

  const MembershipActionButtons({
    super.key,
    required this.sub,
    required this.onCancelTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUserMembership =
        context.read<MembershipCubit>() is UserMembershipCubit;
    final packagesRoute = isUserMembership
        ? AppRouter.kUserPackagesView
        : AppRouter.kPackagesView;
    final initialPage = sub.isUltra ? 2 : 1;

    // منتهي أو ملغي auto-renew وانتهت المدة → restore فقط
    if (sub.isExpired || (sub.isCancelled && !sub.isActive)) {
      return _PrimaryButton(
        label: context.tr('restore_membership'),
        onPressed: () => _pushAndRefetch(
          context,
          packagesRoute,
          args: {'initialPage': initialPage},
        ),
      );
    }

    // نشط
    return Column(
      children: [
        // ── تغيير الباقة — iOS فقط ────────────────────────────────────────
        if (Platform.isIOS) ...[
          _PrimaryButton(
            label: context.tr('change_plan'),
            onPressed: () => _pushAndRefetch(
              context,
              packagesRoute,
              args: {'initialPage': initialPage},
            ),
          ),
          Gap(12.h),
        ],

        // ── إدارة الاشتراك (Manage) — iOS فقط ────────────────────────────
        if (Platform.isIOS) ...[
          _ManageButton(
            onTap: () => context.read<MembershipCubit>().cancelMembership(),
          ),
          Gap(12.h),
        ],

        // ── طلب استرداد (Refund) — iOS 15+ native sheet ───────────────────
        if (Platform.isIOS) ...[
          _RefundButton(
            onTap: () => context.read<MembershipCubit>().requestRefund(),
          ),
          Gap(12.h),
        ],

        // ── إلغاء التجديد التلقائي — يظهر بس لو autoRenewal = true ────────
        // iOS: يفتح Apple sheet | Android: يكلم الباك مباشرة
        if (sub.autoRenewal) _CancelButton(onTap: onCancelTap),
      ],
    );
  }

  void _pushAndRefetch(BuildContext context, String route, {Object? args}) {
    Navigator.pushNamed(context, route, arguments: args).then((_) {
      if (context.mounted) {
        context.read<MembershipCubit>().loadMembership();
      }
    });
  }
}

// ── Primary Button ────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _PrimaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) => CustomBotton(
    height: 52.h,
    width: double.infinity,
    title: label,
    onPressed: onPressed,
    useGradient: true,
  );
}

// ── Manage Button — يفتح Apple's native Manage Subscriptions sheet ────────────
class _ManageButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ManageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          side: BorderSide(color: AppColors.kprimaryColor.withOpacity(0.6)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: onTap,
        icon: Icon(
          Icons.settings_outlined,
          size: 18.sp,
          color: AppColors.kprimaryColor,
        ),
        label: Text(
          context.tr('manage_subscription'),
          style: Styles.textStyle16SemiBold.copyWith(
            color: AppColors.kprimaryColor,
          ),
        ),
      ),
    );
  }
}

// ── Refund Button — يفتح Apple's native Refund Request sheet ─────────────────
class _RefundButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RefundButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          side: BorderSide(color: Colors.orange.shade400),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: onTap,
        icon: Icon(
          Icons.receipt_long_outlined,
          size: 18.sp,
          color: Colors.orange.shade600,
        ),
        label: Text(
          context.tr('request_refund'),
          style: Styles.textStyle16SemiBold.copyWith(
            color: Colors.orange.shade600,
          ),
        ),
      ),
    );
  }
}

// ── Cancel Auto-Renew Button ──────────────────────────────────────────────────
class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          side: BorderSide(color: Colors.red.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: onTap,
        icon: Icon(
          Icons.cancel_outlined,
          size: 18.sp,
          color: Colors.red.shade400,
        ),
        label: Text(
          context.tr('cancel_auto_renew'),
          style: Styles.textStyle16SemiBold.copyWith(
            color: Colors.red.shade400,
          ),
        ),
      ),
    );
  }
}
