import 'package:tayseer/my_import.dart';

class SelectionCard extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            Text(label, style: Styles.textStyle16Meduim),
            const Spacer(),
            Text(
              value,
              style: Styles.textStyle16.copyWith(color: AppColors.secondary),
            ),
            Gap(10.w),
            Icon(
              Icons.arrow_forward_ios,
              size: 14.w,
              color: AppColors.dropDownArrow,
            ),
          ],
        ),
      ),
    );
  }
}
