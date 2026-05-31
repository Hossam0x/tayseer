import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/core/widgets/custom_otp_field.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_cubit.dart';
import 'package:tayseer/features/user/questions/presentation/manager/questions_state.dart';
import 'package:tayseer/my_import.dart';

class OtpPhoneBodyInUser extends StatefulWidget {
  const OtpPhoneBodyInUser({super.key});

  @override
  State<OtpPhoneBodyInUser> createState() => _OtpPhoneBodyInUserState();
}

class _OtpPhoneBodyInUserState extends State<OtpPhoneBodyInUser> {
  String _verificationCode = '';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestionsCubit, QuestionsState>(
      listenWhen: (previous, current) =>
          previous.verifyOtpState != current.verifyOtpState,
      listener: (context, state) {
        if (state.verifyOtpState == CubitStates.success) {
          if (!mounted) return;
          CustomshowDialogWithImage(
            context,
            title: context.tr('head_phone'),
            supTitle: context.tr('head_phone_subtitle'),
            bottonText: 'تأكيد',
            imageUrl: AssetsData.kmapImage,
            onPressed: () {
              context.read<QuestionsCubit>().sendAnswerQuestions(
                question: AuthEnum.phone.name,
                questionCategoryEnum: AuthEnum.phone.name,
                questionNumber: 28,
                answers: [
                  {'answer': 'تم'},
                ],
              );
              context.pushReplacementNamed(
                AppRouter.kBlockedContactsSuccessScreen,
              );
            },
            onCancel: () {
              context.read<QuestionsCubit>().sendAnswerQuestions(
                question: AuthEnum.phone.name,
                questionCategoryEnum: AuthEnum.phone.name,
                questionNumber: 28,
                answers: [
                  {'answer': 'تم'},
                ],
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  context.pushReplacementNamed(AppRouter.kCommitmentView);
                }
              });
            },
            showCancelButton: true,
          );
        } else if (state.verifyOtpState == CubitStates.failure) {
          AppToast.error(
            context,
            state.errorMessage ?? context.tr('otp_failed'),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.verifyOtpState == CubitStates.loading;

        return CustomBackground(
          child: GestureDetector(
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
                            padding: const EdgeInsetsDirectional.only(
                              start: 25,
                            ),
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
                            context.tr('otp_title_phone'),
                            style: Styles.textStyle20Bold.copyWith(
                              color: AppColors.kscandryTextColor,
                            ),
                          ),

                          SizedBox(height: context.height * 0.05),

                          // OTP input
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CustomOtpField(
                              onChanged: (value) {
                                setState(() => _verificationCode = value);
                              },
                              onCompleted: (value) {
                                setState(() => _verificationCode = value);
                              },
                            ),
                          ),

                          Gap(context.height * 0.03),

                          Text(
                            context.tr('otp_sup_title_phone'),
                            style: Styles.textStyle14.copyWith(
                              color: AppColors.kgreyColor,
                            ),
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
                              context.read<QuestionsCubit>().verifyOtp(
                                otp: _verificationCode,
                              );
                            },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
