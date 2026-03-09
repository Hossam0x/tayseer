import 'package:tayseer/my_import.dart';

/// ✅ شيمر مناسب للريلز — خلفية سودا + عناصر shimmer
class ReelsShimmer extends StatelessWidget {
  const ReelsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Shimmer.fromColors(
        baseColor: Colors.grey[900]!,
        highlightColor: Colors.grey[700]!,
        child: Stack(
          children: [
            // ✅ الخلفية الكاملة shimmer
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[900],
            ),

            // ✅ أزرار الأكشن على اليمين (زي لايك، كومنت، شير)
            Positioned(
              right: 16.w,
              bottom: 120.h,
              child: Column(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 18.r,
                          backgroundColor: Colors.grey[800],
                        ),
                        Gap(6.h),
                        Container(
                          width: 28.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ✅ معلومات المستخدم في الأسفل (أفاتار + اسم + وصف)
            Positioned(
              left: 16.w,
              right: 80.w,
              bottom: 40.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الأفاتار + الاسم
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundColor: Colors.grey[800],
                      ),
                      Gap(10.w),
                      Container(
                        width: 120.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                  Gap(12.h),

                  // وصف الريل - سطرين
                  Container(
                    width: double.infinity,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(8.h),
                  Container(
                    width: 200.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
