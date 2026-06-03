import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/widgets/custom_otp_field.dart';
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
            } else if (state.isNew == true) {
              // New advisor — go through phone number + OTP step first
              context.pushReplacementNamed(
                AppRouter.kAddPhoneView,
                arguments: {'isAdvisorFlow': true},
              );
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
        final isResendLoading = state.resendCodeState == CubitStates.loading;

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

                        SizedBox(height: context.height * 0.06),

                        // Title
                        Text(
                          context.tr('otp_title'),
                          style: Styles.textStyle24.copyWith(
                            color: HexColor('590d1c'),
                          ),
                        ),

                        SizedBox(height: context.height * 0.02),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            context.tr('otp_sub_title'),
                            textAlign: TextAlign.center,
                            style: Styles.textStyle14.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        SizedBox(height: context.height * 0.04),

                        // OTP input — CustomOtpField مباشرة بدل CustomOtpTimer
                        // عشان الـ keyboard ميتقفلش على Android
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomOtpField(
                            onChanged: (v) =>
                                setState(() => _verificationCode = v),
                            onCompleted: (v) =>
                                setState(() => _verificationCode = v),
                          ),
                        ),

                        SizedBox(height: context.height * 0.03),

                        // Resend section
                        _ResendSection(isLoading: isResendLoading),

                        SizedBox(height: context.height * 0.03),
                      ],
                    ),
                  ),
                ),

                // Submit button — stays above keyboard
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

// ─────────────────────────────────────────────────────────────────────────────
// Resend Section — مستقلة عن أي cubit خارجي، تستخدم AuthCubit
// ─────────────────────────────────────────────────────────────────────────────

class _ResendSection extends StatefulWidget {
  final bool isLoading;
  const _ResendSection({required this.isLoading});

  @override
  State<_ResendSection> createState() => _ResendSectionState();
}

class _ResendSectionState extends State<_ResendSection> {
  static const _initialSeconds = 300;
  int _seconds = _initialSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      if (_seconds > 0) {
        setState(() => _seconds--);
        return true;
      }
      setState(() => _canResend = true);
      return false;
    });
  }

  void _resend() {
    if (widget.isLoading) return;
    context.read<AuthCubit>().resendCode();
    setState(() {
      _seconds = _initialSeconds;
      _canResend = false;
    });
    _startTimer();
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_canResend) {
      return TextButton(
        onPressed: widget.isLoading ? null : _resend,
        child: Text(
          context.tr('resend_code'),
          style: Styles.textStyle12.copyWith(
            color: HexColor('4d81e7'),
            decoration: TextDecoration.underline,
            decorationColor: HexColor('4d81e7'),
            decorationThickness: 1.5,
          ),
        ),
      );
    }

    return Column(
      children: [
        Text(
          context.tr('resend_code_in'),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTime(_seconds),
          style: Styles.textStyle12.copyWith(color: HexColor('4d81e7')),
        ),
      ],
    );
  }
}
