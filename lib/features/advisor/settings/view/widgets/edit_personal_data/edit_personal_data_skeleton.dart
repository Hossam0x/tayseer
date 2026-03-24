import 'package:tayseer/my_import.dart';

class EditPersonalDataSkeleton extends StatelessWidget {
  const EditPersonalDataSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            height: 150.h,
            width: 155.w,
            decoration: BoxDecoration(
              color: AppColors.secondary100,
              borderRadius: BorderRadius.circular(32.r),
            ),
            child: Center(
              child: Icon(
                Icons.person,
                size: 50.w,
                color: AppColors.secondary300,
              ),
            ),
          ),
        ),
        Gap(20.h),
        _skeletonBox(height: 48.h),
        Gap(11.h),
        _skeletonBox(height: 48.h),
        Gap(11.h),
        _skeletonBox(height: 48.h),
        Gap(11.h),
        _skeletonBox(height: 48.h),
        Gap(11.h),
        _skeletonBox(height: 150.h),
        Gap(25.h),
        _skeletonBox(height: 250.h),
        Gap(35.h),
        _skeletonBox(height: 48.h),
      ],
    );
  }

  Widget _skeletonBox({required double height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondary100,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }
}
