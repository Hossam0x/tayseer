// features/advisor/profile/views/widgets/profile_post_images_grid.dart
import 'package:tayseer/features/shared/home/model/post_model.dart';
import 'package:tayseer/my_import.dart';

class ProfilePostImagesGrid extends StatelessWidget {
  final List<String> images;
  final String postId;
  final PostModel? post;
  final bool isFromPostDetails;

  const ProfilePostImagesGrid({
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
    final double gap = context.responsiveWidth(4);

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
        pageBuilder: (_, __, ___) => _ProfileImageViewerView(
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
    // ⭐️⭐️⭐️ الحل: إضافة unique suffix للـ Hero tag
    final String heroTag =
        'profile_post_${postId}_img_${imagePath}_${DateTime.now().millisecondsSinceEpoch}_$index';

    return Expanded(
      child: GestureDetector(
        onTap: () => _openGallery(context, index),
        child: Hero(
          tag: heroTag,
          placeholderBuilder: (context, heroSize, child) => child,
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

// ═══════════════════════════════════════════════════════════
// Profile Image Viewer (نسخة مبسطة)
// ═══════════════════════════════════════════════════════════
class _ProfileImageViewerView extends StatelessWidget {
  final List<String> images;
  final int initialIndex;
  final String postId;
  final bool isFromPostDetails;
  final PostModel? post;

  const _ProfileImageViewerView({
    required this.images,
    required this.initialIndex,
    required this.postId,
    required this.isFromPostDetails,
    this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: PageView.builder(
          itemCount: images.length,
          controller: PageController(initialPage: initialIndex),
          itemBuilder: (context, index) {
            final imageUrl = images[index];
            final heroTag =
                'profile_post_${postId}_img_${imageUrl}_${DateTime.now().millisecondsSinceEpoch}_$index';

            return GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Hero(
                tag: heroTag,
                child: AppImage(
                  imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
