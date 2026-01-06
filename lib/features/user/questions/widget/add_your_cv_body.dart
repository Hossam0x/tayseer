import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/core/widgets/custom_text_field.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';

import '../../../../my_import.dart';

class AddYourCvBody extends StatefulWidget {
  const AddYourCvBody({super.key});

  @override
  State<AddYourCvBody> createState() => _AddYourCvBodyState();
}

class _AddYourCvBodyState extends State<AddYourCvBody> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: CustomBackground(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(height: context.height * 0.06),

                /// BACK + PROGRESS
                StepHeader(progress: 1, titleKey: 'add_your_cv'),
                const SizedBox(height: 30),
                CustomTextField(
                  hintText: context.tr('tell_us_more_about_yourself'),
                  controller: controller,
                ),
                Spacer(),
                BlocConsumer<AuthCubit, AuthState>(
                  listenWhen: (previous, current) =>
                      previous.answerQuestionsState !=
                      current.answerQuestionsState,
                  listener: (context, state) {
                    if (state.answerQuestionsState == CubitStates.success) {
                      context.pushReplacementNamed(AppRouter.kPersonalInfoView);
                    } else if (state.answerQuestionsState ==
                        CubitStates.failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        CustomSnackBar(
                          context,
                          text: state.errorMessage ?? 'حدث خطأ ما',
                          isError: true,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: CustomBotton(
                        width: context.width,
                        title: state.answerQuestionsState == CubitStates.loading
                            ? context.tr('sending')
                            : context.tr('next'),
                        useGradient: true,
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            getIt<AuthCubit>().sendAnswerQuestions(
                              question: context.tr('add_your_cv'),
                              questionCategoryEnum: AuthEnum.addYourCv.name,
                              questionNumber: 20,
                              answers: [
                                {'answer': controller.text},
                              ],
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              CustomSnackBar(
                                context,
                                text: context.tr('cv_field_empty'),
                                isError: true,
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
