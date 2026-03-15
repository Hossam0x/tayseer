import 'package:tayseer/core/widgets/custom_build_age_and_country_section.dart';
import 'package:tayseer/features/user/marriage_filter/view/widget/custom_data_card.dart';
import 'package:tayseer/features/user/marriage_filter/view/widget/filter_selection_body.dart';
import 'package:tayseer/features/user/marriage_filter/view_models/marriage_filter_cubit.dart';
import 'package:tayseer/features/user/marriage_filter/view_models/marriage_filter_state.dart';
import 'package:tayseer/my_import.dart';

class MarriageFilterBody extends StatelessWidget {
  const MarriageFilterBody({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: BlocConsumer<MarriageFilterCubit, MarriageFilterState>(
        listener: (context, state) {
          if (state.marriageFilterStatus == CubitStates.success) {
            context.pop();
            context.pop();
          } else if (state.marriageFilterStatus == CubitStates.failure) {
            context.pop();
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(
                context,
                text: state.errorMessage ?? context.tr('error_occurred'),
                isError: true,
              ),
            );
          } else if (state.marriageFilterStatus == CubitStates.loading) {
            showDialog(
              context: context,
              builder: (context) => const Center(child: CustomloadingApp()),
            );
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),

              // ✅ قسم العمر والبلد
              SliverToBoxAdapter(
                child: CustomAgeAndCountrySection(
                  ageRange: state.ageRange,
                  onAgeRangeChanged: (values) {
                    context.read<MarriageFilterCubit>().updateAgeRange(values);
                  },
                  countryValue: state.selectedFilters['country']?.toString(),
                  nationalityValue: state.selectedFilters['nationality']
                      ?.toString(),
                  onCountryTap: () => _navigateToSelection(
                    context,
                    fieldKey: 'country',
                    currentValue: state.selectedFilters['country'],
                  ),
                  onNationalityTap: () => _navigateToSelection(
                    context,
                    fieldKey: 'nationality',
                    currentValue: state.selectedFilters['nationality'],
                  ),
                ),
              ),

              // ✅ قسم البيانات والأنشطة — إصلاح: إزالة "goalMarry" المكرر واستبداله بـ "goldAccount"
              SliverToBoxAdapter(
                child: CustomDataCard(
                  sectionTitle: context.tr('data_and_activities'),
                  items: [
                    _buildRow(context, state, "verified_id", "isVerified"),
                    _buildRow(context, state, "new_member", "isNew"),
                    _buildRow(context, state, "photo_status", "imageBlur"),
                    _buildRow(
                      context,
                      state,
                      "gold_account",
                      "goldAccount",
                    ), // ✅ إصلاح: key مختلف
                  ],
                ),
              ),

              // ✅ قسم البيانات الشخصية — إصلاح: تمرير state لكل _buildRow
              SliverToBoxAdapter(
                child: CustomDataCard(
                  sectionTitle: context.tr('personal_data'),
                  items: [
                    _buildRow(context, state, "height", "height"),
                    _buildRow(
                      context,
                      state,
                      "marital_status",
                      "maritalStatus",
                    ),
                    _buildRow(context, state, "job", "job"),
                    _buildRow(context, state, "education", "educationLevel"),
                    _buildRow(context, state, "hobbies", "hobbies"),
                  ],
                ),
              ),

              // ✅ قسم الأهداف — "goalMarry" هنا صح في مكانه
              SliverToBoxAdapter(
                child: CustomDataCard(
                  sectionTitle: context.tr('goals'),
                  items: [
                    _buildRow(context, state, "marriage", "goalMarry"),
                    _buildRow(context, state, "engagement", "goalEngagment"),
                    _buildRow(context, state, "travel", "goalTravel"),
                    _buildRow(context, state, "family", "goalChildren"),
                  ],
                ),
              ),

              // ✅ قسم الدين والعادات
              SliverToBoxAdapter(
                child: CustomDataCard(
                  sectionTitle: context.tr('religion_and_habits'),
                  items: [
                    _buildRow(
                      context,
                      state,
                      "religious_commitment",
                      "religiousCommitment",
                    ),
                    _buildRow(context, state, "smoking", "smoker"),
                    _buildRow(context, state, "hijab", "wearHijab"),
                  ],
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 20)),

              _buildApplyButton(context, state),
            ],
          );
        },
      ),
    );
  }

  /// ✅ دالة للتنقل إلى شاشة الاختيار
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
      context.read<MarriageFilterCubit>().updateField(fieldKey, result);
    }
  }

  // ✅ إصلاح: إضافة state كـ parameter بدل context.read داخل الدالة
  FilterItemModel _buildRow(
    BuildContext context,
    MarriageFilterState state,
    String title,
    String fieldKey,
  ) {
    final value = state.selectedFilters[fieldKey];

    String displayValue = context.tr('no_preference');
    if (value is String && value.isNotEmpty && value != 'no_preference') {
      displayValue = value.contains('_') ? context.tr(value) : value;
    }
    if (value is List && value.isNotEmpty) {
      displayValue = "${value.length} ${context.tr('selected')}";
    }

    return FilterItemModel(
      title: context.tr(title),
      value: displayValue,
      onTap: () => _navigateToSelection(
        context,
        fieldKey: fieldKey,
        currentValue: value,
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(context.tr('filter_profiles'), style: Styles.textStyle18Bold),
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.grey),
        onPressed: () => context.pop(),
      ),
      actions: [
        TextButton(
          onPressed: () => context.read<MarriageFilterCubit>().resetFilters(),
          child: Text(
            context.tr('clear_filters'),
            style: Styles.textStyle14.copyWith(
              color: Colors.grey[700],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton(BuildContext context, MarriageFilterState state) {
    final hasFilters =
        state.selectedFilters.isNotEmpty ||
        state.ageRange != const RangeValues(22, 35);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Center(
          child: CustomBotton(
            backGroundcolor: AppColors.kgreyColor,
            useGradient: hasFilters,
            width: context.width * 0.9,
            title: context.tr('apply_filters'),
            onPressed: () {
              if (hasFilters) {
                context.read<MarriageFilterCubit>().sendMarriageFilter();
              }
            },
          ),
        ),
      ),
    );
  }
}
