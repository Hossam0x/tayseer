import 'package:tayseer/my_import.dart';

/// ويدجت نهاية البوستات المحفوظة — تظهر في آخر القائمة أثناء الأوفلاين
class EndOfCachedPosts extends StatelessWidget {
  const EndOfCachedPosts({
    super.key,
    this.addTopPadding = false,
    this.isEmpty = false,
  });

  final bool addTopPadding;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: addTopPadding ? 150.h : 32.h,
        bottom: 32.h,
        left: 24.w,
        right: 24.w,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(AssetsData.noInternet, width: 64.w, height: 64.w),
          SizedBox(height: 12.h),
          Text(
            isEmpty
                ? context.tr(AppStrings.offlineNoPostsCached)
                : context.tr(AppStrings.offlineViewingCachedPosts),
            style: Styles.textStyle14.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            isEmpty
                ? context.tr(AppStrings.offlineNoPostsCachedSub)
                : context.tr(AppStrings.offlineConnectForMore),
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
