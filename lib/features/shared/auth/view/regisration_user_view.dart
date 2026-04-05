// registration_view.dart

import 'dart:ui';

import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/auth/view/listeners/guest_login_listeners.dart';
import 'package:tayseer/features/shared/auth/view/widget/agreement_text.dart';
import 'package:tayseer/features/shared/auth/view/widget/build_login_button.dart';
import 'package:tayseer/features/shared/auth/view/widget/last_login_bubble.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/main.dart'; // ✅ consumePendingDeepLink
import '../../../../my_import.dart';

class RegisrationView extends StatefulWidget {
  const RegisrationView({super.key});

  @override
  State<RegisrationView> createState() => _RegisrationViewState();
}

class _RegisrationViewState extends State<RegisrationView> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().getLastLogIn();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
      },
      child: Scaffold(
        body: CustomBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: BlocConsumer<AuthCubit, AuthState>(
                listenWhen: (previous, current) {
                  // ✅ تحقق من نوع المستخدم - يجب أن يكون user فقط
                  if (current.currentAuthUserType != null &&
                      current.currentAuthUserType != UserTypeEnum.user) {
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
                      state.currentAuthUserType != UserTypeEnum.user) {
                    return;
                  }

                  // عرض الـ loading
                  if (state.signInWithGoogleState == CubitStates.loading ||
                      state.signInWithAppleState == CubitStates.loading ||
                      state.registerState == CubitStates.loading) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CustomloadingApp()),
                    );
                  }

                  // ─── Failure ───
                  if (state.signInWithGoogleState == CubitStates.failure ||
                      state.signInWithAppleState == CubitStates.failure ||
                      state.registerState == CubitStates.failure ||
                      state.authGoogleState == CubitStates.failure ||
                      state.authAppleState == CubitStates.failure) {
                    context.read<AuthCubit>().resetAuthStates();

                    // إغلاق أي dialog مفتوح
                    if (Navigator.canPop(context)) {
                      context.pop();
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(
                        context,
                        text:
                            state.errorMessage ?? 'حدث خطأ أثناء تسجيل الدخول',
                        isError: true,
                      ),
                    );
                  }

                  // نجاح تسجيل الدخول بجوجل
                  if (state.signInWithGoogleState == CubitStates.success &&
                      state.authGoogleState == CubitStates.success) {
                    if (Navigator.canPop(context)) {
                      context.pop(); // إغلاق أي dialog
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(
                        context,
                        text: context.tr('success_login'),
                        isSuccess: true,
                      ),
                    );

                    if (selectedUserType == UserTypeEnum.user) {
                      if (state.isNew == false) {
                        // ✅ مستخدم موجود — روح الـ layout وافتح الـ deep link
                        context.pushReplacementNamed(AppRouter.kUserLayoutView);
                        consumePendingDeepLink();
                      } else {
                        // ✅ مستخدم جديد — روح اختيار الجنس
                        context.pushNamed(AppRouter.kChooseGenderView);
                        // لا نفتح الـ deep link هنا — ننتظر ما يكمل الـ onboarding
                      }
                    }

                    context.read<AuthCubit>().resetAuthStates();
                  }

                  // ─── Apple Success ───
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

                    if (selectedUserType == UserTypeEnum.user) {
                      if (state.isNew == false) {
                        // ✅ مستخدم موجود — روح الـ layout وافتح الـ deep link
                        context.pushReplacementNamed(AppRouter.kUserLayoutView);
                        consumePendingDeepLink();
                      } else {
                        // ✅ مستخدم جديد — روح اختيار الجنس
                        context.pushNamed(AppRouter.kChooseGenderView);
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
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedUserType = UserTypeEnum.asConsultant;
                              });
                              debugPrint('selectedUserType$selectedUserType');
                              context.pushNamed(
                                AppRouter.kRegisrationAdvisorView,
                              );
                            },
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: HexColor('eadce3').withOpacity(0.4),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Text(
                                      context.tr('loginAsConsultant'),
                                      style: Styles.textStyle14.copyWith(
                                        color: AppColors.kprimaryTextColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Hero(
                            tag: 'app_logo',
                            child: SizedBox(
                              height: context.height * 0.25,
                              width: context.width * 0.65,
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
                              context.tr("welcome_text"),
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
                                          selectedUserType = UserTypeEnum.user;
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

                                      // ✅ تم التعديل - تمرير userType
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
                                          selectedUserType = UserTypeEnum.user;
                                          authCubit.signInWithGoogle(
                                            userType: UserTypeEnum.user,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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

                                        // ✅ تم التعديل - تمرير userType
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
                                            selectedUserType =
                                                UserTypeEnum.user;
                                            authCubit.signInWithApple(
                                              userType: UserTypeEnum.user,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                SizedBox(height: context.height * 0.03),

                                InkWell(
                                  onTap: () {
                                    context.read<AuthCubit>().guestLogin();
                                    // ✅ الـ guest مش بيوصله deep link للـ marriage
                                    // لأن الـ marriage يتطلب حساب مسجل
                                  },
                                  child: Text(
                                    context.tr('user_guest'),
                                    style: Styles.textStyle14Bold.copyWith(
                                      color: AppColors.kprimaryTextColor,
                                    ),
                                  ),
                                ),

                                SizedBox(height: context.height * 0.03),
                                AgreementText(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      GuestLoginListeners(),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
