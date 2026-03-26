import 'package:skeletonizer/skeletonizer.dart';
import 'package:tayseer/my_import.dart';

class CertificatesSkeleton extends StatelessWidget {
  const CertificatesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 24.h),
      child: Skeletonizer(
        enabled: true,
        child: Column(
          children: [
            _buildVideoPlaceholder(),
            Gap(24.h),
            ..._buildCertificatePlaceholders(),
            Gap(24.h),
            _buildBoostButtonPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Container(
      width: double.infinity,
      height: 400.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }

  List<Widget> _buildCertificatePlaceholders() {
    return List.generate(
      3,
      (index) => Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110.w,
                height: 85.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              Gap(16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120.w, height: 20.h, color: Colors.grey.shade400),
                    Gap(8.h),
                    Container(width: 100.w, height: 16.h, color: Colors.grey.shade400),
                    Gap(8.h),
                    Container(width: 60.w, height: 16.h, color: Colors.grey.shade400),
                  ],
                ),
              ),
              Gap(16.w),
              Container(width: 20.w, height: 20.w, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoostButtonPlaceholder() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35.w),
      child: Container(
        width: double.infinity,
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}
