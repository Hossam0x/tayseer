import 'package:tayseer/core/widgets/custom_show_dialog.dart';
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
        CachNetwork.removeData(key: 'token');
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
}
