import '../../../../my_import.dart';

class FilterSectionTitle extends StatelessWidget {
  final String title;
  const FilterSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: Styles.textStyle16Bold.copyWith(color: AppColors.secondary800),
      ),
    );
  }
}
