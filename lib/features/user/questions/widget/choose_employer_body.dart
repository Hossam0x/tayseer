import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import '../../../../my_import.dart';

class EmployerBody extends StatefulWidget {
  const EmployerBody({super.key});

  @override
  State<EmployerBody> createState() => _EmployerBodyState();
}

class _EmployerBodyState extends State<EmployerBody> {
  String? selectedEmployer;
  String search = '';

  final List<String> employersKeys = [
    'employer_government',
    'employer_private',
    'employer_institution',
    'employer_freelance',
    'employer_unemployed',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = employersKeys
        .where((e) => context.tr(e).contains(search))
        .toList();

    return Scaffold(
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: context.height * 0.06),

              /// PROGRESS + BACK
              StepHeader(progress: 0.68, titleKey: 'choose_employer'),
              const SizedBox(height: 20),

              /// SEARCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() => search = value);
                  },
                  decoration: InputDecoration(
                    hintText: context.tr('search_employer'),
                    prefixIcon: const Icon(Icons.search),
                    border: const UnderlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// LIST
              Expanded(
                child: ListView.separated(
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final key = filteredList[index];
                    final isSelected = selectedEmployer == key;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedEmployer = key;
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
                                style: Styles.textStyle16,
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
                    context.pushReplacementNamed(
                      selectedGender == Gender.female
                          ? AppRouter.kAcceptMarriedView
                          : AppRouter.kHealthStatusView,
                    );
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
                      useGradient: selectedEmployer != null,
                      backGroundcolor: AppColors.kgreyColor,
                      onPressed: selectedEmployer == null
                          ? null
                          : () {
                              if (state.answerQuestionsState !=
                                  CubitStates.loading) {
                                getIt<AuthCubit>().sendAnswerQuestions(
                                  question: context.tr('choose_employer'),
                                  questionCategoryEnum:
                                      AuthEnum.chooseEmployer.name,
                                  questionNumber: 16,
                                  answers: [
                                    {'answer': selectedEmployer!},
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
