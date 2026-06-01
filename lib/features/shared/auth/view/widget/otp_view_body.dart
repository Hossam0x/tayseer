import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/widgets/custom_otp_timer.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/main.dart';
import '../../../../../my_import.dart';

class OtpViewBody extends StatefulWidget {
  const OtpViewBody({super.key});

  @override
  State<OtpViewBody> createState() => _OtpViewBodyState();
}

class _OtpViewBodyState extends State<OtpViewBody> {
  String _verificationCode = '';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          previous.verifyOtpState != current.verifyOtpState ||
          previous.resendCodeState != current.resendCodeState,
      listener: (context, state) {
        // ─── OTP verify ───
        if (state.verifyOtpState == CubitStates.success) {
          AppToast.success(context, context.tr('otp_verify_success'));

          if (selectedUserType == UserTypeEnum.asConsultant) {
            if (kCurrentUserData?.compeletedData == true) {
              context.pushReplacementNamed(AppRouter.kAdvisorLayoutView);
            } else if (kCurrentUserData?.compeletedData == false &&
                kCurrentUserData?.lastQuestionNumber == 1) {
              context.pushReplacementNamed(
                AppRouter.kPersonalInfoAsConsultantView,
              );
            } else if (kCurrentUserData?.compeletedData == false &&
                kCurrentUserData?.lastQuestionNumber == 2) {
              context.pushReplacementNamed(
                AppRouter.kConsultantUploadCertificateView,
              );
            } else if (kCurrentUserData?.compeletedData == false &&
                kCurrentUserData?.lastQuestionNumber == 3) {
              context.pushReplacementNamed(AppRouter.kUploadNationalidView);
            } else if (kCurrentUserData?.compeletedData == false &&
                kCurrentUserData?.lastQuestionNumber == 4) {
              context.pushReplacementNamed(AppRouter.kSelectLanguagesView);
            } else if (kCurrentUserData?.compeletedData == false &&
                kCurrentUserData?.lastQuestionNumber == 5) {
              context.pushReplacementNamed(AppRouter.kSelectDaysView);
            } else if (kCurrentUserData?.compeletedData == false &&
                kCurrentUserData?.lastQuestionNumber == 6) {
              context.pushReplacementNamed(AppRouter.kSelectDaysView);
            } else {
              context.pushReplacementNamed(
                AppRouter.kPersonalInfoAsConsultantView,
              );
            }
          } else if (selectedUserType == UserTypeEnum.user) {
            if (state.isNew == true) {
              context.pushReplacementNamed(AppRouter.kAddPhoneView);
            } else {
              context.pushNamedAndRemoveUntil(
                AppRouter.kUserLayoutView,
                predicate: (route) => false,
              );
              consumePendingDeepLink();
            }
          }
        } else if (state.verifyOtpState == CubitStates.failure) {
          AppToast.error(
            context,
            state.errorMessage ?? context.tr('otp_verify_failed'),
          );
        }

        // ─── Resend ───
        if (state.resendCodeState == CubitStates.success) {
          AppToast.success(context, context.tr('otp_sent_success'));
        } else if (state.resendCodeState == CubitStates.failure) {
          AppToast.error(
            context,
            state.errorMessage ?? context.tr('otp_error_general'),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.verifyOtpState == CubitStates.loading;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: context.height * 0.02),

                        // Back button
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 25),
                          child: Align(
                            alignment: isArabic
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 25,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: context.height * 0.08),

                        // Title
                        Text(
                          context.tr('otp_title'),
                          style: Styles.textStyle24.copyWith(
                            color: HexColor('590d1c'),
                          ),
                        ),

                        SizedBox(height: context.height * 0.02),

                        // OTP input + resend timer
                        CustomOtpTimer(
                          onOtpSubmitted: (value) {
                            setState(() => _verificationCode = value);
                          },
                        ),

                        SizedBox(height: context.height * 0.03),
                      ],
                    ),
                  ),
                ),

                // Submit button — always visible above keyboard
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.width * 0.05,
                    8,
                    context.width * 0.05,
                    24,
                  ),
                  child: CustomBotton(
                    width: double.infinity,
                    useGradient: true,
                    title: isLoading
                        ? context.tr('verifying')
                        : context.tr('next'),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_verificationCode.length < 6) {
                              AppToast.error(
                                context,
                                context.tr('otp_enter_first'),
                              );
                              return;
                            }
                            context.read<AuthCubit>().verifyOtp(
                              otp: _verificationCode,
                            );
                          },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
