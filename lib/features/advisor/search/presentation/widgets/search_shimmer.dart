import 'package:tayseer/my_import.dart';

class SearchPostShimmer extends StatelessWidget {
  const SearchPostShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // هيدر المستخدم
              Row(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120.w,
                          height: 14.h,
                          color: Colors.white,
                        ),
                        SizedBox(height: 6.h),
                        Container(
                          width: 80.w,
                          height: 12.h,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(width: 20.w, height: 20.w, color: Colors.white),
                ],
              ),

              SizedBox(height: 16.h),

              // محتوى النص
              Container(
                width: double.infinity,
                height: 16.h,
                color: Colors.white,
              ),
              SizedBox(height: 8.h),
              Container(width: 200.w, height: 16.h, color: Colors.white),

              SizedBox(height: 16.h),

              // محاكاة الصور
              Container(
                width: double.infinity,
                height: 150.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),

              SizedBox(height: 16.h),

              // الإحصائيات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 60.w, height: 16.h, color: Colors.white),
                      SizedBox(width: 16.w),
                      Container(width: 60.w, height: 16.h, color: Colors.white),
                    ],
                  ),
                  Container(width: 80.w, height: 16.h, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchGroupShimmer extends StatelessWidget {
  const SearchGroupShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 120.w, height: 16.h, color: Colors.white),
                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    height: 14.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  Container(width: 80.w, height: 12.h, color: Colors.white),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 90.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
