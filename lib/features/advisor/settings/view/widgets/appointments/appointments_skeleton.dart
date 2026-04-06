import 'package:skeletonizer/skeletonizer.dart' as skeletonizer;
import 'package:tayseer/my_import.dart';

class AppointmentsSkeleton extends StatelessWidget {
  const AppointmentsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return skeletonizer.Skeletonizer(
      enabled: true,
      effect: skeletonizer.ShimmerEffect(
        baseColor: AppColors.secondary200,
        highlightColor: AppColors.kWhiteColor,
        duration: const Duration(milliseconds: 1000),
      ),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: 7,
        separatorBuilder: (_, __) => Gap(20.h),
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  Container(
                    width: 48.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ],
              ),
              Gap(16.h),
              Row(
                children: [
                  Container(
                    width: 30.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: Container(
                      height: 55.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                  Gap(8.w),
                  Container(
                    width: 30.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    child: Container(
                      height: 55.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
