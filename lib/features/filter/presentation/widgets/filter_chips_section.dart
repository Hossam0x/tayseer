import '../../../../my_import.dart';
import '../cubit/advisor_filter_cubit.dart';
import '../cubit/advisor_filter_state.dart';

class FilterChipsSection extends StatelessWidget {
  final List<String> items;
  final bool isLanguages;

  const FilterChipsSection({
    super.key,
    required this.items,
    this.isLanguages = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdvisorFilterCubit, AdvisorFilterState>(
      buildWhen: (previous, current) {
        if (isLanguages) {
          return previous.selectedLanguages != current.selectedLanguages;
        }
        return previous.selectedBadges != current.selectedBadges;
      },
      builder: (context, state) {
        final List<String> selectedList = isLanguages
            ? state.selectedLanguages
            : state.selectedBadges;
        return Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: items.map((item) {
            bool isSelected = selectedList.contains(item.toLowerCase());
            return GestureDetector(
              onTap: () {
                if (isLanguages) {
                  context.read<AdvisorFilterCubit>().toggleLanguage(
                    item.toLowerCase(),
                  );
                } else {
                  context.read<AdvisorFilterCubit>().toggleBadge(
                    item.toLowerCase(),
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary50 : Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.kprimaryColor
                        : AppColors.secondary100,
                  ),
                ),
                child: Text(
                  context.tr(item.toLowerCase()),
                  style: Styles.textStyle14.copyWith(
                    color: isSelected
                        ? AppColors.kprimaryColor
                        : AppColors.secondary800,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
