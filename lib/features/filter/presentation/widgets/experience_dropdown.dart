import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../../my_import.dart';
import '../cubit/advisor_filter_cubit.dart';
import '../cubit/advisor_filter_state.dart';

class ExperienceDropdown extends StatelessWidget {
  const ExperienceDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AdvisorFilterCubit, AdvisorFilterState, String?>(
      selector: (state) => state.selectedExperience,
      builder: (context, selectedExperience) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(color: AppColors.secondary100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text(
                context.tr("select_experience_years"),
                style: Styles.textStyle14.copyWith(
                  color: AppColors.secondary400,
                ),
              ),
              items: ['1-3 years', '3-5 years', '5-10 years', '10+ years']
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(item, style: Styles.textStyle14),
                    ),
                  )
                  .toList(),
              value: selectedExperience,
              onChanged: (value) {
                context.read<AdvisorFilterCubit>().updateExperience(value);
              },
              buttonStyleData: ButtonStyleData(height: 50.h),
              dropdownStyleData: DropdownStyleData(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: Colors.white,
                ),
                elevation: 8,
              ),
              menuItemStyleData: MenuItemStyleData(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
            ),
          ),
        );
      },
    );
  }
}
