import 'package:tayseer/core/widgets/snack_bar_service.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/repos/otp_repository.dart';
import 'package:tayseer/my_import.dart';

class OtpViewUser extends StatefulWidget {
  final String phoneNumber;
  final bool isPhoneUpdate;

  const OtpViewUser({
    super.key,
    required this.phoneNumber,
    this.isPhoneUpdate = false,
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
        Duration(seconds: 30);
        dio.options.receiveTimeout = Duration(seconds: 30);

        dio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              final token = CachNetwork.getStringData(key: 'token');
              if (token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
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
          otpRepository: otpRepository,
        );
      },
      child: Scaffold(
        body: CustomBackground(
          child: BlocConsumer<OtpCubit, OtpState>(
            listener: (context, state) {
              if (state.otpStatus == OtpStatus.success) {
                Future.delayed(Duration(milliseconds: 1500), () {
                  if (mounted) {
                    _navigateAfterVerification(context, state);
                    context.read<OtpCubit>().resetError();
                  }
                });
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
                      child: _buildPinputField(context),
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
                                  context.read<OtpCubit>().verifyOtp(context);
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

  Widget _buildPinputField(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Pinput(
        length: 6,
        controller: _otpController,
        focusNode: FocusNode(),
        defaultPinTheme: PinTheme(
          width: 50.w,
          height: 50.h,
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17.r),
            border: Border.all(color: const Color(0xfff8d3da), width: 1.4),
          ),
        ),
        focusedPinTheme: PinTheme(
          width: 50.w,
          height: 50.h,
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17.r),
            border: Border.all(color: AppColors.kprimaryColor, width: 1.4),
          ),
        ),
        submittedPinTheme: PinTheme(
          width: 50.w,
          height: 50.h,
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17.r),
            border: Border.all(color: const Color(0xfff8d3da), width: 1.4),
          ),
        ),
        showCursor: true,
        onChanged: (value) {
          context.read<OtpCubit>().updateOtpCode(value);
        },
        onCompleted: (value) {
          context.read<OtpCubit>().updateOtpCode(value);
          Future.delayed(Duration(milliseconds: 300), () {
            if (value.length == 6 && mounted) {
              context.read<OtpCubit>().verifyOtp(context);
            }
          });
        },
        keyboardType: TextInputType.number,
        inputFormatters: [],
      ),
    );
  }

  Widget _buildResendSection(BuildContext context, OtpState state) {
    if (state.canResend) {
      return TextButton(
        onPressed: state.isLoading
            ? null
            : () {
                context.read<OtpCubit>().resendCode(context);
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

  void _navigateAfterVerification(BuildContext context, OtpState state) {
    if (state.isPhoneUpdate) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      Navigator.pop(context);
    }
  }
}
