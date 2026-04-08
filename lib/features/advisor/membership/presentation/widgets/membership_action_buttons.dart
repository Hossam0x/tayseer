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

    // Cancelled or expired: restore only
    if (sub.isCancelled || sub.isExpired) {
      return _PrimaryButton(
        label: context.tr('restore_membership'),
        onPressed: () => _pushAndRefetch(context, packagesRoute),
      );
    }

    // Active: change plan + cancel (no renew)
    return Column(
      children: [
        _PrimaryButton(
          label: context.tr('change_plan'),
          onPressed: () => _pushAndRefetch(context, packagesRoute),
        ),
        Gap(12.h),
        _CancelButton(onTap: onCancelTap),
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

class _CancelButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CancelButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        context.tr('cancel_subscription'),
        style: Styles.textStyle14.copyWith(color: Colors.red.shade400),
      ),
    );
  }
}
