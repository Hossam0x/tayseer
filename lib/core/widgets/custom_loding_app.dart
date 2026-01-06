import 'package:tayseer/my_import.dart';

class CustomloadingApp extends StatelessWidget {
  const CustomloadingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppImage(
      width: context.width * 0.1,
      height: context.height * 0.1,
      AssetsData.kloadingAnimationsLottie,
    );
  }
}
