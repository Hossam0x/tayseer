import 'package:tayseer/my_import.dart';

class AccountActivationPendingView extends StatelessWidget {
  const AccountActivationPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(
              AssetsData.kAccountActivationPendingImage,
              width: context.width * 0.6,
              height: context.width * 0.6,
            ),
            const SizedBox(height: 24),
            Text(
              context.tr('accountActivationPendingTitle'),
              style: Styles.textStyle18.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.kscandryTextColor,
              ),
            ),

            const SizedBox(height: 8),
            Text(
              context.tr('accountActivationPendingHint'),
              style: Styles.textStyle12,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
