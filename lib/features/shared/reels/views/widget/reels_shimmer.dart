import 'dart:ui';
import 'package:tayseer/my_import.dart';

/// ✅ شيمر بنفس شكل الريلز بالظبط — هيدر + أزرار جانبية + معلومات يوزر
class ReelsShimmer extends StatelessWidget {
  const ReelsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[700]!,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // 1. Header — نفس شكل _buildHeader في ReelsOverlay
              _buildShimmerHeader(context),

              const Spacer(),

              // 2. Bottom Content — نفس تنسيق الأوفر لاي
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // أ. الأزرار الجانبية
                      _buildShimmerSideActions(context),
                      Gap(10.w),
                      // ب. معلومات المستخدم
                      Expanded(child: _buildShimmerUserInfo(context)),
                    ],
                  ),
                ),
              ),
              Gap(24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.1),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // X button placeholder
                Container(
                  width: 28.sp,
                  height: 28.sp,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                ),
                // info button placeholder
                Container(
                  width: 26.sp,
                  height: 26.sp,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerSideActions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        4,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index < 3 ? context.responsiveHeight(22) : 0,
          ),
          child: Column(
            children: [
              // أيقونة الأكشن — نفس حجم CircularIconButton (50x50)
              Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  shape: BoxShape.circle,
                ),
              ),
              Gap(4.h),
              // العدد تحت الأيقونة
              Container(
                width: 24.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerUserInfo(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الاسم + زر المتابعة + أيقونة التوثيق
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Follow button placeholder
                      Container(
                        width: 60.w,
                        height: 24.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      Gap(8.w),
                      // Verified icon placeholder
                      Container(
                        width: 16.sp,
                        height: 16.sp,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                      ),
                      Gap(4.w),
                      // الاسم
                      Container(
                        width: 100.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),

                  Gap(4.h),

                  // الوقت + اليوزر نيم
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 40.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Gap(context.responsiveWidth(5)),
                      Container(
                        width: 12.sp,
                        height: 12.sp,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          shape: BoxShape.circle,
                        ),
                      ),
                      Gap(context.responsiveWidth(5)),
                      Container(
                        width: 70.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Gap(10.w),

            // الأفاتار — نفس الحجم 45x45
            Container(
              width: 45.w,
              height: 45.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[800]!, width: 1.5),
                color: Colors.grey[800],
              ),
            ),
          ],
        ),

        Gap(8.h),

        // سطر المحتوى — نفس مكان PostContentText
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Container(
            width: double.infinity,
            height: 14.h,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
      ],
    );
  }
}
