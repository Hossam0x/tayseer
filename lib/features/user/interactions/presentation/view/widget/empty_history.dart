import 'package:tayseer/my_import.dart';

class EmptyHistory extends StatelessWidget {
  final String selectedFilter;
  const EmptyHistory({this.selectedFilter = "نال إعجابك", super.key});



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 24.0.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppImage(AssetsData.emptyBoxImage, width: 260.w),
    
           SizedBox(height: 24.h),
    
          Text(
            "اشترك حتي تتمكن من رؤية سجلاتك في الزواج",
            textAlign: TextAlign.center,
            style: Styles.textStyle16SemiBold.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.secondary400,
            ),
          ),
    
          SizedBox(height: 11.w),
    
          Text(
            "لن تتمكن من رؤيتهم الا عند الاشتراك بادر بالاشتراك الان .",
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
