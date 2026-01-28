// lib/features/user/questions/view/screens/country_body.dart

import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_selectable_list.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

import '../../../../../my_import.dart';

class CountryBody extends StatelessWidget {
  CountryBody({super.key});

  /// ValueNotifier لتتبع القيمة المختارة بدون setState
  final ValueNotifier<String?> _selectedValue = ValueNotifier<String?>(null);

  /// قائمة الدول (keys للترجمة)
  final List<String> _countries = [
    'country_saudi',
    'country_egypt',
    'country_emirati',
    'country_kuwait',
    'country_qatar',
    'country_bahrain',
    'country_jordan',
    'country_palestine',
    'country_morocco',
    'country_tunisia',
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
              StepHeader(progress: 0.2, titleKey: 'choose_country'),
              const SizedBox(height: 20),

              /// SELECTABLE LIST
              Expanded(
                child: SelectableListWidget(
                  items: _countries,
                  showSearch: true,
                  searchHintKey: 'search_country',
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
              context.pushReplacementNamed(AppRouter.kChooseAgeView);
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
                onPressed: isEnabled
                    ? () {
                        getIt<QuestionsCubit>().sendAnswerQuestions(
                          question: context.tr('choose_country'),
                          questionCategoryEnum: AuthEnum.country.name,
                          questionNumber: 3,
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
