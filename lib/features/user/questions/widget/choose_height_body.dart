import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';

import '../../../../my_import.dart';

class ChooseHeightBody extends StatefulWidget {
  const ChooseHeightBody({super.key});

  @override
  State<ChooseHeightBody> createState() => _ChooseHeightBodyState();
}

class _ChooseHeightBodyState extends State<ChooseHeightBody> {
  static const int minHeight = 100;
  static const int maxHeight = 220;

  late final List<int> heights;
  late final FixedExtentScrollController _controller;

  int selectedHeight = 170;

  @override
  void initState() {
    super.initState();

    heights = List.generate(
      maxHeight - minHeight + 1,
      (index) => minHeight + index,
    );

    _controller = FixedExtentScrollController(
      initialItem: selectedHeight - minHeight,
    );
  }

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
              StepHeader(progress: 0.42, titleKey: 'choose_height'),
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
                          selectedHeight = heights[index];
                        });
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: heights.length,
                        builder: (context, index) {
                          final height = heights[index];
                          final isSelected = height == selectedHeight;

                          return Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  height.toString(),
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
                                  context.tr('cm'),
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
                    context.pushReplacementNamed(AppRouter.kSkinColorView);
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
                        debugPrint('HEIGHT TO API: $selectedHeight');

                        getIt<AuthCubit>().sendAnswerQuestions(
                          question: context.tr('choose_height'),
                          questionCategoryEnum: AuthEnum.height.name,
                          questionNumber: 7,
                          answers: [
                            {'answer': selectedHeight.toString()},
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
