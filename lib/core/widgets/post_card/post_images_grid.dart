import 'package:tayseer/core/widgets/connectivity_cached_image.dart';
import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/core/models/post_model.dart';
import 'package:tayseer/features/shared/home/views/image_viewer_view.dart';
import 'package:tayseer/my_import.dart';

class PostImagesGrid extends StatelessWidget {
  final List<ImageModel> images;
  final String postId;
  final PostModel? post;
  final bool isFromPostDetails;
  final PostCallbacks callbacks;
  final bool isFromProfile;
  final String? heroPrefix;

  const PostImagesGrid({
    super.key,
    required this.images,
    required this.postId,
    this.post,
    required this.isFromPostDetails,
    this.callbacks = const PostCallbacks(),
    required this.isFromProfile,
    this.heroPrefix,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return _buildSingleImage(context);
    }

    final height = context.responsiveHeight(250);
    final gap = context.responsiveWidth(4);

    return SizedBox(
      height: height,
      child: Row(children: _buildMultiLayout(context, gap)),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🖼️ Single Image
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildSingleImage(BuildContext context) {
    final image = images[0];
    final maxAllowedHeight = context.responsiveHeight(500);
    final aspectRatio = image.aspectRatio.clamp(0.5, 2.5);

    return GestureDetector(
      onTap: () => _openGallery(context, 0),
      child: Hero(
        tag:
            '${heroPrefix ?? (isFromProfile ? 'profile' : 'home')}_post_${postId}_img_${image.image}',
        placeholderBuilder: (_, __, child) => child,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: maxAllowedHeight),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: ConnectivityCachedImage(
                imageUrl: image.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => _buildShimmerPlaceholder(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ✨ Shimmer & Error Widgets
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(color: Colors.white),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 🔢 Multi Images (Grid)
  // ══════════════════════════════════════════════════════════════════════════
  List<Widget> _buildMultiLayout(BuildContext context, double gap) {
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
    ImageModel image, {
    int moreCount = 0,
  }) {
    final heroTag =
        '${heroPrefix ?? (isFromProfile ? 'profile' : 'home')}_post_${postId}_img_${image.image}';

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
                ConnectivityCachedImage(
                  imageUrl: image.image,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _buildShimmerPlaceholder(),
                ),
                if (moreCount > 0)
                  Material(
                    // ✅ Hero widgets يحتاجوا Material ancestor أثناء الـ animation
                    // بدونه الـ Text بيوقع تحت DefaultTextStyle اللي بيعمل خط أصفر
                    type: MaterialType.transparency,
                    child: Container(
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
          images: images.map((e) => e.image).toList(),
          initialIndex: index,
          postId: postId,
          post: post,
          isFromPostDetails: isFromPostDetails,
          callbacks: callbacks,
          heroPrefix: heroPrefix,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
