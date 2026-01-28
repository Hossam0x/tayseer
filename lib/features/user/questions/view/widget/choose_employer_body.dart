// lib/features/user/questions/view/screens/employer_body.dart

import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_selectable_list.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

import '../../../../../my_import.dart';

class EmployerBody extends StatelessWidget {
  EmployerBody({super.key});

  /// ValueNotifier لتتبع القيمة المختارة
  final ValueNotifier<String?> _selectedValue = ValueNotifier<String?>(null);

  /// قائمة جهات العمل (keys للترجمة)
  final List<String> _employerItems = const [
    'employer_government',
    'employer_private',
    'employer_institution',
    'employer_freelance',
    'employer_unemployed',
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
              StepHeader(progress: 0.68, titleKey: 'choose_employer'),
              const SizedBox(height: 20),

              /// ✅ SELECTABLE LIST (مع سيرش)
              Expanded(
                child: SelectableListWidget(
                  items: _employerItems,
                  showSearch: true,
                  searchHintKey: 'search_employer',
                  primaryColor: AppColors.kprimaryColor,
                  onChanged: (key, value) {
                    _selectedValue.value = value;
                  },
                ),
              ),

              /// NEXT BUTTON
              _buildNextButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: _selectedValue,
      builder: (context, selectedValue, _) {
        return BlocConsumer<QuestionsCubit, QuestionsState>(
          listenWhen: (previous, current) =>
              previous.answerQuestionsState != current.answerQuestionsState,
          listener: (context, state) {
            if (state.answerQuestionsState == CubitStates.success) {
              context.pushReplacementNamed(
                selectedGender == Gender.female
                    ? AppRouter.kAcceptMarriedView
                    : AppRouter.kHealthStatusView,
              );
            } else if (state.answerQuestionsState == CubitStates.failure) {
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
            final isLoading = state.answerQuestionsState == CubitStates.loading;
            final isEnabled = selectedValue != null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: CustomBotton(
                width: context.width,
                title: isLoading ? context.tr('sending') : context.tr('next'),
                useGradient: isEnabled,
                backGroundcolor: AppColors.kgreyColor,
                onPressed: isEnabled && !isLoading
                    ? () {
                        getIt<QuestionsCubit>().sendAnswerQuestions(
                          question: context.tr('choose_employer'),
                          questionCategoryEnum: AuthEnum.chooseEmployer.name,
                          questionNumber: 16,
                          answers: [
                            {'answer': selectedValue},
                          ],
                        );
                      }
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
