import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/services.dart';
import 'package:tayseer/features/user/user_profile/presentation/cubit/otp/otp_cubit.dart';
import 'package:tayseer/my_import.dart' hide PinTheme;

class OtpUserScreen extends StatefulWidget {
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
  State<OtpUserScreen> createState() => _OtpUserScreenState();
}

class _OtpUserScreenState extends State<OtpUserScreen> {
  late TextEditingController _otpController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<OtpCubit>(
        param1: OtpCubitParams(
          phoneNumber: widget.phoneNumber,
          isPhoneUpdate: widget.isPhoneUpdate,
          isEmailUpdate: widget.isEmailUpdate,
          otpSource: widget.otpSource,
        ),
      ),
      child: Scaffold(
        body: CustomBackground(
          child: BlocConsumer<OtpCubit, OtpState>(
            listener: (context, state) {
              if (state.errorMessage.isNotEmpty) {
                AppToast.error(context, context.tr(state.errorMessage));
                context.read<OtpCubit>().clearMessages();
              } else if (state.successMessage.isNotEmpty &&
                  state.otpStatus == OtpStatus.success) {
                AppToast.success(context, context.tr(state.successMessage));

                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) {
                    Navigator.pop(context);
                    context.read<OtpCubit>().resetError();
                  }
                });
                context.read<OtpCubit>().clearMessages();
              } else if (state.successMessage.isNotEmpty) {
                AppToast.success(context, context.tr(state.successMessage));
                context.read<OtpCubit>().clearMessages();
              }
            },
            builder: (context, state) {
              if (_otpController.text != state.otpCode) {
                _otpController.text = state.otpCode;
                _otpController.selection = TextSelection.fromPosition(
                  TextPosition(offset: state.otpCode.length),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: context.height * 0.05),
                    _buildBackButton(context),
                    SizedBox(height: context.height * 0.1),
                    _buildTitle(context, state),
                    SizedBox(height: context.height * 0.02),
                    _buildSubtitle(context, state),
                    SizedBox(height: context.height * 0.04),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: _buildPinCodeField(context),
                    ),
                    SizedBox(height: context.height * 0.04),
                    _buildResendSection(context, state),
                    SizedBox(height: context.height * 0.06),
                    _buildConfirmButton(context, state),
                    SizedBox(height: context.height * 0.03),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 25),
      child: Align(
        alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 25),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, OtpState state) {
    String title = context.tr('otp_title');
    if (state.isPhoneUpdate) title = context.tr('confirm_new_phone');
    if (state.isEmailUpdate) title = context.tr('confirm_new_email');

    return Text(
      title,
      style: Styles.textStyle24.copyWith(color: HexColor('590d1c')),
    );
  }

  Widget _buildSubtitle(BuildContext context, OtpState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Text(
        context.tr('otp_sent_to_number', args: [state.phoneNumber]),
        textAlign: TextAlign.center,
        style: Styles.textStyle14.copyWith(color: Colors.grey),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, OtpState state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: CustomBotton(
        width: double.infinity,
        useGradient: true,
        title: state.isLoading ? context.tr('verifying') : context.tr('confirm'),
        onPressed: state.isLoading
            ? null
            : () {
                if (state.otpCode.length == 6) {
                  context.read<OtpCubit>().verifyOtp();
                } else {
                  AppToast.error(context, context.tr('otp_digit_6_error'));
                }
              },
      ),
    );
  }

  Widget _buildPinCodeField(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) {
              _focusNode.requestFocus();
              SystemChannels.textInput.invokeMethod('TextInput.show');
            }
          });
        } else {
          _focusNode.requestFocus();
          SystemChannels.textInput.invokeMethod('TextInput.show');
        }
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: PinCodeTextField(
          appContext: context,
          length: 6,
          controller: _otpController,
          focusNode: _focusNode,
          onChanged: (value) => context.read<OtpCubit>().updateOtpCode(value),
          onCompleted: (value) {
            if (value.length == 6) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) context.read<OtpCubit>().verifyOtp();
              });
            }
          },
          autoFocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          enableActiveFill: true,
          autoDisposeControllers: false,
          autoDismissKeyboard: true,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(17.r),
            fieldHeight: 50.h,
            fieldWidth: 50.w,
            activeFillColor: Colors.white,
            activeColor: AppColors.kprimaryColor,
            selectedColor: AppColors.kprimaryColor,
            selectedFillColor: Colors.white,
            inactiveColor: const Color(0xfff8d3da),
            inactiveFillColor: Colors.white,
            borderWidth: 0.4,
          ),
          animationType: AnimationType.fade,
          animationDuration: const Duration(milliseconds: 300),
          useHapticFeedback: true,
          hapticFeedbackTypes: HapticFeedbackTypes.light,
          cursorColor: Colors.black,
          cursorHeight: 24,
          cursorWidth: 2,
          autoUnfocus: true,
          blinkWhenObscuring: true,
        ),
      ),
    );
  }

  Widget _buildResendSection(BuildContext context, OtpState state) {
    if (state.canResend) {
      return TextButton(
        onPressed: state.isLoading ? null : () => context.read<OtpCubit>().resendCode(),
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
    } else {
      return Column(
        children: [
          Text(context.tr('resend_code_in'), style: const TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 4.h),
          Text(_formatTime(state.resendSeconds), style: Styles.textStyle12.copyWith(color: HexColor('4d81e7'))),
        ],
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60);
    final secondsRemaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secondsRemaining.toString().padLeft(2, '0')}';
  }
}
