import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/views/image_viewer_view.dart';
import 'package:tayseer/my_import.dart';

class PostImagesGrid extends StatelessWidget {
  final List<String> images;
  final String postId;
  final PostModel? post;
  final bool isFromPostDetails;
  final PostCallbacks callbacks;
  final bool isFromProfile;

  const PostImagesGrid({
    super.key,
    required this.images,
    required this.postId,
    this.post,
    required this.isFromPostDetails,
    this.callbacks = const PostCallbacks(),
    required this.isFromProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    // ✅ 1. لو صورة واحدة: اللوجيك الجديد
    if (images.length == 1) {
      return _buildSingleImage(context);
    }

    // ✅ 2. لو أكثر من صورة: Grid ثابت
    final height = context.responsiveHeight(250);
    final gap = context.responsiveWidth(4);

    return SizedBox(
      height: height,
      child: Row(children: _buildMultiLayout(context, gap, isFromProfile)),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🖼️ Single Image Logic (الحل النهائي للريسايز)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSingleImage(BuildContext context) {
    // ارتفاع الشيمر فقط (عشان التحميل)
    final double placeholderHeight = context.responsiveHeight(250);
    // أقصى ارتفاع مسموح (عشان الصور الطويلة أوي متغطيش الشاشة)
    final double maxAllowedHeight = context.responsiveHeight(500);

    return GestureDetector(
      onTap: () => _openGallery(context, 0),
      child: Hero(
        tag: 'post_${postId}_img_${images[0]}',
        placeholderBuilder: (_, __, child) => child,
        child: Container(
          width: double.infinity,
          // ✅ التعديل هنا: شيلنا minHeight
          // سيبنا بس maxHeight عشان لو الصورة طويلة أوي يقصها
          constraints: BoxConstraints(maxHeight: maxAllowedHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: images[0],

              // ✅ fitWidth: بيخلي الصورة تملى العرض، وطولها يبقى على قدها بالظبط
              // لو الصورة قصيرة، الكونتينر هيقصر معاها ومش هيبقى فيه فراغات
              // لو الصورة طويلة عن 500، هتتقص من فوق وتحت
              fit: BoxFit.fitWidth,

              // محاذاة الصورة في النص عشان لو اتقصت تتقص من فوق وتحت بالتساوي
              alignment: Alignment.center,

              // ✅ الشيمر بس هو اللي ليه طول ثابت عشان اللودينج
              placeholder: (context, url) => Container(
                height: placeholderHeight,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Center(), // ممكن تحط سبينر هنا لو حابب
              ),

              errorWidget: (context, url, error) => Container(
                height: placeholderHeight,
                width: double.infinity,
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, color: Colors.grey[400]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔢 Multi Images Logic (Grid) - زي ما هو بدون تغيير
  // ══════════════════════════════════════════════════════════════════════════
  List<Widget> _buildMultiLayout(
    BuildContext context,
    double gap,
    bool isFromProfile,
  ) {
    final count = images.length;

    if (count == 2) {
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
      final remainingCount = count - 3;
      return [
        _buildRoundedImage(context, 0, images[0]),
        Gap(gap),
        _buildRoundedImage(context, 1, images[1]),
        Gap(gap),
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
    final heroTag = 'post_${postId}_img_$imagePath';

    return Expanded(
      child: GestureDetector(
        onTap: () => _openGallery(context, index),
        child: Hero(
          tag: heroTag,
          placeholderBuilder: (_, __, child) => child,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                if (moreCount > 0)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Text(
                        "+$moreCount",
                        style: Styles.textStyle20Bold.copyWith(
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

  void _openGallery(BuildContext context, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => ImageViewerView(
          isFromProfile: isFromProfile,
          images: images,
          initialIndex: index,
          postId: postId,
          post: post,
          isFromPostDetails: isFromPostDetails,
          callbacks: callbacks,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
