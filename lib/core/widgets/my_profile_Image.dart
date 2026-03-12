import 'dart:ui';
import 'package:tayseer/my_import.dart';

class MyProfileImage extends StatelessWidget {
  final int size;
  final double? width;
  final String? imageUrl;
  final String? heroTag;
  final VoidCallback? onTap;
  final bool isAnnonymous;
  final bool isBlur;

  const MyProfileImage({
    super.key,
    this.width,
    this.size = 45,
    this.imageUrl,
    this.heroTag,
    this.onTap,
    this.isAnnonymous = false,
    this.isBlur = false,
  });

  @override
  Widget build(BuildContext context) {
    String image = imageUrl ?? kCurrentUserData?.image ?? '';
    if (image.isEmpty) {
      return const SizedBox();
    }

    final imageWidget = SizedBox(
      height: width ?? size.r,
      width: width ?? size.r,
      child: ClipOval(
        child: isBlur
            ? ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AppImage(
                  isAnnonymous ? AssetsData.anonymousProfile : image,
                  fit: BoxFit.cover,
                  isAvatar: true,
                ),
              )
            : AppImage(
                isAnnonymous ? AssetsData.anonymousProfile : image,
                fit: BoxFit.cover,
                isAvatar: true,
              ),
      ),
    );

    // Wrap with Hero if heroTag is provided
    final heroWrappedWidget = heroTag != null
        ? Hero(tag: heroTag!, child: imageWidget)
        : imageWidget;

    // Make tappable if onTap is provided
    if (onTap != null) {
      return CustomClick(onTap: onTap, child: heroWrappedWidget);
    }

    return heroWrappedWidget;
  }
}
