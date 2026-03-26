import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/my_import.dart';

class SessionPricingSkeleton extends StatelessWidget {
  const SessionPricingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        itemCount: 2,
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
                    width: 100.w,
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
                    width: 60.w,
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
                        border: Border.all(
                          color: AppColors.secondary200.withOpacity(0.5),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Gap(8.w),
                          Container(
                            width: 1.w,
                            height: 25.h,
                            color: Colors.grey.shade400,
                          ),
                          Gap(8.w),
                          Expanded(
                            child: Container(
                              height: 20.h,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade400,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                          ),
                          Gap(16.w),
                          Container(
                            width: 40.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade400,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
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
