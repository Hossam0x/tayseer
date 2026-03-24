import 'package:tayseer/my_import.dart';

class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          Gap(30.h),
          _buildSectionSkeleton(context.tr('personal_info')),
          Gap(30.h),
          _buildSectionSkeleton(context.tr('privacy')),
          Gap(40.h),
        ],
      ),
    );
  }

  Widget _buildSectionSkeleton(String title) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.whiteCard2Back,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16.h, right: 16.w, bottom: 8.h),
            child: Container(
              width: 120.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: AppColors.secondary200,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          Gap(16.h),
          for (var i = 0; i < 4; i++) ...[
            _buildRowSkeleton(),
            if (i < 3)
              Divider(
                height: 1.h,
                color: Colors.grey.shade200,
                indent: 15,
                endIndent: 15,
              ),
            Gap(10.h),
          ],
        ],
      ),
    );
  }

  Widget _buildRowSkeleton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 150.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.secondary200,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          const Spacer(),
          Container(
            width: 80.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: AppColors.secondary200,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          Gap(10.w),
          Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: AppColors.secondary200,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
