import 'package:tayseer/core/enum/advisor_status.dart';
import 'package:tayseer/my_import.dart';

class CustomClick extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const CustomClick({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
  });
  @override
  Widget build(BuildContext context) {
    if (isGuest) {
      return GestureDetector(
        onTap: () {
          _showGuestDialog(context);
        },

        child: child,
      );
    } else if (isAdvisor && advisorStatus != AdvisorStatus.approved) {
      if (advisorStatus == AdvisorStatus.pending) {
        return GestureDetector(
          onTap: () {
            _showAdvisorPendingDialog(context);
          },
          child: child,
        );
      } else if (advisorStatus == AdvisorStatus.disapproved) {
        return GestureDetector(
          onTap: () {
            _showAdvisorDisapprovedDialog(context);
          },
          child: child,
        );
      } else {
        return GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: child,
        );
      }
    } else {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: child,
      );
    }
  }

  void _showGuestDialog(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('joinUs'),
      supTitle: context.tr("guest_login_first"),
      icon: Icons.lock_person_outlined,
      iconColor: AppColors.kprimaryColor,
      bottonText: context.tr("login"),
      showCancelButton: true,
      cancelText: context.tr('skip'),
      onPressed: () {
        CachNetwork.clearGuestAndProfileCache();
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.kRegisrationView,
          (route) => false,
        );
      },
      onCancel: () {
        // Dialog closes automatically
      },
    );
  }

  void _showAdvisorPendingDialog(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr(AppStrings.accountUnderReview),
      supTitle: context.tr(AppStrings.accountUnderReviewMessage),
      icon: Icons.hourglass_top,
      iconColor: Colors.orange,
      bottonText: context.tr(AppStrings.gotIt),
      showCancelButton: false,
      onPressed: () {
        // Dialog closes automatically
      },
    );
  }

  void _showAdvisorDisapprovedDialog(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr(AppStrings.cannotDoThisAction),
      supTitle: context.tr(AppStrings.accountDisApprovedMessage),
      icon: Icons.cancel_outlined,
      iconColor: Colors.red,
      bottonText: context.tr(AppStrings.contactSupport),
      showCancelButton: true,
      cancelText: context.tr(AppStrings.gotIt),
      onPressed: () {
        // Navigate to contact support page or open email client
        // For example:
        // Navigator.pushNamed(context, AppRouter.kContactSupportView);
      },
      onCancel: () {
        // Dialog closes automatically
      },
    );
  }
}
