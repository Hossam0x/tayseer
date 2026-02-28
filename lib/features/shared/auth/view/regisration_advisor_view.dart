import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/auth/view/widget/agreement_text.dart';
import 'package:tayseer/features/shared/auth/view/widget/build_login_button.dart';
import 'package:tayseer/features/shared/auth/view/widget/last_login_bubble.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/my_import.dart';

class RegisrationAdvisorView extends StatelessWidget {
  const RegisrationAdvisorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: BlocConsumer<AuthCubit, AuthState>(
              listenWhen: (previous, current) {
                // ✅ تحقق من نوع المستخدم - يجب أن يكون asConsultant فقط
                if (current.currentAuthUserType != null &&
                    current.currentAuthUserType != UserTypeEnum.asConsultant) {
                  return false;
                }

                return previous.registerState != current.registerState ||
                    previous.signInWithAppleState !=
                        current.signInWithAppleState ||
                    previous.signInWithGoogleState !=
                        current.signInWithGoogleState ||
                    previous.authGoogleState != current.authGoogleState ||
                    previous.authAppleState != current.authAppleState;
              },
              listener: (context, state) {
                if (state.fromScreen != 'registration') return;

                // ✅ تحقق إضافي من نوع المستخدم
                if (state.currentAuthUserType != null &&
                    state.currentAuthUserType != UserTypeEnum.asConsultant) {
                  return;
                }

                if (state.signInWithGoogleState == CubitStates.loading ||
                    state.signInWithAppleState == CubitStates.loading ||
                    state.registerState == CubitStates.loading) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CustomloadingApp()),
                  );
                }

                if (state.signInWithGoogleState == CubitStates.failure ||
                    state.signInWithAppleState == CubitStates.failure ||
                    state.registerState == CubitStates.failure ||
                    state.authGoogleState == CubitStates.failure ||
                    state.authAppleState == CubitStates.failure) {
                  context.read<AuthCubit>().resetAuthStates();

                  if (Navigator.canPop(context)) {
                    context.pop();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    CustomSnackBar(
                      context,
                      text: state.errorMessage ?? 'حدث خطأ أثناء تسجيل الدخول',
                      isError: true,
                    ),
                  );
                }

                if (state.signInWithGoogleState == CubitStates.success &&
                    state.authGoogleState == CubitStates.success) {
                  if (Navigator.canPop(context)) {
                    context.pop();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    CustomSnackBar(
                      context,
                      text: context.tr('success_login'),
                      isSuccess: true,
                    ),
                  );
                  if (selectedUserType == UserTypeEnum.asConsultant) {
                    if (kCurrentUserData?.compeletedData == true) {
                      context.pushNamedAndRemoveUntil(
                        predicate: (route) => false,
                        AppRouter.kAdvisorLayoutView,
                      );
                    } else {
                      context.pushReplacementNamed(
                        AppRouter.kPersonalInfoAsConsultantView,
                      );
                    }
                  }
                  context.read<AuthCubit>().resetAuthStates();
                }

                if (state.signInWithAppleState == CubitStates.success &&
                    state.authAppleState == CubitStates.success) {
                  if (Navigator.canPop(context)) {
                    context.pop(); // قفل اللودنج
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    CustomSnackBar(
                      context,
                      text: context.tr('success_login'),
                      isSuccess: true,
                    ),
                  );

                  if (selectedUserType == UserTypeEnum.asConsultant) {
                    if (kCurrentUserData?.compeletedData == true) {
                      context.pushNamedAndRemoveUntil(
                        predicate: (route) => false,
                        AppRouter.kAdvisorLayoutView,
                      );
                    } else {
                      context.pushReplacementNamed(
                        AppRouter.kPersonalInfoAsConsultantView,
                      );
                    }
                  }
                  context.read<AuthCubit>().resetAuthStates();
                }
              },
              builder: (context, state) {
                final authCubit = getIt<AuthCubit>();
                return Stack(
                  children: [
                    Column(
                      children: [
                        Align(
                          alignment: isArabic
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () async {
                              context.pop();
                              await CachNetwork.removeData(key: kUserType);
                              selectedUserType = UserTypeEnum.user;
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 25,
                            ),
                          ),
                        ),

                        // GestureDetector(
                        //   onTap: () async {},
                        //   child: Align(
                        //     alignment: Alignment.topLeft,
                        //     child: GestureDetector(
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(
                        //           top: 20,
                        //           left: 20,
                        //         ),
                        //         child: Row(
                        //           mainAxisSize: MainAxisSize.min,

                        //           children: [
                        //             Text(
                        //               'عربي',
                        //               style: Styles.textStyle16.copyWith(
                        //                 color: AppColors.kprimaryColor,
                        //               ),
                        //             ),
                        //             SizedBox(width: context.width * 0.01),
                        //             AppImage(
                        //               AssetsData.kLangImage,
                        //               height: 20,
                        //               width: 20,
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Hero(
                          tag: 'app_logo',
                          child: SizedBox(
                            height: context.height * 0.35,
                            width: context.width * 0.75,
                            child: AppImage(
                              AssetsData.kAppLogotayseerImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        SizedBox(height: context.height * 0.01),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            context.tr("welcome_text_advisor"),
                            textAlign: TextAlign.center,
                            style: Styles.textStyle18.copyWith(
                              color: AppColors.kprimaryTextColor,
                            ),
                          ),
                        ),

                        SizedBox(height: context.height * 0.02),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            children: [
                              /// ================= EMAIL =================
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (state.lastLoginBy == 'email' &&
                                        state.lastLoginEmail != null &&
                                        state.lastLoginEmail!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 25,
                                        ),
                                        child: LastLoginBubble(
                                          onTap: () {
                                            // authCubit.logInUser(
                                            //   email: state.lastLoginEmail,
                                            // );
                                          },
                                          text: state.lastLoginEmail!,
                                        ),
                                      ),

                                    buildLoginButton(
                                      context,

                                      colors: [
                                        HexColor('e9bd7b'),
                                        HexColor('ce8f93'),
                                        HexColor('b362ac'),
                                      ],
                                      text: context.tr('login_email'),
                                      icon: AssetsData.kEmailImage,
                                      onTap: () async {
                                        selectedUserType =
                                            UserTypeEnum.asConsultant;
                                        context.pushNamed(
                                          AppRouter.kRegisterView,
                                          arguments: {'authCubit': authCubit},
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: context.height * 0.025),

                              /// ================= GOOGLE =================
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (state.lastLoginBy == 'google' &&
                                        state.lastLoginEmail != null &&
                                        state.lastLoginEmail!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 25,
                                        ),
                                        child: LastLoginBubble(
                                          onTap: () {
                                            // authCubit.logInUser(
                                            //   email: state.lastLoginEmail,
                                            // );
                                          },
                                          text: state.lastLoginEmail!,
                                        ),
                                      ),

                                    buildLoginButton(
                                      context,

                                      colors: [
                                        HexColor('b279ad'),
                                        HexColor('9499c7'),
                                        HexColor('80b0d8'),
                                      ],
                                      text: context.tr('login_google'),
                                      icon: AssetsData.kGoogleImage,
                                      onTap: () {
                                        authCubit.signInWithGoogle(
                                          userType: UserTypeEnum.asConsultant,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: context.height * 0.03),

                              /// ================= APPLE =================
                              if (Platform.isIOS)
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (state.lastLoginBy == 'apple' &&
                                          state.lastLoginEmail != null &&
                                          state.lastLoginEmail!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 25,
                                          ),
                                          child: LastLoginBubble(
                                            onTap: () {
                                              // authCubit.logInUser(
                                              //   email: state.lastLoginEmail,
                                              // );
                                            },
                                            text: state.lastLoginEmail!,
                                          ),
                                        ),

                                      buildLoginButton(
                                        context,

                                        colors: [
                                          HexColor('b279ad'),
                                          HexColor('9499c7'),
                                          HexColor('80b0d8'),
                                        ],
                                        text: context.tr('login_apple'),
                                        icon: AssetsData.kAppleIcon,
                                        onTap: () {
                                          authCubit.signInWithApple(
                                            userType: UserTypeEnum.asConsultant,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                              SizedBox(height: context.height * 0.01),

                              AgreementText(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
