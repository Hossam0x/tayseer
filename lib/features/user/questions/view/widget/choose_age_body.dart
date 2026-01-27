// lib/features/user/questions/view/screens/choose_age_body.dart

import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_ios_picker.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

import '../../../../../my_import.dart';

class ChooseAgeBody extends StatelessWidget {
  ChooseAgeBody({super.key});

  static const int _initialAge = 20;
  final ValueNotifier<int> _selectedAge = ValueNotifier<int>(_initialAge);

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
              StepHeader(progress: 0.3, titleKey: 'choose_age'),
              const SizedBox(height: 30),

              /// ✅ iOS PICKER
              CustomIosPicker(
                initialValue: 20,
                minValue: 18,
                maxValue: 100,
                primaryColor: AppColors.kprimaryColor,
                onSelectedItemChanged: (age) {
                  _selectedAge.value = age;
                },
              ),

              const Spacer(),

              /// NEXT BUTTON
              _buildNextButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return BlocConsumer<QuestionsCubit, QuestionsState>(
      listenWhen: (previous, current) =>
          previous.answerQuestionsState != current.answerQuestionsState,
      listener: (context, state) {
        if (state.answerQuestionsState == CubitStates.success) {
          context.pushReplacementNamed(AppRouter.kSocialStatusView);
        }
        if (state.answerQuestionsState == CubitStates.failure) {
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

        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: CustomBotton(
            width: context.width,
            title: isLoading ? context.tr('sending') : context.tr('next'),
            useGradient: true,
            onPressed: () {
              debugPrint('AGE TO API: ${_selectedAge.value}');

              !isLoading
                  ? getIt<QuestionsCubit>().sendAnswerQuestions(
                      question: context.tr('choose_age'),
                      questionCategoryEnum: AuthEnum.age.name,
                      questionNumber: 4,
                      answers: [
                        {'answer': _selectedAge.value.toString()},
                      ],
                    )
                  : null;
            },
          ),
        );
      },
    );
  }
}
