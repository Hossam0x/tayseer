import '../../my_import.dart';

class AppImage extends StatelessWidget {
  final String? path;
  final double? height, width;
  final BoxFit fit;
  final Color? color;
  final String? placeholderImage;

  const AppImage(
    this.path, {
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.scaleDown,
    this.color,
    this.placeholderImage,
  });

  @override
  Widget build(BuildContext context) {
    if (path == null || path!.isEmpty) {
      return placeholderImage != null
          ? Image.asset(
            placeholderImage!,
            height: height,
            width: width,
            fit: fit,
          )
          : const SizedBox.shrink();
    }

    // SVG
    if (path!.endsWith("svg")) {
      if (path!.startsWith("http")) {
        return SvgPicture.network(
          path!,
          fit: fit,
          height: height,
          width: width,
          color: color,
          placeholderBuilder:
              (context) =>
                  placeholderImage != null
                      ? Image.asset(
                        placeholderImage!,
                        height: height,
                        width: width,
                        fit: fit,
                      )
                      : _buildLoadingPlaceholder(),
        );
      } else {
        return SvgPicture.asset(
          path!,
          fit: fit,
          height: height,
          width: width,
          color: color,
        );
      }
    }

    // Lottie
    if (path!.endsWith("json")) {
      return Lottie.asset(path!, fit: fit, height: height, width: width);
    }

    // GIF ✅
    if (path!.endsWith("gif")) {
      if (path!.startsWith("http")) {
        return CachedNetworkImage(
          imageUrl: path!,
          fit: fit,
          height: height,
          width: width,
          placeholder:
              (context, url) =>
                  placeholderImage != null
                      ? Image.asset(
                        placeholderImage!,
                        height: height,
                        width: width,
                        fit: fit,
                      )
                      : _buildLoadingPlaceholder(),
          errorWidget:
              (context, url, error) =>
                  const Icon(Icons.error, color: Colors.red),
        );
      } else {
        return Image.asset(path!, height: height, width: width, fit: fit);
      }
    }

    // Network image
    if (path!.startsWith("http")) {
      return CachedNetworkImage(
        memCacheWidth: 600,
        imageUrl: path!,
        fit: fit,
        height: height,
        width: width,
        color: color,
        placeholder:
            (context, url) =>
                placeholderImage != null
                    ? Image.asset(
                      placeholderImage!,
                      height: height,
                      width: width,
                      fit: fit,
                    )
                    : _buildLoadingPlaceholder(),
        errorWidget:
            (context, url, error) =>
                placeholderImage != null
                    ? Image.asset(
                      placeholderImage!,
                      height: height,
                      width: width,
                      fit: fit,
                    )
                    : const Icon(Icons.error, color: Colors.red),
      );
    }

    // Asset image
    return Image.asset(
      path!,
      height: height,
      width: width,
      fit: fit,
      color: color,
    );
  }

  Widget _buildLoadingPlaceholder() {
    return SizedBox(
      height: height,
      width: width,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
        ),
      ),
    );
  }
}
