import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/core/widgets/custom_otp_timer.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
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
    return BlocListener<QuestionsCubit, QuestionsState>(
      listenWhen: (previous, current) =>
          previous.verifyOtpState != current.verifyOtpState ||
          previous.answerQuestionsState != current.answerQuestionsState,

      listener: (context, state) {
        if (state.verifyOtpState == CubitStates.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CustomloadingApp()),
          );
        } else if (state.verifyOtpState == CubitStates.success) {
          // close loading dialog only (don't pop the current route)
          if (Navigator.canPop(context)) Navigator.pop(context);

          // show the success dialog after closing the loader
          Future.microtask(() {
            CustomshowDialogWithImage(
              context,
              title: context.tr("head_phone"),
              supTitle: context.tr("head_phone_subtitle"),
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
                  context.pushReplacementNamed(AppRouter.kCommitmentView);
                });
              },
              showCancelButton: true,
            );
          });
        } else if (state.verifyOtpState == CubitStates.failure) {
          // close loading if open
          if (Navigator.canPop(context)) Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? context.tr('otp_failed'),
              isError: true,
            ),
          );
        }
      },

      child: CustomBackground(
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
                context.tr('otp_title_phone'),
                style: Styles.textStyle20Bold.copyWith(
                  color: AppColors.kscandryTextColor,
                ),
              ),

              SizedBox(height: context.height * 0.02),

              // OTP input
              CustomOtpTimer(
                isphone: true,
                onOtpSubmitted: (verificationCode) {
                  setState(() {
                    _verificationCode = verificationCode;
                  });
                },
              ),
              Gap(context.height * 0.02),

              Text(
                context.tr('otp_sup_title_phone'),
                style: Styles.textStyle14.copyWith(color: AppColors.kgreyColor),
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

                  context.read<QuestionsCubit>().verifyOtp(
                    otp: _verificationCode,
                  );
                },
              ),

              SizedBox(height: context.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
