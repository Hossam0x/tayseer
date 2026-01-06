import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_otp_timer.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
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
        if (state.verifyOtpState == CubitStates.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CustomloadingApp()),
          );
        } else if (state.verifyOtpState == CubitStates.success) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('otp_verify_success'),
              isSuccess: true,
            ),
          );

          Future.delayed(const Duration(seconds: 1), () {
            selectedUserType == UserTypeEnum.asConsultant
                ? context.pushReplacementNamed(
                    AppRouter.kPersonalInfoAsConsultantView,
                  )
                : context.pushReplacementNamed(AppRouter.kChooseGenderView);
          });
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

        if (state.resendCodeState == CubitStates.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CustomloadingApp()),
          );
        } else if (state.resendCodeState == CubitStates.success) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('otp_sent_success'),
              isSuccess: true,
            ),
          );
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
                alignment: Alignment.centerRight,
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
