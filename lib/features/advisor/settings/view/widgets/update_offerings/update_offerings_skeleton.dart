import 'package:skeletonizer/skeletonizer.dart' as skeletonizer;
import 'package:tayseer/my_import.dart';

class UpdateOfferingsSkeleton extends StatelessWidget {
  const UpdateOfferingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return skeletonizer.Skeletonizer(
      enabled: true,
      effect: skeletonizer.ShimmerEffect(
        baseColor: AppColors.secondary100,
        highlightColor: AppColors.kWhiteColor.withOpacity(0.8),
        duration: const Duration(milliseconds: 1200),
      ),
      child: Column(
        children: [
          // Stats banner skeleton
          Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),

          Gap(16.h),

          // Country cards skeleton
          Expanded(
            child: ListView.separated(
              itemCount: 2,
              separatorBuilder: (_, __) => Gap(14.h),
              itemBuilder: (_, __) => _CountryCardSkeleton(),
            ),
          ),

          // Bottom buttons skeleton
          Gap(12.h),
          Container(
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          Gap(12.h),
          Container(
            width: double.infinity,
            height: 54.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          Gap(20.h),
        ],
      ),
    );
  }
}

class _CountryCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                // Delete button placeholder
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 80.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Gap(4.h),
                      Container(
                        width: 50.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                // Flag placeholder
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.grey.shade100, height: 1, thickness: 1),

          // Offering rows
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Column(
              children: [
                _OfferingRowSkeleton(),
                Gap(8.h),
                _OfferingRowSkeleton(),
                Gap(8.h),
                // Add button placeholder
                Container(
                  width: double.infinity,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferingRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Delete icon
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        // Name
        Expanded(
          child: Container(
            height: 12.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        // Chips
        Row(
          children: List.generate(
            3,
            (i) => Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Container(
                width: i == 0
                    ? 52.w
                    : i == 1
                    ? 36.w
                    : 44.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
