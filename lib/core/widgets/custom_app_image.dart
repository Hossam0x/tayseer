import 'package:vector_graphics/vector_graphics.dart';
import '../../my_import.dart';

// ══════════════════════════════════════════════════════════════════════════════
// ⭐ AppImage – ويدجت موحدة لكل أنواع الصور
// ══════════════════════════════════════════════════════════════════════════════
class AppImage extends StatefulWidget {
  final String? path;
  final double? height, width;
  final BoxFit fit;
  final Color? color;
  final Gradient? gradientColorSvg;
  final String? placeholderImage;
  final bool flipOnLtr;
  final double? blur;
  final bool isAvatar;
  final double? radius;

  const AppImage(
    this.path, {
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.color,
    this.placeholderImage,
    this.gradientColorSvg,
    this.flipOnLtr = false,
    this.isAvatar = false,
    this.blur,
    this.radius,
  });

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  String? _previousNetworkPath;

  @override
  void didUpdateWidget(AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path &&
        oldWidget.path != null &&
        oldWidget.path!.startsWith('http')) {
      _previousNetworkPath = oldWidget.path;
    }
  }

  Widget _flipIfLtr(Widget child, BuildContext context) {
    if (!widget.flipOnLtr) return child;
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    if (!isLtr) return child;
    return Transform.scale(scaleX: -1, child: child);
  }

  Widget _wrapWithClip(Widget child) {
    if (widget.radius != null && widget.radius! > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius!),
        child: child,
      );
    }
    return child;
  }

  Widget _wrapWithGradient(Widget child) {
    if (widget.gradientColorSvg != null) {
      return ShaderMask(
        shaderCallback: (bounds) =>
            widget.gradientColorSvg!.createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: child,
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.path;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;

    if (path == null || path.isEmpty) {
      return _buildFallback();
    }

    final ext = path.split('.').last.toLowerCase();

    if (ext == 'vec') return _buildVec(path);
    if (ext == 'svg') return _buildSvg(path);

    if (ext == 'json') {
      return _wrapWithClip(
        Lottie.asset(
          path,
          fit: widget.fit,
          height: widget.height,
          width: widget.width,
        ),
      );
    }

    if (ext == 'gif') return _buildGif(path, pixelRatio);

    if (path.startsWith('http')) {
      return _wrapWithGradient(
        _ConnectivityNetworkImage(
          imageUrl: path,
          fit: widget.fit,
          height: widget.height,
          width: widget.width,
          color: widget.color,
          placeholderImage: widget.placeholderImage,
          isAvatar: widget.isAvatar,
          loadingPlaceholder: _buildLoadingPlaceholder(),
          pixelRatio: pixelRatio,
          blur: widget.blur,
          previousUrl: _previousNetworkPath,
          radius: widget.radius,
        ),
      );
    }

    return _buildAssetRaster(path, pixelRatio);
  }

  Widget _buildVec(String path) {
    Widget vecWidget = SizedBox(
      height: widget.height,
      width: widget.width,
      child: VectorGraphic(
        loader: AssetBytesLoader(path),
        fit: widget.fit,
        colorFilter: widget.gradientColorSvg == null && widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (_) =>
            SizedBox(height: widget.height ?? 24, width: widget.width ?? 24),
      ),
    );
    return _flipIfLtr(_wrapWithClip(_wrapWithGradient(vecWidget)), context);
  }

  Widget _buildSvg(String path) {
    final colorFilter = widget.gradientColorSvg == null && widget.color != null
        ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
        : null;

    Widget svgWidget = path.startsWith('http')
        ? SvgPicture.network(
            path,
            fit: widget.fit,
            height: widget.height,
            width: widget.width,
            colorFilter: colorFilter,
            placeholderBuilder: (_) => widget.placeholderImage != null
                ? Image.asset(widget.placeholderImage!,
                    height: widget.height,
                    width: widget.width,
                    fit: widget.fit)
                : _buildLoadingPlaceholder(),
          )
        : SvgPicture.asset(
            path,
            fit: widget.fit,
            height: widget.height,
            width: widget.width,
            colorFilter: colorFilter,
            placeholderBuilder: (_) => widget.placeholderImage != null
                ? Image.asset(widget.placeholderImage!,
                    height: widget.height,
                    width: widget.width,
                    fit: widget.fit)
                : _buildLoadingPlaceholder(),
          );

    return _flipIfLtr(_wrapWithClip(_wrapWithGradient(svgWidget)), context);
  }

  Widget _buildGif(String path, double pixelRatio) {
    if (path.startsWith('http')) {
      return _ConnectivityNetworkImage(
        imageUrl: path,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        color: null,
        placeholderImage: widget.placeholderImage,
        isAvatar: widget.isAvatar,
        loadingPlaceholder: _buildLoadingPlaceholder(),
        pixelRatio: pixelRatio,
        blur: widget.blur,
        previousUrl: _previousNetworkPath,
        radius: widget.radius,
      );
    }
    return _flipIfLtr(
      _wrapWithClip(
        Image.asset(
          path,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
        ),
      ),
      context,
    );
  }

  Widget _buildAssetRaster(String path, double pixelRatio) {
    final safeWidth = widget.width;
    final safeHeight = widget.height;

    Widget assetImage = Image.asset(
      path,
      height: widget.height,
      width: widget.width,
      fit: widget.fit,
      color: widget.color,
      cacheWidth: (safeWidth != null && safeWidth.isFinite && safeWidth > 0)
          ? (safeWidth * pixelRatio).toInt()
          : null,
      cacheHeight: (safeHeight != null && safeHeight.isFinite && safeHeight > 0)
          ? (safeHeight * pixelRatio).toInt()
          : null,
      errorBuilder: (_, __, ___) => _buildErrorWidget(),
    );

    return _flipIfLtr(_wrapWithClip(_wrapWithGradient(assetImage)), context);
  }

  Widget _buildFallback() {
    if (widget.placeholderImage != null) {
      return _wrapWithClip(
        Image.asset(widget.placeholderImage!,
            height: widget.height,
            width: widget.width,
            fit: widget.fit),
      );
    }
    if (widget.isAvatar) {
      return _wrapWithClip(
        Image.asset(AssetsData.defaultProfileImage,
            height: widget.height,
            width: widget.width,
            fit: widget.fit),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoadingPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: widget.height,
        width: widget.width,
        color: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.placeholderImage != null) {
      return Image.asset(widget.placeholderImage!,
          height: widget.height,
          width: widget.width,
          fit: widget.fit);
    }
    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image_outlined,
            color: Colors.grey[350], size: 32.sp),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// 🔄 Connectivity Image
// ══════════════════════════════════════════════════════════════════════════════
class _ConnectivityNetworkImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? height;
  final double? width;
  final Color? color;
  final String? placeholderImage;
  final bool isAvatar;
  final Widget loadingPlaceholder;
  final double pixelRatio;
  final double? blur;
  final String? previousUrl;
  final double? radius;

  const _ConnectivityNetworkImage({
    required this.imageUrl,
    required this.fit,
    this.height,
    this.width,
    this.color,
    this.placeholderImage,
    required this.isAvatar,
    required this.loadingPlaceholder,
    required this.pixelRatio,
    this.blur,
    this.previousUrl,
    this.radius,
  });

  @override
  State<_ConnectivityNetworkImage> createState() =>
      _ConnectivityNetworkImageState();
}

class _ConnectivityNetworkImageState
    extends State<_ConnectivityNetworkImage> {
  int _retryKey = 0;
  bool _hasFailed = false;
  String? _localPreviousUrl;

  @override
  void initState() {
    super.initState();
    _localPreviousUrl = widget.previousUrl;
  }

  @override
  void didUpdateWidget(_ConnectivityNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _localPreviousUrl = widget.previousUrl ?? oldWidget.imageUrl;
      _hasFailed = false;
    }
  }

  int? get _memCacheWidth {
    final w = widget.width;
    if (w != null && w.isFinite && w > 0) {
      return (w * widget.pixelRatio).toInt();
    }
    return null;
  }

  int? get _memCacheHeight {
    final h = widget.height;
    if (h != null && h.isFinite && h > 0) {
      return (h * widget.pixelRatio).toInt();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      key: ValueKey('${widget.imageUrl}_$_retryKey'),
      memCacheWidth: _memCacheWidth,
      memCacheHeight: _memCacheHeight,
      imageUrl: widget.imageUrl,
      fit: widget.fit,
      height: widget.height,
      width: widget.width,
      color: widget.blur != null ? null : widget.color,
    );

    return widget.radius != null && widget.radius! > 0
        ? ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius!),
            child: image,
          )
        : image;
  }
}