import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/email/email_edit_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/otp/otp_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/otp_user_screen.dart';
import 'package:tayseer/my_import.dart';

class EmailEditScreen extends StatefulWidget {
  final String initialEmail;
  const EmailEditScreen({super.key, this.initialEmail = ""});

  @override
  State<EmailEditScreen> createState() => _EmailEditScreenState();
}

class _EmailEditScreenState extends State<EmailEditScreen> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EmailEditCubit>()..updateEmail(widget.initialEmail),
      child: Scaffold(
        body: BlocConsumer<EmailEditCubit, EmailEditState>(
          listener: (context, state) {
            if (state.errorMessage.isNotEmpty) {
              AppToast.error(context, context.tr(state.errorMessage));
              context.read<EmailEditCubit>().clearMessages();
            } else if (state.successMessage.isNotEmpty &&
                state.status == CubitStates.success) {
              AppToast.success(context, context.tr(state.successMessage));

              Future.delayed(const Duration(milliseconds: 1400), () async {
                if (!mounted) return;

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OtpUserScreen(
                      phoneNumber: state.fullEmail,
                      isPhoneUpdate: false,
                      isEmailUpdate: true,
                      otpSource: OtpSource.email,
                    ),
                  ),
                );

                if (mounted && result == null) {
                  Navigator.pop(context);
                }

                if (mounted) {
                  context.read<EmailEditCubit>().reset();
                }
              });
              context.read<EmailEditCubit>().clearMessages();
            }
          },
          builder: (context, state) {
            if (_emailController.text != state.email) {
              _emailController.text = state.email;
              _emailController.selection = TextSelection.fromPosition(
                TextPosition(offset: state.email.length),
              );
            }

            return AdvisorBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    Gap(16.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: SimpleAppBar(
                        title: context.tr('emailtitle'),
                        isLargeTitle: true,
                      ),
                    ),
                    Gap(8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        context.tr('email_verification_hint'),
                        textAlign: TextAlign.center,
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.primary800,
                        ),
                      ),
                    ),
                    Gap(100.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: _buildEmailInputField(context, state),
                    ),
                    const Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 50.w,
                        vertical: 30.h,
                      ),
                      child: CustomBotton(
                        height: 53.h,
                        width: double.infinity,
                        title: state.isLoading
                            ? context.tr('sending_status')
                            : context.tr('next'),
                        useGradient: true,
                        backGroundcolor: state.canProceed && !state.isLoading
                            ? Colors.transparent
                            : Colors.grey,
                        onPressed: state.isLoading || !state.canProceed
                            ? null
                            : () => context
                                  .read<EmailEditCubit>()
                                  .updateEmailRequest(),
                      ),
                    ),
                    Gap(MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmailInputField(BuildContext context, EmailEditState state) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.kWhiteColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: state.emailError.isNotEmpty
                    ? Colors.red
                    : AppColors.primary100,
                width: state.emailError.isNotEmpty ? 1.5 : 1,
              ),
            ),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: Styles.textStyle14.copyWith(
                color: AppColors.secondary800,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: context.tr('email_hint'),
                hintStyle: Styles.textStyle14.copyWith(
                  color: AppColors.primary200,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
              onChanged: (v) => context.read<EmailEditCubit>().updateEmail(v),
            ),
          ),
          if (state.emailError.isNotEmpty) ...[
            Gap(8.h),
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Text(
                context.tr(state.emailError),
                style: Styles.textStyle12.copyWith(
                  color: Colors.red,
                  height: 1.4,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
