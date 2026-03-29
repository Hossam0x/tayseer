import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/widgets/custom_otp_timer.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/main.dart'; // ✅ consumePendingDeepLink
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
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
      previous.verifyOtpState != current.verifyOtpState ||
          previous.resendCodeState != current.resendCodeState,

      listener: (context, state) {
        // ─── OTP Loading ───
        if (state.verifyOtpState == CubitStates.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CustomloadingApp()),
          );

          // ─── OTP Success ───
        } else if (state.verifyOtpState == CubitStates.success) {
          context.pop(); // إغلاق الـ loading

          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('otp_verify_success'),
              isSuccess: true,
            ),
          );

          if (selectedUserType == UserTypeEnum.asConsultant) {
            // ─── Consultant ───
            if (kCurrentUserData?.compeletedData == true) {
              context.pushReplacementNamed(AppRouter.kAdvisorLayoutView);
              // ✅ المستشار مش بيستخدم deep link للزواج
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
            // ─── User ───
            if (state.isNew == true) {
              // ✅ مستخدم جديد — يكمل الـ onboarding الأول
              // لا نفتح الـ deep link هنا
              context.pushReplacementNamed(AppRouter.kChooseGenderView);
            } else {
              // ✅ مستخدم موجود — روح الـ layout وافتح الـ deep link
              context.pushNamedAndRemoveUntil(
                AppRouter.kUserLayoutView,
                predicate: (route) => false,
              );
              consumePendingDeepLink();
            }
          }

          // ─── OTP Failure ───
        } else if (state.verifyOtpState == CubitStates.failure) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? context.tr('otp_verify_failed'),
              isError: true,
            ),
          );
        }

        // ─── Resend Loading ───
        if (state.resendCodeState == CubitStates.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CustomloadingApp()),
          );
          // ─── Resend Success ───
        } else if (state.resendCodeState == CubitStates.success) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('otp_sent_success'),
              isSuccess: true,
            ),
          );
          // ─── Resend Failure ───
        } else if (state.resendCodeState == CubitStates.failure) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? context.tr('otp_error_general'),
              isError: true,
            ),
          );
        }
      },

      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: context.height * 0.05),

            // Back button
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Align(
                alignment: isArabic
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                    size: 25,
                  ),
                ),
              ),
            ),

            SizedBox(height: context.height * 0.1),

            // Title
            Text(
              context.tr('otp_title'),
              style: Styles.textStyle24.copyWith(color: HexColor('590d1c')),
            ),

            SizedBox(height: context.height * 0.02),

            // OTP input
            CustomOtpTimer(
              onOtpSubmitted: (verificationCode) {
                setState(() {
                  _verificationCode = verificationCode;
                });
              },
            ),

            SizedBox(height: context.height * 0.06),

            // Submit button
            CustomBotton(
              width: context.width * 0.9,
              useGradient: true,
              title: context.tr('next'),
              onPressed: () {
                if (_verificationCode.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    CustomSnackBar(
                      context,
                      text: context.tr('otp_enter_first'),
                      isError: true,
                    ),
                  );
                  return;
                }

                context.read<AuthCubit>().verifyOtp(otp: _verificationCode);
              },
            ),

            SizedBox(height: context.height * 0.03),
          ],
        ),
      ),
    );
  }
}