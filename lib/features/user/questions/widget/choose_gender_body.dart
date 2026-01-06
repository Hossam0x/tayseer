import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tayseer/core/enum/auth_enum.dart';
import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';

import '../../../../my_import.dart';

class ChooseGenderBody extends StatefulWidget {
  const ChooseGenderBody({super.key, required this.currentUserType});
  final UserTypeEnum currentUserType;

  @override
  State<ChooseGenderBody> createState() => _ChooseGenderBodyState();
}

class _ChooseGenderBodyState extends State<ChooseGenderBody> {
  Gender? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: CustomBackground(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SizedBox(height: context.height * 0.05),

                        /// Back Button
                        Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: IconButton(
                              onPressed: () {
                                context.pop();
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 25,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: context.height * 0.02),

                        /// Title
                        Text(
                          context.tr('choose_identity'),
                          style: Styles.textStyle22.copyWith(
                            color: AppColors.kscandryTextColor,
                          ),
                        ),

                        const SizedBox(height: 8),

                        /// Description
                        Text(
                          context.tr('choose_identity_desc'),
                          textAlign: TextAlign.center,
                          style: Styles.textStyle12.copyWith(
                            color: HexColor('4d4d4d'),
                          ),
                        ),

                        const Spacer(),

                        /// Cards
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _GenderCard(
                              colorText: selectedGender == Gender.female
                                  ? HexColor('f6579b')
                                  : HexColor('757474'),
                              title: context.tr('female'),
                              image: selectedGender == Gender.female
                                  ? AssetsData.kFemaleImage
                                  : AssetsData.kFemaleImage,
                              colorContainer: selectedGender == Gender.female
                                  ? HexColor('ffc3e0')
                                  : HexColor('ffffff'),
                              onTap: () {
                                setState(() {
                                  selectedGender = Gender.female;
                                });
                              },
                            ),
                            _GenderCard(
                              colorText: selectedGender == Gender.male
                                  ? HexColor('4a84fa')
                                  : HexColor('757474'),
                              title: context.tr('male'),
                              image: selectedGender == Gender.male
                                  ? AssetsData.kMaleImage
                                  : AssetsData.kMaleImage,
                              colorContainer: selectedGender == Gender.male
                                  ? HexColor('d1e0ff')
                                  : HexColor('ffffff'),
                              onTap: () {
                                setState(() {
                                  selectedGender = Gender.male;
                                });
                              },
                            ),
                          ],
                        ),

                        const Spacer(),

                        /// Next Button
                        BlocConsumer<AuthCubit, AuthState>(
                          listenWhen: (previous, current) =>
                              previous.answerQuestionsState !=
                              current.answerQuestionsState,
                          listener: (context, state) {
                            if (state.answerQuestionsState ==
                                CubitStates.success) {
                              context.pushReplacementNamed(
                                AppRouter.kNationalityView,
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
                            return CustomBotton(
                              width: context.width,
                              useGradient: selectedGender == null
                                  ? false
                                  : true,
                              onPressed: selectedGender == null
                                  ? null
                                  : () {
                                      if (UserTypeEnum.guest ==
                                          widget.currentUserType) {
                                        context.pushReplacementNamed(
                                          arguments: {
                                            'currentUserType':
                                                UserTypeEnum.guest,
                                          },
                                          AppRouter.kAdvisorLayoutView,
                                        );
                                      } else {
                                        getIt<AuthCubit>().sendAnswerQuestions(
                                          question: context.tr(
                                            'choose_identity',
                                          ),
                                          questionCategoryEnum:
                                              AuthEnum.gender.name,
                                          questionNumber: 1,
                                          answers: [
                                            {'answer': selectedGender?.name},
                                          ],
                                        );
                                      }
                                    },

                              backGroundcolor: AppColors.kgreyColor,

                              title:
                                  state.answerQuestionsState ==
                                      CubitStates.loading
                                  ? context.tr('sending')
                                  : context.tr('next'),
                            );
                          },
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.title,
    required this.image,
    required this.colorText,
    required this.colorContainer,
    required this.onTap,
  });

  final String title;
  final String image;
  final Color colorText;
  final Color colorContainer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: context.width * 0.4,
        height: context.height * 0.23,
        decoration: BoxDecoration(
          color: colorContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Styles.textStyle16.copyWith(color: colorText)),

            const SizedBox(height: 12),

            AppImage(image, height: context.height * 0.15),
          ],
        ),
      ),
    );
  }
}
