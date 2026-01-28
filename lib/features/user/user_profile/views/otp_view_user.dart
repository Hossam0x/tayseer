// features/otp/otp_view.dart
import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/my_import.dart';

class OtpViewUser extends StatelessWidget {
  final String phoneNumber;
  final bool isPhoneUpdate;

  const OtpViewUser({
    super.key,
    required this.phoneNumber,
    this.isPhoneUpdate = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OtpCubit(phoneNumber: phoneNumber, isPhoneUpdate: isPhoneUpdate),
      child: Scaffold(
        body: CustomBackground(
          child: BlocConsumer<OtpCubit, OtpState>(
            listener: (context, state) {
              if (state.otpStatus == OtpStatus.success) {
                // إظهار رسالة نجاح
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isPhoneUpdate
                          ? 'تم تأكيد رقم الهاتف بنجاح'
                          : 'تم التحقق بنجاح',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );

                // التنقل للصفحة المناسبة
                _navigateAfterVerification(context, state);

                // إعادة تعيين الحالة
                context.read<OtpCubit>().resetError();
              }

              if (state.otpStatus == OtpStatus.failure &&
                  state.errorMessage.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.errorMessage),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
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
                            Navigator.pop(context);
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
                      state.isPhoneUpdate
                          ? 'تأكيد رقم الهاتف الجديد'
                          : 'رمز التحقق',
                      style: Styles.textStyle24.copyWith(
                        color: HexColor('590d1c'),
                      ),
                    ),

                    SizedBox(height: context.height * 0.02),

                    // Subtitle
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        'تم إرسال رمز التحقق إلى ${state.phoneNumber}',
                        textAlign: TextAlign.center,
                        style: Styles.textStyle14.copyWith(color: Colors.grey),
                      ),
                    ),

                    SizedBox(height: context.height * 0.04),

                    // OTP input - جعل الحقول معكوسة
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Directionality(
                        textDirection:
                            TextDirection.ltr, // ✅ جعل الاتجاه LTR للحقول
                        child: _buildOtpFields(context),
                      ),
                    ),

                    SizedBox(height: context.height * 0.04),

                    // Resend code timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'إعادة إرسال الرمز خلال ',
                          style: Styles.textStyle14.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${(state.resendSeconds ~/ 60).toString().padLeft(2, '0')}:${(state.resendSeconds % 60).toString().padLeft(2, '0')}',
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.primary600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: context.height * 0.02),

                    // Resend button
                    if (state.canResend)
                      TextButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                context.read<OtpCubit>().resendCode();
                              },
                        child: Text(
                          'إعادة إرسال الرمز',
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.primary600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                    SizedBox(height: context.height * 0.06),

                    // Submit button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: CustomBotton(
                        width: double.infinity,
                        useGradient: true,
                        title: state.isLoading ? 'جاري التحقق...' : 'تأكيد',
                        // isEnabled: state.canSubmit,
                        onPressed: state.isLoading
                            ? null
                            : () {
                                context.read<OtpCubit>().verifyOtp();
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

  Widget _buildOtpFields(BuildContext context) {
    return BlocBuilder<OtpCubit, OtpState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            // حساب المؤشر المعكوس للحقل الأخير أولاً
            final reversedIndex = 5 - index;

            // الحصول على الرقم الحالي للحقل (من اليمين لليسار)
            String currentDigit = '';
            if (reversedIndex < state.otpCode.length) {
              currentDigit = state.otpCode[reversedIndex];
            }

            // إنشاء controller لهذا الحقل
            final controller = TextEditingController(text: currentDigit);

            return SizedBox(
              width: 40.w,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: Styles.textStyle18.copyWith(color: Colors.black),
                decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary500),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    // حساب المؤشر الفعلي (معكوس)
                    final actualIndex = 5 - index;

                    // بناء كود OTP جديد
                    String newOtpCode = state.otpCode;

                    if (newOtpCode.length >= actualIndex + 1) {
                      // استبدال الرقم الموجود
                      newOtpCode =
                          newOtpCode.substring(0, actualIndex) +
                          value +
                          (newOtpCode.length > actualIndex + 1
                              ? newOtpCode.substring(actualIndex + 1)
                              : '');
                    } else {
                      // إضافة رقم جديد
                      newOtpCode =
                          newOtpCode.padRight(actualIndex, ' ') + value;
                      newOtpCode = newOtpCode.replaceAll(' ', '');
                    }

                    // تحديث الحالة
                    context.read<OtpCubit>().updateOtpCode(newOtpCode);

                    // نقل التركيز للحقل التالي (اليسار)
                    if (index < 5 && value.isNotEmpty) {
                      // لأن المؤشرات معكوسة، ننتقل للحقل التالي على اليسار
                      final nextIndex = index + 1;
                      if (nextIndex <= 5) {
                        // يمكن إضافة منطق لنقل التركيز هنا إذا لزم الأمر
                      }
                    }
                  } else if (value.isEmpty && index < 5) {
                    // حذف الرقم - الانتقال للحقل السابق (اليمين)
                    final actualIndex = 5 - index;
                    if (state.otpCode.length >= actualIndex) {
                      String newOtpCode = '';
                      if (state.otpCode.length == actualIndex) {
                        newOtpCode = state.otpCode.substring(
                          0,
                          actualIndex - 1,
                        );
                      } else {
                        newOtpCode =
                            state.otpCode.substring(0, actualIndex - 1) +
                            state.otpCode.substring(actualIndex);
                      }
                      context.read<OtpCubit>().updateOtpCode(newOtpCode);
                    }
                  }
                },
              ),
            );
          }).reversed.toList(), // ✅ عكس ترتيب الحقول
        );
      },
    );
  }

  void _navigateAfterVerification(BuildContext context, OtpState state) {
    if (state.isPhoneUpdate) {
      // بعد تحديث الهاتف، العودة للصفحة الرئيسية
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      // في حالات أخرى (تسجيل دخول، إلخ)
      Navigator.pop(context);
    }
  }
}
