import 'package:tayseer/my_import.dart';

class EmptyNotification extends StatelessWidget {
  const EmptyNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppImage(AssetsData.emptynotification, width: 111),
          const SizedBox(height: 20),
          Text(
            context.tr(AppStrings.noNotificationsYet),
            style: Styles.textStyle16,
          ),
          const SizedBox(height: 10),
          Text(
            context.tr(AppStrings.notificationsAppearHere),
            style: Styles.textStyle16,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
