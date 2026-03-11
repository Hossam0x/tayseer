import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/my_import.dart';

class RatingsSkeleton extends StatelessWidget {
  const RatingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        child: Column(
          children: [
            _buildSummarySkeleton(),
            Gap(20.h),
            ..._buildReviewSkeletons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySkeleton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          Gap(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAverageColumnSkeleton(),
              Gap(24.w),
              Expanded(child: _buildStarBarsSkeleton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAverageColumnSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.grey.shade400,
          ),
          width: 60.w,
          height: 30.h,
        ),
        Gap(8.h),
        Container(
          width: 100.w,
          height: 15.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.grey.shade400,
          ),
        ),
        Gap(8.h),
        Container(
          width: 80.w,
          height: 15.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildStarBarsSkeleton() {
    return Column(
      children: List.generate(
        5,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Row(
            children: [
              Container(
                width: 20.w,
                height: 15.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.grey.shade400,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Container(
                  height: 8.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              Gap(12.w),
              Container(
                width: 60.w,
                height: 15.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildReviewSkeletons() {
    return List.generate(
      3,
      (index) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60.r,
              height: 60.r,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                shape: BoxShape.circle,
              ),
            ),
            Gap(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Container(
                        width: 80.w,
                        height: 15.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  Gap(12.h),
                  Container(
                    width: double.infinity,
                    height: 80.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.grey.shade400,
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
