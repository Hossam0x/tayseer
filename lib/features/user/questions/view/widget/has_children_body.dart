// lib/features/user/questions/view/screens/has_children_body.dart

import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_selectable_list.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

import '../../../../../my_import.dart';

class HasChildrenBody extends StatelessWidget {
  HasChildrenBody({super.key});

  /// ValueNotifier لتتبع القيمة المختارة
  final ValueNotifier<String?> _selectedValue = ValueNotifier<String?>(null);

  /// قائمة الإجابات (keys للترجمة)
  final List<String> _hasChildrenItems = const ['yes', 'no'];

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
              StepHeader(progress: 0.61, titleKey: 'has_children'),
              const SizedBox(height: 30),

              Expanded(
                child: SelectableListWidget(
                  items: _hasChildrenItems,
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
              context.pushReplacementNamed(AppRouter.kChildrenNumberView);
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
                                question: context.tr('has_children'),
                                questionCategoryEnum: AuthEnum.hasChildren.name,
                                questionNumber: 11,
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
