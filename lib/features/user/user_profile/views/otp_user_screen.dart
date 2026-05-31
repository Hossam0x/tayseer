import 'package:tayseer/core/widgets/custom_otp_field.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/my_import.dart';

class OtpUserScreen extends StatelessWidget {
  final String phoneNumber;
  final bool isPhoneUpdate;
  final bool isEmailUpdate;
  final OtpSource otpSource;

  const OtpUserScreen({
    super.key,
    required this.phoneNumber,
    this.isPhoneUpdate = false,
    this.isEmailUpdate = false,
    this.otpSource = OtpSource.phone,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OtpCubit>(
        param1: OtpCubitParams(
          phoneNumber: phoneNumber,
          isPhoneUpdate: isPhoneUpdate,
          isEmailUpdate: isEmailUpdate,
          otpSource: otpSource,
        ),
      ),
      child: const Scaffold(
        resizeToAvoidBottomInset: false,
        body: CustomBackground(child: _OtpUserBody()),
      ),
    );
  }
}

class _OtpUserBody extends StatelessWidget {
  const _OtpUserBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          AppToast.error(context, context.tr(state.errorMessage));
          context.read<OtpCubit>().clearMessages();
        } else if (state.successMessage.isNotEmpty &&
            state.otpStatus == OtpStatus.success) {
          AppToast.success(context, context.tr(state.successMessage));
          context.read<OtpCubit>().clearMessages();

          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) {
              Navigator.pop(context, true);
              context.read<OtpCubit>().resetError();
            }
          });
        } else if (state.successMessage.isNotEmpty) {
          AppToast.success(context, context.tr(state.successMessage));
          context.read<OtpCubit>().clearMessages();
        }
      },
      builder: (context, state) {
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
                              onPressed: () => Navigator.pop(context),
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
                          _resolveTitle(context, state),
                          style: Styles.textStyle24.copyWith(
                            color: HexColor('590d1c'),
                          ),
                        ),

                        SizedBox(height: context.height * 0.02),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            context.tr(
                              'otp_sent_to_number',
                              args: [state.phoneNumber],
                            ),
                            textAlign: TextAlign.center,
                            style: Styles.textStyle14.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        SizedBox(height: context.height * 0.04),

                        // OTP boxes
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CustomOtpField(
                            onChanged: (value) =>
                                context.read<OtpCubit>().updateOtpCode(value),
                            onCompleted: (_) {
                              if (!state.isLoading) {
                                context.read<OtpCubit>().verifyOtp();
                              }
                            },
                          ),
                        ),

                        SizedBox(height: context.height * 0.04),

                        // Resend section
                        _ResendSection(state: state),

                        SizedBox(height: context.height * 0.03),
                      ],
                    ),
                  ),
                ),

                // Confirm button — always visible above keyboard
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
                    title: state.isLoading
                        ? context.tr('verifying')
                        : context.tr('confirm'),
                    onPressed: state.isLoading
                        ? null
                        : () {
                            if (state.otpCode.length == 6) {
                              context.read<OtpCubit>().verifyOtp();
                            } else {
                              AppToast.error(
                                context,
                                context.tr('otp_digit_6_error'),
                              );
                            }
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

  String _resolveTitle(BuildContext context, OtpState state) {
    if (state.isPhoneUpdate) return context.tr('confirm_new_phone');
    if (state.isEmailUpdate) return context.tr('confirm_new_email');
    return context.tr('otp_title');
  }
}

class _ResendSection extends StatelessWidget {
  final OtpState state;

  const _ResendSection({required this.state});

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (state.canResend) {
      return TextButton(
        onPressed: state.isLoading
            ? null
            : () => context.read<OtpCubit>().resendCode(),
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
          _formatTime(state.resendSeconds),
          style: Styles.textStyle12.copyWith(color: HexColor('4d81e7')),
        ),
      ],
    );
  }
}
