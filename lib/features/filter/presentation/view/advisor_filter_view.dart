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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdvisorFilterCubit(),
      child: AdvisorBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(context),
          body: const AdvisorFilterBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        context.tr("filter_profiles"),
        style: Styles.textStyle24Meduim.copyWith(color: AppColors.secondary700),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.close, color: AppColors.secondary800),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [const ClearFiltersButton()],
    );
  }
}

class AdvisorFilterBody extends StatelessWidget {
  const AdvisorFilterBody({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ الـ value = كود اللغة اللي بيتبعت للـ API (ar, en, fr, de)
    // الـ label = مفتاح الترجمة اللي بيتعرض للمستخدم
    final List<_LangOption> languages = [
      _LangOption(apiCode: 'ar',  labelKey: 'arabic'),
      _LangOption(apiCode: 'en',  labelKey: 'english'),
      _LangOption(apiCode: 'fr',  labelKey: 'french'),
      _LangOption(apiCode: 'de',  labelKey: 'german'),
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
          // ✅ بنبعت apiCode للـ cubit، ونعرض الترجمة للمستخدم
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

// ✅ helper model — apiCode للـ API، labelKey للترجمة
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
        onPressed: () {
          context.read<AdvisorFilterCubit>().clearFilters();
        },
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
          onPressed: (state.isLoading || !state.isFilterComplete)
              ? null
              : () => context.read<AdvisorFilterCubit>().applyFilters(context),
          backGroundcolor: state.isFilterComplete
              ? null
              : const Color(0xff9E9E9E),
          width: double.infinity,
        );
      },
    );
  }
}