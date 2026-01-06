import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';

import '../../../../my_import.dart';

class ChooseWeightBody extends StatefulWidget {
  const ChooseWeightBody({super.key});

  @override
  State<ChooseWeightBody> createState() => _ChooseWeightBodyState();
}

class _ChooseWeightBodyState extends State<ChooseWeightBody> {
  final FixedExtentScrollController _controller = FixedExtentScrollController(
    initialItem: 30,
  ); // 70kg

  int selectedWeight = 70;

  /// weights from 40kg to 150kg
  final List<int> weights = List.generate(111, (index) => index + 40);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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

              /// WHITE CONTAINER (WHEEL)
              Container(
                height: context.height * 0.4,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// RED LINES
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 2,
                          width: 100,
                          color: AppColors.kprimaryColor,
                        ),
                        const SizedBox(height: 50),
                        Container(
                          height: 2,
                          width: 100,
                          color: AppColors.kprimaryColor,
                        ),
                      ],
                    ),

                    /// WHEEL
                    ListWheelScrollView.useDelegate(
                      controller: _controller,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedWeight = weights[index];
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: weights.length,
                        builder: (context, index) {
                          final weight = weights[index];
                          final isSelected = weight == selectedWeight;

                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  weight.toString(),
                                  style: TextStyle(
                                    fontSize: isSelected ? 32 : 20,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? AppColors.kprimaryColor
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  context.tr('kg'),
                                  style: TextStyle(
                                    fontSize: isSelected ? 18 : 14,
                                    color: isSelected
                                        ? AppColors.kprimaryColor
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              /// NEXT BUTTON + INTEGRATION
              BlocConsumer<AuthCubit, AuthState>(
                listenWhen: (previous, current) =>
                    previous.answerQuestionsState !=
                    current.answerQuestionsState,
                listener: (context, state) {
                  if (state.answerQuestionsState == CubitStates.success) {
                    context.pushReplacementNamed(AppRouter.kChooseHeightView);
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
                        debugPrint('WEIGHT TO API: $selectedWeight');

                        getIt<AuthCubit>().sendAnswerQuestions(
                          question: context.tr('choose_weight'),
                          questionCategoryEnum: AuthEnum.weight.name,
                          questionNumber: 6,
                          answers: [
                            {'answer': selectedWeight.toString()},
                          ],
                        );
                      },
                    ),
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
