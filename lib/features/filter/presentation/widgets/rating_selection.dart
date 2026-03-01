import '../../../../my_import.dart';
import '../cubit/advisor_filter_cubit.dart';
import '../cubit/advisor_filter_state.dart';

class RatingSelection extends StatelessWidget {
  const RatingSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AdvisorFilterCubit, AdvisorFilterState, int>(
      selector: (state) => state.selectedRating,
      builder: (context, selectedRating) {
        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: List.generate(5, (index) {
            int rating = 5 - index;
            bool isSelected = selectedRating == rating;
            return GestureDetector(
              onTap: () {
                context.read<AdvisorFilterCubit>().toggleRating(rating);
              },
              child: AnimatedScale(
                scale: isSelected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary50 : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.kprimaryColor
                          : AppColors.secondary100,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.kprimaryColor.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < rating ? Icons.star : Icons.star_border,
                        color: starIndex < rating
                            ? AppColors.kprimaryColor
                            : AppColors.secondary200,
                        size: 18.sp,
                      );
                    }),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
