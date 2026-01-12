import 'package:tayseer/features/advisor/home/model/post_model.dart';
import 'package:tayseer/features/advisor/home/view_model/home_cubit.dart';
import 'package:tayseer/my_import.dart';
// تأكد من استيراد ImageViewerView
import 'package:tayseer/features/advisor/home/views/image_viewer_view.dart';

class PostImagesGrid extends StatelessWidget {
  final List<String> images;
  final String postId; // ✅ ضروري عشان الـ Hero
  final PostModel? post; // نمرره عشان نبعته للفيو
  final bool isFromPostDetails;
  const PostImagesGrid({
    super.key,
    required this.images,
    required this.postId,
    this.post,
    required this.isFromPostDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    final double height = context.responsiveHeight(206);
    final double gap = context.responsiveWidth(
      4,
    ); // تقليل المسافة قليلاً لتتناسب مع الصور

    return SizedBox(
      height: height,
      child: Row(children: _buildLayout(context, gap)),
    );
  }

  void _openGallery(BuildContext context, int index) {
    // ✅ Navigation Logic with Hero Animation Support
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, // مهم عشان الترانزيشن يبان ناعم
        pageBuilder: (_, __, ___) => ImageViewerView(
          homeCubit: context.read<HomeCubit>(),
          images: images,
          initialIndex: index,
          postId: postId,
          isFromPostDetails: isFromPostDetails,
          post: post,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  List<Widget> _buildLayout(BuildContext context, double gap) {
    int count = images.length;

    if (count == 1) {
      return [_buildRoundedImage(context, 0, images[0])];
    } else if (count == 2) {
      return [
        _buildRoundedImage(context, 0, images[0]),
        Gap(gap),
        _buildRoundedImage(context, 1, images[1]),
      ];
    } else if (count == 3) {
      return [
        _buildRoundedImage(context, 0, images[0]),
        Gap(gap),
        _buildRoundedImage(context, 1, images[1]),
        Gap(gap),
        _buildRoundedImage(context, 2, images[2]),
      ];
    } else {
      // 4 صور أو أكثر
      int remainingCount = count - 3;
      return [
        _buildRoundedImage(context, 0, images[0]),
        Gap(gap),
        _buildRoundedImage(context, 1, images[1]),
        Gap(gap),
        // الصورة الأخيرة هتفتح الجاليري عند الإندكس 2 (الصورة الثالثة)
        _buildRoundedImage(context, 2, images[2], moreCount: remainingCount),
      ];
    }
  }

  Widget _buildRoundedImage(
    BuildContext context,
    int index,
    String imagePath, {
    int moreCount = 0,
  }) {
    // ✅ Hero Tag Generation
    final String heroTag = 'post_${postId}_img_$imagePath';

    return Expanded(
      child: GestureDetector(
        onTap: () => _openGallery(context, index),
        child: Hero(
          tag: heroTag,
          // Placeholder يمنع الوميض أثناء الانتقال
          placeholderBuilder: (context, heroSize, child) => child,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. الصورة
                AppImage(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),

                // 2. طبقة الرقم (+3)
                if (moreCount > 0)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Text(
                        "+$moreCount",
                        style: Styles.textStyle20Bold.copyWith(
                          // استخدم ستايل مناسب
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
