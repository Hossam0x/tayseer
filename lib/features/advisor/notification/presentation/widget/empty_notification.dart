import 'package:tayseer/my_import.dart';

class EmptyNotification extends StatelessWidget {
  const EmptyNotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppImage(AssetsData.emptynotification, width: 111),
          const SizedBox(height: 20),
          Text('لا توجد اشعارات حتى الان', style: Styles.textStyle16),
          const SizedBox(height: 10),
          Text(
            'ستظهر جميع اشعاراتك هنا عن الاشتراكات والاحداث',
            style: Styles.textStyle16,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
