import 'package:tayseer/my_import.dart';

class AccountReviewView extends StatelessWidget {
  const AccountReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: context.height * .05),
              Text(
                context.tr('accountReviewTitle'),
                style: Styles.textStyle18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.kscandryTextColor,
                ),
              ),
              const SizedBox(height: 16),
              AppImage(
                AssetsData.kAccountReviewImage,
                height: context.height * .4,
                width: context.width * .7,
              ),
              const SizedBox(height: 16),

              Text(
                context.tr('accountReviewSubtitle'),
                textAlign: TextAlign.center,
                style: Styles.textStyle14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
