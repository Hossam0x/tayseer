import 'dart:convert';
import 'dart:developer';

import 'package:tayseer/core/enum/male_female.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';
import 'package:tayseer/main.dart'; // ✅ consumePendingDeepLink
import '../../../../../my_import.dart';

class ChooseGenderBody extends StatelessWidget {
  const ChooseGenderBody({super.key, required this.currentUserType});
  final UserTypeEnum currentUserType;

  @override
  Widget build(BuildContext context) {
    /// ValueNotifier لتتبع الجنس المختار
    final selectedGender = ValueNotifier<Gender?>(null);

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
                              onPressed: () => context.pop(),
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
                          style: Styles.textStyle20Bold.copyWith(
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
                        ValueListenableBuilder<Gender?>(
                          valueListenable: selectedGender,
                          builder: (context, gender, _) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _GenderCard(
                                  colorText: gender == Gender.female
                                      ? HexColor('f6579b')
                                      : HexColor('757474'),
                                  title: context.tr('female'),
                                  image: AssetsData.kFemaleImage,
                                  colorContainer: gender == Gender.female
                                      ? HexColor('ffc3e0')
                                      : HexColor('ffffff'),
                                  onTap: () {
                                    selectedGender.value = Gender.female;
                                  },
                                ),
                                _GenderCard(
                                  colorText: gender == Gender.male
                                      ? HexColor('4a84fa')
                                      : HexColor('757474'),
                                  title: context.tr('male'),
                                  image: AssetsData.kMaleImage,
                                  colorContainer: gender == Gender.male
                                      ? HexColor('d1e0ff')
                                      : HexColor('ffffff'),
                                  onTap: () {
                                    selectedGender.value = Gender.male;
                                  },
                                ),
                              ],
                            );
                          },
                        ),

                        const Spacer(),

                        /// Next Button
                        _buildNextButton(context, selectedGender),

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

  Widget _buildNextButton(
    BuildContext context,
    ValueNotifier<Gender?> selectedGender,
  ) {
    return ValueListenableBuilder<Gender?>(
      valueListenable: selectedGender,
      builder: (context, gender, _) {
        return BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              previous.setGenderState != current.setGenderState,
          listener: (context, state) {
            if (state.setGenderState == CubitStates.success) {
              // ✅ بيروح ChooseSocialStatusView أولاً
              kCurrentUserData = kCurrentUserData?.copyWith(
                gender: gender?.name,
              );
              CachNetwork.setData(
                key: kuserData,
                value: jsonEncode(kCurrentUserData?.toJson() ?? {}),
              );
              log(
                '>>>>>>>>>>>>>>>>>>>.Gender set successfully ${kCurrentUserData?.gender}',
              );
              context.pushReplacementNamed(AppRouter.kSocialStatusView);
            } else if (state.setGenderState == CubitStates.failure) {
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
            final isLoading = state.setGenderState == CubitStates.loading;
            final isEnabled = gender != null;

            return CustomBotton(
              width: context.width,
              useGradient: isEnabled,
              backGroundcolor: AppColors.kgreyColor,
              title: isLoading ? context.tr('sending') : context.tr('next'),
              onPressed: isEnabled && !isLoading
                  ? () {
                      if (currentUserType == UserTypeEnum.guest) {
                        // ✅ Guest — روح مباشرة للـ layout
                        // Guest مش بيوصله deep link للزواج
                        context.pushReplacementNamed(
                          AppRouter.kAdvisorLayoutView,
                          arguments: {'currentUserType': UserTypeEnum.guest},
                        );
                      } else {
                        context.read<AuthCubit>().setGender(
                          gender: gender.name,
                        );
                      }
                    }
                  : null,
            );
          },
        );
      },
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
