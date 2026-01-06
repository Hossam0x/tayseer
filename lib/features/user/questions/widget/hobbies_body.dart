import 'package:tayseer/features/shared/auth/view/widget/custom_step_header.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import '../../../../my_import.dart';

class HobbiesBody extends StatefulWidget {
  const HobbiesBody({super.key});

  @override
  State<HobbiesBody> createState() => _HobbiesBodyState();
}

class _HobbiesBodyState extends State<HobbiesBody> {
  final List<String> hobbiesKeys = [
    'hobby_music',
    'hobby_sports',
    'hobby_travel',
    'hobby_reading',
    'hobby_cooking',
    'hobby_drawing',
    'hobby_mountain_climbing',
    'hobby_meditation',
    'hobby_photography',
    'hobby_sewing',
    'hobby_writing',
    'hobby_cycling',
    'hobby_tourism',
  ];

  final Set<String> selectedHobbies = {};

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
              StepHeader(progress: 0.95, titleKey: 'choose_hobbies'),
              const SizedBox(height: 20),

              /// HOBBIES GRID
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: hobbiesKeys.map((key) {
                      final isSelected = selectedHobbies.contains(key);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedHobbies.remove(key);
                            } else {
                              selectedHobbies.add(key);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? HexColor('e44e6c')
                                : HexColor('fdf5f8'),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.kprimaryColor
                                  : HexColor('fdf5f8'),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppImage(
                                _getHobbyIcon(key),
                                color: isSelected
                                    ? Colors.white
                                    : HexColor('666666'),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                context.tr(key),
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : HexColor('666666'),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              /// NEXT BUTTON + INTEGRATION
              BlocConsumer<AuthCubit, AuthState>(
                listenWhen: (prev, curr) =>
                    prev.answerQuestionsState != curr.answerQuestionsState,
                listener: (context, state) {
                  if (state.answerQuestionsState == CubitStates.success) {
                    context.pushReplacementNamed(AppRouter.kAddYourCvView);
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
                      useGradient: selectedHobbies.isNotEmpty,
                      backGroundcolor: AppColors.kgreyColor,
                      onPressed: selectedHobbies.isEmpty
                          ? null
                          : () {
                              if (state.answerQuestionsState !=
                                  CubitStates.loading) {
                                final answers = selectedHobbies
                                    .map((e) => {'answer': e})
                                    .toList();
                                getIt<AuthCubit>().sendAnswerQuestions(
                                  question: context.tr('choose_hobbies'),
                                  questionCategoryEnum: 'hobbies',
                                  questionNumber: 19,
                                  answers: answers,
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

  String _getHobbyIcon(String key) {
    switch (key) {
      case 'hobby_music':
        return AssetsData.kmusicIcon;
      case 'hobby_sports':
        return AssetsData.ksportsIcon;
      case 'hobby_travel':
        return AssetsData.ktravelIcon;
      case 'hobby_reading':
        return AssetsData.kreadingIcon;
      case 'hobby_cooking':
        return AssetsData.kcookingIcon;
      case 'hobby_drawing':
        return AssetsData.kdrawingIcon;
      case 'hobby_mountain_climbing':
        return AssetsData.kmountainIcon;
      case 'hobby_meditation':
        return AssetsData.kmeditationIcon;
      case 'hobby_photography':
        return AssetsData.kphotographyIcon;
      case 'hobby_sewing':
        return AssetsData.ksewingIcon;
      case 'hobby_writing':
        return AssetsData.kwritingIcon;
      case 'hobby_cycling':
        return AssetsData.kcyclingIcon;
      case 'hobby_tourism':
        return AssetsData.kswimmingIcon;
      default:
        return AssetsData.kAppLogo;
    }
  }
}
