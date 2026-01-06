import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import '../../../../my_import.dart';

class HealthStatusBody extends StatefulWidget {
  const HealthStatusBody({super.key});

  @override
  State<HealthStatusBody> createState() => _HealthStatusBodyState();
}

class _HealthStatusBodyState extends State<HealthStatusBody> {
  String? selectedValue;

  final List<String> healthOptionsKeys = [
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

              /// LIST
              Expanded(
                child: ListView.separated(
                  itemCount: healthOptionsKeys.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final key = healthOptionsKeys[index];
                    final isSelected = selectedValue == key;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedValue = key;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.pink.withOpacity(.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          border: isSelected
                              ? Border.all(color: AppColors.kprimaryColor)
                              : null,
                        ),
                        child: Row(
                          children: [
                            if (isSelected)
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.kprimaryColor,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            if (isSelected) const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.tr(key),
                                style: Styles.textStyle14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// NEXT BUTTON + INTEGRATION
              BlocConsumer<AuthCubit, AuthState>(
                listenWhen: (prev, curr) =>
                    prev.answerQuestionsState != curr.answerQuestionsState,
                listener: (context, state) {
                  if (state.answerQuestionsState == CubitStates.success) {
                    context.pushReplacementNamed(AppRouter.kHobbiesView);
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
                      useGradient: selectedValue != null,
                      backGroundcolor: AppColors.kgreyColor,
                      onPressed: selectedValue == null
                          ? null
                          : () {
                              if (state.answerQuestionsState !=
                                  CubitStates.loading) {
                                getIt<AuthCubit>().sendAnswerQuestions(
                                  question: context.tr('health_status'),
                                  questionCategoryEnum:
                                      AuthEnum.healthStatus.name,
                                  questionNumber: 18,
                                  answers: [
                                    {'answer': selectedValue!},
                                  ],
                                );
                              }
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
