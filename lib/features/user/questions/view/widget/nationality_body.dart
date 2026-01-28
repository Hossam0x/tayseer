import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_selectable_list.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

import '../../../../../my_import.dart';

class NationalityBody extends StatelessWidget {
  NationalityBody({super.key});

  final ValueNotifier<String?> _selectedValue = ValueNotifier<String?>(null);

  final List<String> _nationalities = [
    'nationality_saudi',
    'nationality_egyptian',
    'nationality_emirati',
    'nationality_kuwaiti',
    'nationality_qatari',
    'nationality_bahraini',
    'nationality_jordanian',
    'nationality_palestinian',
    'nationality_moroccan',
    'nationality_tunisian',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: context.height * 0.06),

              /// PROGRESS + BACK
              StepHeader(progress: 0.1, titleKey: 'choose_nationality'),
              const SizedBox(height: 20),

              /// ✅ SELECTABLE LIST
              Expanded(
                child: SelectableListWidget(
                  items: _nationalities,
                  showSearch: true,
                  searchHintKey: 'search_nationality',
                  primaryColor: AppColors.kprimaryColor,
                  onChanged: (key, value) {
                    // ✅ بس بنغير الـ ValueNotifier - مفيش setState
                    _selectedValue.value = value;
                  },
                ),
              ),

              /// ✅ NEXT BUTTON - بيسمع للـ ValueNotifier
              ValueListenableBuilder<String?>(
                valueListenable: _selectedValue,
                builder: (context, selectedValue, _) {
                  return BlocConsumer<QuestionsCubit, QuestionsState>(
                    listenWhen: (previous, current) =>
                        previous.answerQuestionsState !=
                        current.answerQuestionsState,
                    listener: (context, state) {
                      if (state.answerQuestionsState == CubitStates.success) {
                        context.pushReplacementNamed(AppRouter.kCountryView);
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
                      final isLoading =
                          state.answerQuestionsState == CubitStates.loading;
                      final isEnabled = selectedValue != null;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: CustomBotton(
                          width: context.width,
                          title: isLoading
                              ? context.tr('sending')
                              : context.tr('next'),
                          useGradient: isEnabled,
                          backGroundcolor: AppColors.kgreyColor,
                          onPressed: isEnabled
                              ? () {
                                  !isLoading
                                      ? getIt<QuestionsCubit>()
                                            .sendAnswerQuestions(
                                              question: context.tr(
                                                'choose_nationality',
                                              ),
                                              questionCategoryEnum:
                                                  'nationality',
                                              questionNumber: 2,
                                              answers: [
                                                {'answer': selectedValue},
                                              ],
                                            )
                                      : null;
                                }
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
