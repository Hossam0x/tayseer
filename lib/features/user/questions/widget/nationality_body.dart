import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';

import '../../../../my_import.dart';

class NationalityBody extends StatefulWidget {
  const NationalityBody({super.key});

  @override
  State<NationalityBody> createState() => _NationalityBodyState();
}

class _NationalityBodyState extends State<NationalityBody> {
  String? selectedNationality;
  String search = '';
  final List<String> nationalities = [
    'nationality_saudi',
    'nationality_egyptian',
    'nationality_emirati',
    'nationality_kuwaiti',
    'nationality_qatari',
    'nationality_bahraini',
    'nationality_jordanian',
    'nationality_palestinian',
    'nationality_moroccan',
    'nationality_tunisian',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = nationalities
        .where((e) => e.toLowerCase().contains(search.toLowerCase()))
        .toList();

    return Scaffold(
      body: CustomBackground(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: context.height * 0.06),

              /// PROGRESS + BACK
              StepHeader(progress: 0.1, titleKey: 'choose_nationality'),
              const SizedBox(height: 20),

              /// SEARCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() => search = value);
                  },
                  decoration: InputDecoration(
                    hintText: context.tr('search_nationality'),
                    prefixIcon: const Icon(Icons.search),
                    border: UnderlineInputBorder(),
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
                    final item = filteredList[index];
                    final isSelected = selectedNationality == item;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedNationality = item;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
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
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
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
                            Text(context.tr(item), style: Styles.textStyle16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// NEXT BUTTON
              BlocConsumer<AuthCubit, AuthState>(
                listenWhen: (previous, current) =>
                    previous.answerQuestionsState !=
                    current.answerQuestionsState,
                listener: (context, state) {
                  if (state.answerQuestionsState == CubitStates.success) {
                    context.pushReplacementNamed(AppRouter.kCountryView);
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
                      useGradient: selectedNationality == null ? false : true,
                      backGroundcolor: AppColors.kgreyColor,
                      onPressed: selectedNationality == null
                          ? null
                          : () {
                              final nationalityToApi = selectedNationality!;
                              debugPrint('SEND TO API: $nationalityToApi');

                              getIt<AuthCubit>().sendAnswerQuestions(
                                question: context.tr('choose_nationality'),
                                questionCategoryEnum: 'nationality',
                                questionNumber: 2,
                                answers: [
                                  {'answer': nationalityToApi},
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
