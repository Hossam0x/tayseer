import 'package:tayseer/core/utils/app_strings.dart';
import 'package:tayseer/my_import.dart';

/// ويدجت نهاية البوستات المحفوظة — تظهر في آخر القائمة أثناء الأوفلاين
class EndOfCachedPosts extends StatelessWidget {
  const EndOfCachedPosts({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AssetsData.noInternet, width: 64.w, height: 64.w),
          SizedBox(height: 12.h),
          Text(
            context.tr(AppStrings.offlineViewingCachedPosts),
            style: Styles.textStyle14.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            context.tr(AppStrings.offlineConnectForMore),
            style: Styles.textStyle12.copyWith(color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Container(
            width: 4.w,
            height: 4.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}
