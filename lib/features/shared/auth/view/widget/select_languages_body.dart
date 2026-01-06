import 'package:tayseer/features/shared/auth/view/widget/custom_language_selectable_row.dart';
import 'package:tayseer/my_import.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_cubit.dart';
import 'package:tayseer/features/shared/auth/view_model/auth_state.dart';

class SelectLanguagesBody extends StatelessWidget {
  const SelectLanguagesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();

    final allLanguages = {
      'ar': 'arabic',
      'en': 'english',
      'fr': 'french',
      'rs': 'serbian',
      'gr': 'greek',
    };

    return Scaffold(
      body: CustomBackground(
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            // ✅ تحقق إن فيه على الأقل لغة واحدة مختارة
            final hasSelection = state.selectedLanguages.isNotEmpty;

            return SafeArea(
              child: Column(
                children: [
                  /// Back
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),

                  Gap(context.responsiveHeight(8)),

                  /// Title
                  Text(
                    context.tr('languagesYouSpeak'),
                    style: Styles.textStyle18.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.kscandryTextColor,
                    ),
                  ),

                  Gap(context.responsiveHeight(6)),

                  Text(
                    context.tr('languagesYouSpeakHint'),
                    textAlign: TextAlign.center,
                    style: Styles.textStyle12,
                  ),

                  Gap(context.responsiveHeight(24)),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: allLanguages.entries.map((entry) {
                        final code = entry.key;
                        final nameKey = entry.value;

                        return LanguageSelectableRow(
                          title: context.tr(nameKey),

                          isSelected: state.selectedLanguages.contains(code),

                          onTap: () => authCubit.toggleLanguage(code),
                        );
                      }).toList(),
                    ),
                  ),

                  /// Button
                  BlocConsumer<AuthCubit, AuthState>(
                    listenWhen: (previous, current) =>
                        previous.addLanguageState != current.addLanguageState,
                    listener: (context, state) {
                      if (state.addLanguageState == CubitStates.success) {
                        context.pushNamed(AppRouter.kSelectDaysView);
                      } else if (state.addLanguageState ==
                          CubitStates.failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar(
                            context,
                            isError: true,
                            text: state.errorMessage ?? '',
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      return CustomBotton(
                        width: context.width * .9,
                        title: state.addLanguageState == CubitStates.loading
                            ? context.tr('sending')
                            : context.tr('next'),
                        useGradient: hasSelection,
                        backGroundcolor: AppColors.kgreyColor,
                        onPressed: hasSelection
                            ? () {
                                authCubit.addLanguage();
                              }
                            : null,
                      );
                    },
                  ),

                  Gap(context.responsiveHeight(20)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
