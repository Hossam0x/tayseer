// lib/features/user/questions/view/screens/choose_weight_body.dart

import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/user/questions/view/widget/custom_ios_picker.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';

import '../../../../../my_import.dart';

class ChooseWeightBody extends StatelessWidget {
  ChooseWeightBody({super.key});

  static const int _initialWeight = 70;
  final ValueNotifier<int> _selectedWeight = ValueNotifier<int>(_initialWeight);

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
              StepHeader(progress: 0.45, titleKey: 'choose_weight'),
              const SizedBox(height: 30),

              /// ✅ iOS PICKER للوزن
              CustomIosPicker(
                initialValue: _initialWeight,
                minValue: 40,
                maxValue: 150,
                unit: context.tr('kg'),
                primaryColor: AppColors.kprimaryColor,
                onSelectedItemChanged: (weight) {
                  _selectedWeight.value = weight;
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
          context.pushReplacementNamed(AppRouter.kChooseHeightView);
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
              debugPrint('WEIGHT TO API: ${_selectedWeight.value}');

              getIt<QuestionsCubit>().sendAnswerQuestions(
                question: context.tr('choose_weight'),
                questionCategoryEnum: AuthEnum.weight.name,
                questionNumber: 6,
                answers: [
                  {'answer': _selectedWeight.value.toString()},
                ],
              );
            },
          ),
        );
      },
    );
  }
}
