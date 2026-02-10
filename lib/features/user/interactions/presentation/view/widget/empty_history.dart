import 'package:tayseer/my_import.dart';

class EmptyHistory extends StatelessWidget {
  final String selectedFilter;
  
  const EmptyHistory({
    this.selectedFilter = "",
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(AssetsData.emptyBoxImage, width: 260.w),

          SizedBox(height: 24.h),

          Text(
            context.tr("subscribe_to_see_marriage_history"), // ✅ ترجمة
            textAlign: TextAlign.center,
            style: Styles.textStyle16SemiBold.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.secondary400,
            ),
          ),

          SizedBox(height: 11.w),

          Text(
            context.tr("subscribe_to_see_history_desc"), // ✅ ترجمة
            textAlign: TextAlign.center,
            style: Styles.textStyle14.copyWith(
              color: AppColors.secondary200,
              fontWeight: FontWeight.w400,
              height: 1.5.h,
            ),
          ),

          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}