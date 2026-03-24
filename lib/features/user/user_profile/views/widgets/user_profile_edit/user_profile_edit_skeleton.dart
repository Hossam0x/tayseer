import 'package:tayseer/my_import.dart';

class UserProfileEditSkeleton extends StatelessWidget {
  const UserProfileEditSkeleton({super.key});

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
        Gap(30.h),
        _SkeletonField(),
        Gap(16.h),
        _SkeletonField(),
        Gap(16.h),
        _SkeletonField(),
      ],
    );
  }
}

class _SkeletonField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.secondary100,
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}
