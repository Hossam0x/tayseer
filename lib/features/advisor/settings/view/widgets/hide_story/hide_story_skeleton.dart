import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/my_import.dart';

class HideStorySkeleton extends StatelessWidget {
  const HideStorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            Container(height: 1, color: Colors.grey.shade200),
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120.w,
                      height: 18.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    Gap(6.h),
                    Container(
                      width: 80.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
