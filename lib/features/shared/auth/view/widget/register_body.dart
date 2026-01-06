import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/functions/route_by_last_question.dart';
import 'package:tayseer/core/widgets/custom_text_f_field_title.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import '../../../../../my_import.dart';

class RegisterBody extends StatelessWidget {
  const RegisterBody({super.key});
  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    return BlocListener<AuthCubit, AuthState>(
      bloc: authCubit,
      listenWhen: (previous, current) =>
          previous.registerState != current.registerState,
      listener: (context, state) {
        if (state.fromScreen != 'register') return;

        if (state.registerState == CubitStates.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CustomloadingApp()),
          );
        }
        if (state.registerState == CubitStates.success) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('success_login'),
              isSuccess: true,
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (state.verify == true) {
              final route = routeByLastQuestion(state.lastQuestionNumber);
              selectedUserType == UserTypeEnum.asConsultant
                  ? context.pushNamed(AppRouter.kPersonalInfoAsConsultantView)
                  : context.pushNamed(route);
            } else {
              context.pushNamed(AppRouter.kOtpView);
            }
          });
        }
        if (state.registerState == CubitStates.failure) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? 'حدث خطأ أثناء إنشاء الحساب ❌',
              isError: true,
            ),
          );
        }
      },
      child: SingleChildScrollView(
        child: CustomBackground(
          child: Form(
            key: authCubit.registerFormKey,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  SizedBox(height: context.height * 0.05),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () async {
                        context.pop();
                        await CachNetwork.removeData(key: 'user_type');
                        selectedUserType = UserTypeEnum.user;
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 25,
                      ),
                    ),
                  ),
                  SizedBox(height: context.height * 0.01),
                  AppImage(
                    AssetsData.kAppLogo,
                    width: context.width * 0.5,
                    height: context.height * 0.1,
                  ),
                  SizedBox(height: context.height * 0.03),
                  Text(
                    context.tr('email_title'),
                    style: Styles.textStyle20.copyWith(
                      color: HexColor('590d1c'),
                    ),
                  ),
                  SizedBox(height: context.height * 0.01),

                  Text(
                    context.tr('email_sub_title'),
                    style: Styles.textStyle14.copyWith(
                      color: HexColor('4d4d4d'),
                    ),
                  ),
                  SizedBox(height: context.height * 0.05),

                  /// 🔹 البريد الإلكتروني
                  CustomTextFFieldTitle(
                    title: '',
                    controller: authCubit.emailController,
                    isMail: true,
                  ),
                  SizedBox(height: context.height * 0.05),

                  /// 🔹 زر التسجيل
                  CustomBotton(
                    useGradient: true,
                    width: context.width,
                    title: 'إنشاء حساب',
                    onPressed: () {
                      authCubit.logInUser(fromRegistrationScreen: true);
                    },
                  ),

                  SizedBox(height: context.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
