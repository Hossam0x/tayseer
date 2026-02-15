import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/repos/otp_repository.dart';
import 'package:tayseer/my_import.dart' hide PinTheme;

class OtpViewUser extends StatefulWidget {
  final String phoneNumber;
  final bool isPhoneUpdate;
  final bool isEmailUpdate;
  final OtpSource otpSource; // ⭐⭐ إضافة

  const OtpViewUser({
    super.key,
    required this.phoneNumber,
    this.isPhoneUpdate = false,
    this.isEmailUpdate = false,
    this.otpSource = OtpSource.phone, // ⭐⭐ قيمة افتراضية
  });

  @override
  State<OtpViewUser> createState() => _OtpViewUserState();
}

class _OtpViewUserState extends State<OtpViewUser> {
  late TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dio = Dio();

        dio.options.baseUrl = 'https://tayser-app.net/api/v1';
        dio.options.connectTimeout = Duration(seconds: 30);
        dio.options.receiveTimeout = Duration(seconds: 30);

        // ⭐⭐ إضافة validateStatus هنا أيضاً
        dio.options.validateStatus = (status) => status! < 500;

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final token = CachNetwork.getStringData(key: 'token');
              if (token.isNotEmpty) {
                // ⭐ تصحيح التحقق من null
                options.headers['Authorization'] = 'Bearer $token';
                print('🔑 إضافة Token إلى الطلب');
              } else {
                print('⚠️ Token غير موجود أو فارغ');
              }
              options.headers['Content-Type'] = 'application/json';
              return handler.next(options);
            },
          ),
        );

        final otpRepository = OtpRepositoryImpl(dio);

        return OtpCubit(
          phoneNumber: widget.phoneNumber,
          isPhoneUpdate: widget.isPhoneUpdate,
          isEmailUpdate: widget.isEmailUpdate,
          otpRepository: otpRepository,
          otpSource: widget.otpSource, // ⭐⭐ تمرير المصدر
        );
      },
      child: Scaffold(
        body: CustomBackground(
          child: BlocConsumer<OtpCubit, OtpState>(
            listener: (context, state) {
              if (state.errorMessage.isNotEmpty) {
                showSafeSnackBar(
                  context: context,
                  text: state.errorMessage,
                  isError: true,
                );
                context.read<OtpCubit>().clearMessages();
              } else if (state.successMessage.isNotEmpty &&
                  state.otpStatus == OtpStatus.success) {
                showSafeSnackBar(
                  context: context,
                  text: state.successMessage,
                  isSuccess: true,
                );

                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) {
                    Navigator.pop(context);
                    context.read<OtpCubit>().resetError();
                  }
                });
                context.read<OtpCubit>().clearMessages();
              } else if (state.successMessage.isNotEmpty) {
                // If success but not success status (like resend)
                showSafeSnackBar(
                  context: context,
                  text: state.successMessage,
                  isSuccess: true,
                );
                context.read<OtpCubit>().clearMessages();
              }
            },
            builder: (context, state) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_otpController.text != state.otpCode) {
                  _otpController.text = state.otpCode;
                  _otpController.selection = TextSelection.fromPosition(
                    TextPosition(offset: state.otpCode.length),
                  );
                }
              });

              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: context.height * 0.05),

                    Padding(
                      padding: const EdgeInsets.only(right: 25),
                      child: Align(
                        alignment: Alignment.centerRight,
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

                    SizedBox(height: context.height * 0.1),

                    Text(
                      state.isPhoneUpdate
                          ? 'تأكيد رقم الهاتف الجديد'
                          : state.isEmailUpdate
                          ? 'تأكيد البريد الإلكتروني الجديد'
                          : 'رمز التحقق',
                      style: Styles.textStyle24.copyWith(
                        color: HexColor('590d1c'),
                      ),
                    ),

                    SizedBox(height: context.height * 0.02),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        'تم إرسال رمز التحقق إلى ${state.phoneNumber}',
                        textAlign: TextAlign.center,
                        style: Styles.textStyle14.copyWith(color: Colors.grey),
                      ),
                    ),

                    SizedBox(height: context.height * 0.04),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: _buildPinCodeField(context),
                    ),

                    SizedBox(height: context.height * 0.04),

                    _buildResendSection(context, state),

                    SizedBox(height: context.height * 0.06),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: CustomBotton(
                        width: double.infinity,
                        useGradient: true,
                        title: state.isLoading ? 'جاري التحقق...' : 'تأكيد',
                        onPressed: state.isLoading
                            ? null
                            : () {
                                if (state.otpCode.length == 6) {
                                  context.read<OtpCubit>().verifyOtp();
                                } else {
                                  showSafeSnackBar(
                                    context: context,
                                    text: 'يجب إدخال الرمز المكون من 6 أرقام',
                                    isError: true,
                                  );
                                }
                              },
                      ),
                    ),

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

  Widget _buildPinCodeField(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PinCodeTextField(
        appContext: context,
        length: 6,
        controller: _otpController,
        onChanged: (value) {
          print('🔢 تغيير OTP: $value');
          context.read<OtpCubit>().updateOtpCode(value);
        },
        onCompleted: (value) {
          print('✅ اكتمل OTP: $value');
          if (value.length == 6) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                context.read<OtpCubit>().verifyOtp();
              }
            });
          }
        },

        // ⭐⭐ الإعدادات الأساسية
        autoFocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,

        // ⭐⭐ إعدادات المسح
        enableActiveFill: true,
        autoDisposeControllers: false,
        autoDismissKeyboard: false, // ⭐⭐ هذا هو الـ parameter الصحيح

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
        animationDuration: Duration(milliseconds: 300),
        enablePinAutofill: false,
        textStyle: const TextStyle(fontSize: 20, color: Colors.black),

        // ⭐⭐ إعدادات الكيبورد
        cursorColor: Colors.black,
        cursorHeight: 24,
        cursorWidth: 2,

        // ⭐⭐ السماح بالمسح - التصحيح هنا
        useHapticFeedback: true,
        hapticFeedbackTypes: HapticFeedbackTypes.light, // ⭐⭐ التصحيح
        // ⭐⭐ لا تقفل الكيبورد عند الاكتمال
        // autoDismissKeyboard: false, // تم تعيينه أعلاه

        // ⭐⭐ إعدادات الـ error
        errorAnimationController: null,
        errorTextSpace: 40.h,

        // ⭐⭐ إعدادات إضافية
        beforeTextPaste: (text) {
          // التحقق من أن النص أرقام فقط
          return RegExp(r'^[0-9]+$').hasMatch(text ?? '');
        },

        // ⭐⭐ السماح بالمسح بشكل كامل
        autoUnfocus: false,
        blinkWhenObscuring: true,
      ),
    );
  }

  Widget _buildResendSection(BuildContext context, OtpState state) {
    if (state.canResend) {
      return TextButton(
        onPressed: state.isLoading
            ? null
            : () {
                context.read<OtpCubit>().resendCode();
              },
        child: Text(
          'إعادة إرسال الرمز',
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
          Text(
            'إعادة إرسال الرمز خلال',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 4.h),
          Text(
            _formatTime(state.resendSeconds),
            style: Styles.textStyle12.copyWith(color: HexColor('4d81e7')),
          ),
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
