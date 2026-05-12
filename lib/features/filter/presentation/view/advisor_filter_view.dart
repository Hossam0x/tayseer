import 'package:tayseer/features/filter/presentation/cubit/advisor_filter_state.dart';
import '../../../../my_import.dart';
import '../cubit/advisor_filter_cubit.dart';
import '../widgets/price_range_slider.dart';
import '../widgets/experience_dropdown.dart';
import '../widgets/rating_selection.dart';
import '../widgets/filter_chips_section.dart';
import '../widgets/filter_calendar.dart';
import '../widgets/filter_section_title.dart';

class AdvisorFilterView extends StatelessWidget {
  const AdvisorFilterView({super.key});

  Future<void> _onBackPressed(BuildContext context) async {
    final cubit = context.read<AdvisorFilterCubit>();

    if (!cubit.state.isFilterComplete) {
      Navigator.pop(context);
      return;
    }

    // ✅ شيل الـ await — الدالة void مش Future
    CustomshowDialogWithImage(
      context,
      title: context.tr("filter_profiles"),
      supTitle: context.tr("apply_filters"),
      imageUrl: AssetsData.kWoriningImage,
      bottonText: context.tr("no"),
      cancelText: context.tr("yes"),
      showCancelButton: true,
      onPressed: () {
        Navigator.pop(context); // ارجع من صفحة الفلتر
      },
      onCancel: () {
        // أغلق الـ dialog
        cubit.applyFilters(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdvisorFilterCubit(),
      child: Builder(
        builder: (context) {
          return WillPopScope(
            onWillPop: () async {
              await _onBackPressed(context);
              return false; // ✅ نمنع الـ pop التلقائي ونتحكم فيه يدوياً
            },
            child: AdvisorBackground(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: SizedBox(
                        height: kToolbarHeight,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.secondary800,
                              ),
                              onPressed: () => _onBackPressed(context),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  context.tr("filter_profiles"),
                                  style: Styles.textStyle24Meduim.copyWith(
                                    color: AppColors.secondary700,
                                  ),
                                ),
                              ),
                            ),
                            const ClearFiltersButton(),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(child: AdvisorFilterBody()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdvisorFilterBody extends StatelessWidget {
  const AdvisorFilterBody({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_LangOption> languages = [
      _LangOption(apiCode: 'ar', labelKey: 'arabic'),
      _LangOption(apiCode: 'en', labelKey: 'english'),
      _LangOption(apiCode: 'fr', labelKey: 'french'),
      _LangOption(apiCode: 'de', labelKey: 'german'),
    ];

    final List<String> badges = [
      'influencer',
      'expert',
      'fast_response',
      'trusted',
      'inspired',
      'listener',
      'wise',
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(20.h),
          FilterSectionTitle(title: context.tr("price")),
          const PriceRangeSlider(),
          Gap(30.h),
          FilterSectionTitle(title: context.tr("experience")),
          const ExperienceDropdown(),
          Gap(30.h),
          FilterSectionTitle(title: context.tr("rate")),
          const RatingSelection(),
          Gap(30.h),
          FilterSectionTitle(title: context.tr("language")),
          FilterChipsSection(
            items: languages.map((l) => l.apiCode).toList(),
            labelKeys: languages.map((l) => l.labelKey).toList(),
            isLanguages: true,
          ),
          Gap(30.h),
          FilterSectionTitle(title: context.tr("Medals")),
          FilterChipsSection(items: badges, isLanguages: false),
          Gap(30.h),
          FilterSectionTitle(title: context.tr("appointments")),
          const FilterCalendar(),
          Gap(40.h),
          const ApplyFiltersButton(),
          Gap(40.h),
        ],
      ),
    );
  }
}

class _LangOption {
  final String apiCode;
  final String labelKey;
  const _LangOption({required this.apiCode, required this.labelKey});
}

class ClearFiltersButton extends StatelessWidget {
  const ClearFiltersButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: TextButton(
        onPressed: () => context.read<AdvisorFilterCubit>().clearFilters(),
        child: Text(
          context.tr("clear_filters"),
          style: Styles.textStyle14.copyWith(
            color: AppColors.secondary400,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class ApplyFiltersButton extends StatelessWidget {
  const ApplyFiltersButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvisorFilterCubit, AdvisorFilterState>(
      buildWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading ||
          prev.isFilterComplete != curr.isFilterComplete,
      builder: (context, state) {
        return CustomBotton(
          title: state.isLoading ? '...' : context.tr("apply_filters"),
          onPressed: state.isLoading
              ? null
              : () => context.read<AdvisorFilterCubit>().applyFilters(context),
          width: double.infinity,
        );
      },
    );
  }
}
