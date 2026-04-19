import 'package:tayseer/my_import.dart';

class PostCardShimmer extends StatelessWidget {
  const PostCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        // ✅ شيلنا الـ border radius عشان يبقى حواف حادة زي انستغرام
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with padding
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: _buildHeader(),
            ),
            Gap(15.h),
            // Text with padding
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: _buildTextLines(),
            ),
            Gap(12.h),
            // Image without padding (full width)
            _buildImagePlaceholder(),
            Gap(15.h),
            // Stats and actions with padding
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildStats(), Gap(8.h), _buildActions()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
    children: [
      _circle(48.w),
      Gap(12.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _rect(width: 120.w, height: 14.h),
            Gap(6.h),
            _rect(width: 180.w, height: 12.h),
          ],
        ),
      ),
    ],
  );

  Widget _buildTextLines() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _rect(width: double.infinity, height: 14.h),
      Gap(8.h),
      _rect(width: 250.w, height: 14.h),
    ],
  );

  Widget _buildImagePlaceholder() => _rect(
    width: double.infinity,
    height: 250.h, // ✅ رجعناه لحجم مناسب
    radius: 0,
  );

  Widget _buildStats() => Center(
    child: _rect(width: 150.w, height: 12.h),
  );

  Widget _buildActions() => Row(
    children: [_circle(38.w), Gap(6.w), _circle(38.w), Gap(6.w), _circle(38.w)],
  );

  Widget _circle(double size) => Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
    ),
  );

  Widget _rect({
    required double width,
    required double height,
    double radius = 4,
  }) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius.r),
    ),
  );
}
