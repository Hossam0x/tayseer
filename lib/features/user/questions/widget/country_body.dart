import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';

import '../../../../my_import.dart';

class CountryBody extends StatefulWidget {
  const CountryBody({super.key});

  @override
  State<CountryBody> createState() => _CountryBodyState();
}

class _CountryBodyState extends State<CountryBody> {
  String? selectedCountry;
  String search = '';
  final List<String> countries = [
    'country_saudi',
    'country_egypt',
    'country_emirati',
    'country_kuwait',
    'country_qatar',
    'country_bahrain',
    'country_jordan',
    'country_palestine',
    'country_morocco',
    'country_tunisia',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredList = countries
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
              StepHeader(progress: 0.2, titleKey: 'choose_country'),
              const SizedBox(height: 20),

              /// SEARCH
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) {
                    setState(() => search = value);
                  },
                  decoration: InputDecoration(
                    hintText: context.tr('search_country'),
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
                    final item = filteredList[index];
                    final isSelected = selectedCountry == item;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCountry = item;
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
                            Text(context.tr(item), style: Styles.textStyle14),
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
                    context.pushReplacementNamed(AppRouter.kChooseAgeView);
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
                      useGradient: selectedCountry == null ? false : true,
                      backGroundcolor: AppColors.kgreyColor,
                      onPressed: selectedCountry == null
                          ? null
                          : () {
                              final countryToApi = selectedCountry!;
                              debugPrint('SEND TO API: $countryToApi');

                              getIt<AuthCubit>().sendAnswerQuestions(
                                question: context.tr('choose_country'),
                                questionCategoryEnum: AuthEnum.country.name,
                                questionNumber: 3,
                                answers: [
                                  {'answer': countryToApi},
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
