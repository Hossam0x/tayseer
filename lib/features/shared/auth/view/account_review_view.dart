// import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/my_import.dart';

class AccountReviewView extends StatefulWidget {
  const AccountReviewView({super.key});

  @override
  State<AccountReviewView> createState() => _AccountReviewViewState();
}

class _AccountReviewViewState extends State<AccountReviewView> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 5), () {
      context.pushNamedAndRemoveUntil(
        predicate: (route) => false,
        AppRouter.kAdvisorLayoutView,
      );
      // context.read<AuthCubit>().close();
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
