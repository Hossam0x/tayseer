import 'package:tayseer/my_import.dart';

class ActivationSuccessView extends StatefulWidget {
  const ActivationSuccessView({super.key});

  @override
  State<ActivationSuccessView> createState() => _ActivationSuccessViewState();
}

class _ActivationSuccessViewState extends State<ActivationSuccessView> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 5), () {
      context.pushNamedAndRemoveUntil(
        predicate: (route) => false,
        AppRouter.kAdvisorLayoutView,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: Column(
            children: [
              /// Back
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  color: AppColors.kscandryTextColor,
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.close),
                ),
              ),

              /// Title
              Text(
                context.tr('activationSuccessTitle'),
                style: Styles.textStyle18.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.kprimaryTextColor,
                ),
              ),
              SizedBox(height: context.height * 0.05),

              /// Image
              AppImage(
                AssetsData.kAccountActivationSuccessImage,
                width: context.width * 0.7,
                height: context.width * 0.6,
              ),

              SizedBox(height: context.height * 0.05),

              /// Subtitle
              Text(
                context.tr('activationSuccessSubtitle'),
                style: Styles.textStyle14.copyWith(
                  color: AppColors.kgreyColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.height * 0.1),
              CustomBotton(
                useGradient: true,
                width: context.width * 0.9,
                title: context.tr('proceedToLogin'),
                onPressed: () {
                  context.pushNamedAndRemoveUntil(
                    predicate: (route) => false,
                    AppRouter.kRegisrationView,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
