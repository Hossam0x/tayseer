import 'package:dropdown_button2/dropdown_button2.dart';
import '../../../../my_import.dart';
import '../cubit/advisor_filter_cubit.dart';
import '../cubit/advisor_filter_state.dart';

// ✅ Model لفصل الـ value عن الـ display label
class _ExperienceOption {
  final String value;  // القيمة اللي بتتبعت للـ API  (رقم string)
  final String label;  // النص اللي بيتعرض للمستخدم

  const _ExperienceOption({required this.value, required this.label});
}

class ExperienceDropdown extends StatelessWidget {
  const ExperienceDropdown({super.key});

  // ✅ values صريحة — كل value هي الرقم الأول من النطاق
  // الـ cubit هيحولها لـ "1_years", "3_years", etc.
  static const List<_ExperienceOption> _options = [
    _ExperienceOption(value: '1',  label: '1 - 3 years'),
    _ExperienceOption(value: '3',  label: '3 - 5 years'),
    _ExperienceOption(value: '5',  label: '5 - 10 years'),
    _ExperienceOption(value: '10', label: '10+ years'),
  ];

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
              // ✅ value = الرقم فقط ("1", "3", "5", "10")
              items: _options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option.value,
                      child: Text(option.label, style: Styles.textStyle14),
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