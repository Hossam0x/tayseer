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
    final List<String> languages = ['arabic', 'english', 'french', 'german'];
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
          FilterSectionTitle(title: context.tr("rating")),
          const RatingSelection(),
          Gap(30.h),
          FilterSectionTitle(title: context.tr("language")),
          FilterChipsSection(items: languages, isLanguages: true),
          Gap(30.h),
          FilterSectionTitle(title: context.tr("badges")),
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
    return CustomBotton(
      title: context.tr("apply_filters"),
      onPressed: () {
        context.read<AdvisorFilterCubit>().applyFilters();
        Navigator.pop(context);
      },
      backGroundcolor: const Color(0xff9E9E9E),
      width: double.infinity,
    );
  }
}
