import 'package:tayseer/my_import.dart';

class AdvisorSearchSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const AdvisorSearchSectionHeader({
    super.key,
    required this.title,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Styles.textStyle16Bold.copyWith(
              color: AppColors.kprimaryColor,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  context.tr("see_all"),
                  style: Styles.textStyle14.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12.sp,
                  color: AppColors.kprimaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
