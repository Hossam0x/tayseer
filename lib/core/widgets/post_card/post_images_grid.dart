import 'package:tayseer/core/widgets/post_card/post_callbacks.dart';
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/features/shared/home/views/image_viewer_view.dart';
import 'package:tayseer/my_import.dart';

class PostImagesGrid extends StatelessWidget {
  final List<String> images;
  final String postId;
  final PostModel? post;
  final bool isFromPostDetails;

  /// Bundled callbacks for post actions
  final PostCallbacks callbacks;

  const PostImagesGrid({
    super.key,
    required this.images,
    required this.postId,
    this.post,
    required this.isFromPostDetails,
    this.callbacks = const PostCallbacks(),
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    final height = context.responsiveHeight(206);
    final gap = context.responsiveWidth(4);

    return SizedBox(
      height: height,
      child: Row(children: _buildLayout(context, gap)),
    );
  }

  void _openGallery(BuildContext context, int index) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => ImageViewerView(
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

  List<Widget> _buildLayout(BuildContext context, double gap) {
    final count = images.length;

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
}