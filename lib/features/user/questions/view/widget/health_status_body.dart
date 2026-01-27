// lib/features/user/questions/view/screens/health_status_body.dart

import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_selectable_list.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

import '../../../../../my_import.dart';

class HealthStatusBody extends StatelessWidget {
  HealthStatusBody({super.key});

  /// ValueNotifier لتتبع القيمة المختارة
  final ValueNotifier<String?> _selectedValue = ValueNotifier<String?>(null);

  /// قائمة الحالات الصحية (keys للترجمة)
  final List<String> _healthStatusItems = const [
    'health_excellent',
    'health_good',
    'health_followup',
    'health_chronic',
    'health_unstable',
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

              /// BACK + PROGRESS
              StepHeader(progress: 0.83, titleKey: 'health_status'),
              const SizedBox(height: 30),

              /// ✅ SELECTABLE LIST (بدون سيرش)
              Expanded(
                child: SelectableListWidget(
                  items: _healthStatusItems,
                  showSearch: false,
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
              context.pushReplacementNamed(AppRouter.kHobbiesView);
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
                        !isLoading
                            ? getIt<QuestionsCubit>().sendAnswerQuestions(
                                question: context.tr('health_status'),
                                questionCategoryEnum:
                                    AuthEnum.healthStatus.name,
                                questionNumber: 18,
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
    );
  }
}
