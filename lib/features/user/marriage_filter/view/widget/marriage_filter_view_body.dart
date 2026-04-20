import 'package:tayseer/core/widgets/custom_build_age_and_country_section.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/user/user_profile/presentation/view_model/user_packages_cubit.dart';
import 'package:tayseer/features/user/marriage_filter/view/widget/custom_data_card.dart';
import 'package:tayseer/features/user/marriage_filter/view/widget/filter_selection_body.dart';
import 'package:tayseer/features/user/marriage_filter/view_models/marriage_filter_cubit.dart';
import 'package:tayseer/features/user/marriage_filter/view_models/marriage_filter_state.dart';
import 'package:tayseer/my_import.dart';

class MarriageFilterBody extends StatelessWidget {
  const MarriageFilterBody({super.key, this.onBackPressed});

  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    return CustomBackground(
      child: BlocConsumer<MarriageFilterCubit, MarriageFilterState>(
        listener: (context, state) {
          if (state.marriageFilterStatus == CubitStates.loading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CustomloadingApp()),
            );
          } else if (state.marriageFilterStatus == CubitStates.success) {
            // ✅ أغلق الـ loading dialog
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            // ✅ ارجع من صفحة الفلتر
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } else if (state.marriageFilterStatus == CubitStates.failure) {
            // ✅ أغلق الـ loading dialog
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
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
          final countryRaw = state.selectedFilters['country']?.toString();
          final nationalityRaw = state.selectedFilters['nationality']
              ?.toString();

          final countryDisplay =
              (countryRaw != null &&
                  countryRaw.isNotEmpty &&
                  countryRaw != 'no_preference')
              ? context.tr(countryRaw)
              : null;

          final nationalityDisplay =
              (nationalityRaw != null &&
                  nationalityRaw.isNotEmpty &&
                  nationalityRaw != 'no_preference')
              ? context.tr(nationalityRaw)
              : null;

          final hasFilters =
              state.selectedFilters.isNotEmpty ||
              state.ageRange != const RangeValues(22, 35);

          return Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    _buildSliverAppBar(context),

                    SliverToBoxAdapter(
                      child: CustomAgeAndCountrySection(
                        ageRange: state.ageRange,
                        onAgeRangeChanged: (values) {
                          context.read<MarriageFilterCubit>().updateAgeRange(
                            values,
                          );
                        },
                        countryValue: countryDisplay,
                        nationalityValue: nationalityDisplay,
                        onCountryTap: () => _navigateToSelection(
                          context,
                          fieldKey: 'country',
                          currentValue: countryRaw,
                        ),
                        onNationalityTap: () => _navigateToSelection(
                          context,
                          fieldKey: 'nationality',
                          currentValue: nationalityRaw,
                        ),
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: CustomDataCard(
                        sectionTitle: context.tr('data_and_activities'),
                        items: [
                          _buildRow(context, state, 'verified_id', 'isVerified'),
                          _buildRow(context, state, 'new_member', 'isNew'),
                          _buildRow(context, state, 'photo_status', 'imageBlur'),
                        ],
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: CustomDataCard(
                        sectionTitle: context.tr('personal_data'),
                        items: [
                          _buildRow(context, state, 'height', 'height'),
                          _buildRow(
                            context,
                            state,
                            'marital_status',
                            'maritalStatus',
                          ),
                          _buildRow(context, state, 'job', 'job'),
                          _buildRow(context, state, 'education', 'educationLevel'),
                          _buildRow(context, state, 'hobbies', 'hobbies'),
                        ],
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: CustomDataCard(
                        sectionTitle: context.tr('goals'),
                        items: [
                          _buildRow(context, state, 'marriage', 'goalMarry'),
                          _buildRow(context, state, 'engagement', 'goalEngagment'),
                          _buildRow(context, state, 'travel', 'goalTravel'),
                          _buildRow(context, state, 'family', 'goalChildren'),
                        ],
                      ),
                    ),

                    SliverToBoxAdapter(
                      child: CustomDataCard(
                        sectionTitle: context.tr('religion_and_habits'),
                        items: [
                          _buildRow(
                            context,
                            state,
                            'religious_commitment',
                            'religiousCommitment',
                          ),
                          _buildRow(context, state, 'smoking', 'smoker'),
                          _buildRow(context, state, 'hijab', 'wearHijab'),
                        ],
                      ),
                    ),

                    // ✅ لو مفيش فلاتر: الزر في آخر الـ scroll
                    // ✅ لو في فلاتر: padding عشان الزر الـ floating ميغطيش المحتوى
                    if (!hasFilters)
                      SliverToBoxAdapter(
                        child: _buildApplyButtonWidget(context, state),
                      )
                    else
                      const SliverPadding(padding: EdgeInsets.only(bottom: 90)),
                  ],
                ),

                // ✅ الزر الـ floating يظهر بس لما في فلاتر مطبقة
                if (hasFilters)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildApplyButtonWidget(context, state),
                  ),
              ],
            ),
          );
        },
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
      context.read<MarriageFilterCubit>().updateField(fieldKey, result);
    }
  }

  FilterItemModel _buildRow(
    BuildContext context,
    MarriageFilterState state,
    String title,
    String fieldKey,
  ) {
    final value = state.selectedFilters[fieldKey];

    String displayValue = context.tr('no_preference');

    if (value is int) {
      displayValue = '$value ${context.tr('cm')}';
    } else if (value is String &&
        value.isNotEmpty &&
        value != 'no_preference') {
      displayValue = context.tr(value);
    } else if (value is List && value.isNotEmpty) {
      displayValue = '${value.length} ${context.tr('selected')}';
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
        onPressed:
            onBackPressed ?? () => context.pop(), // ✅ استخدم الـ callback
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

  Widget _buildApplyButtonWidget(BuildContext context, MarriageFilterState state) {
    final hasFilters =
        state.selectedFilters.isNotEmpty ||
        state.ageRange != const RangeValues(22, 35);

    const freeKeys = {'country', 'nationality'};
    final hasPaidFilters = state.selectedFilters.keys
        .any((key) => !freeKeys.contains(key));

    return Container(
      // color: Colors.white.withOpacity(0.95),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      child: CustomBotton(
        backGroundcolor: AppColors.kgreyColor,
        useGradient: hasFilters,
        width: double.infinity,
        title: context.tr('apply_filters'),
        onPressed: () async {
          if (!hasFilters) return;

          if (hasPaidFilters) {
            final cachedSub = await UserPackagesCubit.getCachedSubType();
            final isFree = cachedSub == null;
            if (!context.mounted) return;
            if (isFree) {
              showFiltterLimitDialogs(
                context,
                onSubscribe: () =>
                    context.pushNamed(AppRouter.kUserPackagesView),
              );
              return;
            }
          }

          if (context.mounted) {
            context.read<MarriageFilterCubit>().sendMarriageFilter();
          }
        },
      ),
    );
  }
}
