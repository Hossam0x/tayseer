// lib/features/user/questions/view/screens/choose_height_body.dart
import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_ios_picker.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

import '../../../../../my_import.dart';

class ChooseHeightBody extends StatelessWidget {
  ChooseHeightBody({super.key});

  static const int _initialHeight = 170;
  final ValueNotifier<int> _selectedHeight = ValueNotifier<int>(_initialHeight);

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
              StepHeader(progress: 0.46, titleKey: 'choose_height'),
              const SizedBox(height: 30),

              CustomIosPicker(
                initialValue: _initialHeight,
                minValue: 100,
                maxValue: 220,
                unit: context.tr('cm'),
                primaryColor: AppColors.kprimaryColor,
                onSelectedItemChanged: (height) {
                  _selectedHeight.value = height;
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
          context.pushReplacementNamed(AppRouter.kSkinColorView);
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

        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: CustomBotton(
            width: context.width,
            title: isLoading ? context.tr('sending') : context.tr('next'),
            useGradient: true,
            onPressed: () {
              !isLoading
                  ? getIt<QuestionsCubit>().sendAnswerQuestions(
                      question: context.tr('choose_height'),
                      questionCategoryEnum: AuthEnum.height.name,
                      questionNumber: 7,
                      answers: [
                        {'answer': _selectedHeight.value.toString()},
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
