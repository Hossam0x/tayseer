import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import '../../../../my_import.dart';

class JobBody extends StatefulWidget {
  const JobBody({super.key});

  @override
  State<JobBody> createState() => _JobBodyState();
}

class _JobBodyState extends State<JobBody> {
  String? selectedJob;
  String search = '';

  final List<String> jobsKeys = [
    'job_student',
    'job_teacher',
    'job_engineer',
    'job_doctor',
    'job_nurse',
    'job_driver',
    'job_business',
    'job_unemployed',
    'job_other',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = jobsKeys
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
              StepHeader(progress: 0.66, titleKey: 'choose_job'),
              const SizedBox(height: 20),

              /// SEARCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() => search = value);
                  },
                  decoration: InputDecoration(
                    hintText: context.tr('search_job'),
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
                    final isSelected = selectedJob == key;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedJob = key;
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
                    context.pushReplacementNamed(AppRouter.kChooseEmployerView);
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
                      useGradient: selectedJob != null,
                      backGroundcolor: AppColors.kgreyColor,
                      onPressed: selectedJob == null
                          ? null
                          : () {
                              if (state.answerQuestionsState !=
                                  CubitStates.loading) {
                                getIt<AuthCubit>().sendAnswerQuestions(
                                  question: context.tr('choose_job'),
                                  questionCategoryEnum: AuthEnum.job.name,
                                  questionNumber: 15,
                                  answers: [
                                    {'answer': selectedJob!},
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
