// lib/features/user/questions/view/partner_filter_screen.dart

import 'package:tayseer/core/widgets/custom_build_age_and_country_section.dart';
import 'package:tayseer/features/user/marriage_filter/view/widget/filter_selection_body.dart';
import 'package:tayseer/features/user/questions/view_model/questions_cubit.dart';
import 'package:tayseer/features/user/questions/view_model/questions_state.dart';
import 'package:tayseer/my_import.dart';

class PartnerFilterBody extends StatelessWidget {
  const PartnerFilterBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: BlocConsumer<QuestionsCubit, QuestionsState>(
        listenWhen: (previous, current) =>
            previous.partnerFilterState != current.partnerFilterState,
        listener: (context, state) {
          if (state.partnerFilterState == CubitStates.success) {
            context.pushReplacementNamed(AppRouter.kSubscriptionView);
          } else if (state.partnerFilterState == CubitStates.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(
                context,
                text: state.errorMessage ?? context.tr('error_occurred'),
                isError: true,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 15),

                // ✅ AppBar
                _buildAppBar(context),

                const SizedBox(height: 24),

                // ✅ العنوان
                _buildTitle(context),

                const SizedBox(height: 24),

                Expanded(
                  child: SingleChildScrollView(
                    child: CustomAgeAndCountrySection(
                      ageRange: state.partnerAgeRange,
                      onAgeRangeChanged: (values) {
                        context.read<QuestionsCubit>().updatePartnerAgeRange(
                          values,
                        );
                      },
                      countryValue: state.partnerCountry,
                      nationalityValue: state.partnerNationality,
                      onCountryTap: () => _navigateToSelection(
                        context,
                        fieldKey: 'country',
                        currentValue: state.partnerCountry,
                      ),
                      onNationalityTap: () => _navigateToSelection(
                        context,
                        fieldKey: 'nationality',
                        currentValue: state.partnerNationality,
                      ),
                    ),
                  ),
                ),

                // ✅ زر اكتشاف الملفات الشخصية
                _buildBottomButton(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الإغلاق
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(Icons.close, color: Colors.black54, size: 24),
          ),
          // مسح الكل
          GestureDetector(
            onTap: () {
              context.read<QuestionsCubit>().resetPartnerFilter();
            },
            child: Text(
              context.tr('clear_all'),
              style: Styles.textStyle14.copyWith(
                color: Colors.grey[600],
                decoration: TextDecoration.underline,
                decorationColor: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        context.tr('partner_filter_title'),
        style: Styles.textStyle22Bold.copyWith(
          color: AppColors.kscandryTextColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, QuestionsState state) {
    final isLoading = state.partnerFilterState == CubitStates.loading;

    // ✅ التحقق من اختيار البلد والجنسية
    final isCountrySelected =
        state.partnerCountry != null && state.partnerCountry!.isNotEmpty;
    final isNationalitySelected =
        state.partnerNationality != null &&
        state.partnerNationality!.isNotEmpty;

    // ✅ الزر متفعل فقط إذا تم اختيار البلد والجنسية
    final isEnabled = isCountrySelected && isNationalitySelected && !isLoading;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: CustomBotton(
        width: context.width,
        title: isLoading
            ? context.tr('loading')
            : context.tr('discover_profiles'),
        useGradient: isEnabled, // ✅ التدرج فقط إذا كان متفعل
        backGroundcolor: AppColors.kgreyColor,
        onPressed: isEnabled
            ? () {
                context.read<QuestionsCubit>().submitPartnerFilter();
              }
            : null,
      ),
    );
  }

  Future<void> _navigateToSelection(
    BuildContext context, {
    required String fieldKey,
    dynamic currentValue,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterSelectionScreen(
          fieldKey: fieldKey,
          initialValue: currentValue,
        ),
      ),
    );

    if (result != null && context.mounted) {
      if (fieldKey == 'country') {
        context.read<QuestionsCubit>().updatePartnerCountry(result);
      } else if (fieldKey == 'nationality') {
        context.read<QuestionsCubit>().updatePartnerNationality(result);
      }
    }
  }
}
