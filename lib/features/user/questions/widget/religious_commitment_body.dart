import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';

import '../../../../my_import.dart';

class ReligiousCommitmentBody extends StatefulWidget {
  const ReligiousCommitmentBody({super.key});

  @override
  State<ReligiousCommitmentBody> createState() =>
      _ReligiousCommitmentBodyState();
}

class _ReligiousCommitmentBodyState extends State<ReligiousCommitmentBody> {
  String? selectedValue;

  final List<String> itemsKeys = const [
    'religion_full',
    'religion_partial',
    'religion_sometimes',
    'religion_none',
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
              StepHeader(progress: 0.6, titleKey: 'religious_commitment'),
              const SizedBox(height: 30),

              /// LIST
              Expanded(
                child: ListView.separated(
                  itemCount: itemsKeys.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final key = itemsKeys[index];
                    final isSelected = selectedValue == key;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedValue = key;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
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
                listenWhen: (previous, current) =>
                    previous.answerQuestionsState !=
                    current.answerQuestionsState,
                listener: (context, state) {
                  if (state.answerQuestionsState == CubitStates.success) {
                    context.pushReplacementNamed(AppRouter.kHasChildrenView);
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
                              getIt<AuthCubit>().sendAnswerQuestions(
                                question: context.tr('religious_commitment'),
                                questionCategoryEnum:
                                    AuthEnum.religiousCommitment.name,
                                questionNumber: 10,
                                answers: [
                                  {'answer': context.tr(selectedValue!)},
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
