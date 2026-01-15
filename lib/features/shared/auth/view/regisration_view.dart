import 'dart:ui';

import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/functions/route_by_last_question.dart';
import 'package:tayseer/features/shared/auth/view/listeners/guest_login_listeners.dart';
import 'package:tayseer/features/shared/auth/view/widget/last_login_bubble.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
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
      canPop: false, // يمنع الرجوع
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
                  return previous.registerState != current.registerState ||
                      previous.signInWithAppleState !=
                          current.signInWithAppleState ||
                      previous.signInWithGoogleState !=
                          current.signInWithGoogleState;
                },
                listener: (context, state) {
                  if (state.fromScreen != 'registration') return;
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
                      state.registerState == CubitStates.failure) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(
                        context,
                        text:
                            state.errorMessage ?? 'حدث خطأ أثناء تسجيل الدخول',
                        isError: true,
                      ),
                    );
                  }
                  if (state.registerState == CubitStates.success) {
                    context.pop();

                    context.pushNamed(AppRouter.kUserLayoutView);
                    // if (state.verify == true) {
                    //   final route = routeByLastQuestion(
                    //     state.lastQuestionNumber,
                    //   );
                    //   context.pushNamed(route);
                    // } else {
                    //   context.pushNamed(AppRouter.kOtpView);
                    // }
                  }
                  if (state.signInWithGoogleState == CubitStates.success) {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(
                        context,
                        text: context.tr('success_login'),
                        isSuccess: true,
                      ),
                    );
                    Future.delayed(const Duration(seconds: 2), () {
                      context.pushReplacementNamed(AppRouter.kUserLayoutView);
                    });
                  }
                },
                builder: (context, state) {
                  final authCubit = getIt<AuthCubit>();
                  return Stack(
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await CachNetwork.setData(
                                key: 'user_type',
                                value: UserTypeEnum.asConsultant.name,
                              );
                              selectedUserType = UserTypeEnum.asConsultant;
                              context.pushNamed(AppRouter.kRegisterView);
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
                                              authCubit.logInUser(
                                                email: state.lastLoginEmail,
                                              );
                                            },
                                            text: state.lastLoginEmail!,
                                          ),
                                        ),

                                      _buildLoginButton(
                                        context,
                                        color1: HexColor('e9bd7b'),
                                        color2: HexColor('ce8f93'),
                                        color3: HexColor('b362ac'),
                                        text: context.tr('login_email'),
                                        icon: AssetsData.kEmailImage,
                                        onTap: () async {
                                          await CachNetwork.setData(
                                            key: 'user_type',
                                            value: UserTypeEnum.user.name,
                                          );
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
                                              authCubit.logInUser(
                                                email: state.lastLoginEmail,
                                              );
                                            },
                                            text: state.lastLoginEmail!,
                                          ),
                                        ),

                                      _buildLoginButton(
                                        context,
                                        color1: HexColor('b279ad'),
                                        color2: HexColor('9499c7'),
                                        color3: HexColor('80b0d8'),
                                        text: context.tr('login_google'),
                                        icon: AssetsData.kGoogleImage,
                                        onTap: authCubit.signInWithGoogle,
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
                                                authCubit.logInUser(
                                                  email: state.lastLoginEmail,
                                                );
                                              },
                                              text: state.lastLoginEmail!,
                                            ),
                                          ),

                                        _buildLoginButton(
                                          context,
                                          color1: HexColor('b279ad'),
                                          color2: HexColor('9499c7'),
                                          color3: HexColor('80b0d8'),
                                          text: context.tr('login_apple'),
                                          icon: AssetsData.kAppleIcon,
                                          onTap: authCubit.signInWithApple,
                                        ),
                                      ],
                                    ),
                                  ),

                                SizedBox(height: context.height * 0.03),

                                InkWell(
                                  onTap: () {
                                    context.read<AuthCubit>().guestLogin();
                                  },
                                  child: Text(
                                    context.tr('user_guest'),
                                    style: Styles.textStyle16.copyWith(
                                      color: AppColors.kprimaryTextColor,
                                    ),
                                  ),
                                ),
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

  Widget _buildLoginButton(
    BuildContext ctx, {
    required Color color1,
    required Color color2,
    required Color color3,
    required String text,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color1, color2, color3],
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: AppImage(
                icon,
                width: ctx.width * 0.055,
                height: ctx.height * 0.025,
              ),
            ),
            SizedBox(width: ctx.width * 0.02),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: Styles.textStyle14.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
