import 'dart:ui';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import '../../my_import.dart';

// ⭐ StatefulWidget عشان يحتفظ بالـ URL القديم ويمنع الـ flash
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
  });

  @override
  State<AppImage> createState() => _AppImageState();
}

class _AppImageState extends State<AppImage> {
  String? _previousNetworkPath;

  @override
  void didUpdateWidget(AppImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // لو الـ URL اتغير وكان network image، نحفظ القديم كـ fallback
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

  @override
  Widget build(BuildContext context) {
    final path = widget.path;

    if (path == null || path.isEmpty) {
      if (widget.placeholderImage != null) {
        return Image.asset(
          widget.placeholderImage!,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
        );
      } else if (widget.isAvatar) {
        return Image.asset(
          AssetsData.defaultProfileImage,
          height: widget.height,
          width: widget.width,
          fit: widget.fit,
        );
      }
      return const SizedBox.shrink();
    }

    // SVG
    if (path.endsWith("svg")) {
      Widget svgWidget;
      if (path.startsWith("http")) {
        svgWidget = SvgPicture.network(
          path,
          fit: widget.fit,
          height: widget.height,
          width: widget.width,
          color: widget.gradientColorSvg == null ? widget.color : null,
          placeholderBuilder: (context) => widget.placeholderImage != null
              ? Image.asset(
                  widget.placeholderImage!,
                  height: widget.height,
                  width: widget.width,
                  fit: widget.fit,
                )
              : _buildLoadingPlaceholder(),
        );
      } else {
        svgWidget = SvgPicture.asset(
          path,
          fit: widget.fit,
          height: widget.height,
          width: widget.width,
          color: widget.gradientColorSvg == null ? widget.color : null,
          placeholderBuilder: (context) => widget.placeholderImage != null
              ? Image.asset(
                  widget.placeholderImage!,
                  height: widget.height,
                  width: widget.width,
                  fit: widget.fit,
                )
              : _buildLoadingPlaceholder(),
        );
      }
      if (widget.gradientColorSvg != null) {
        return _flipIfLtr(
          ShaderMask(
            shaderCallback: (bounds) =>
                widget.gradientColorSvg!.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: svgWidget,
          ),
          context,
        );
      }
      return _flipIfLtr(svgWidget, context);
    }

    // Lottie
    if (path.endsWith("json")) {
      return Lottie.asset(
        path,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
      );
    }

    // GIF
    if (path.endsWith("gif")) {
      if (path.startsWith("http")) {
        return _ConnectivityNetworkImage(
          imageUrl: path,
          fit: widget.fit,
          height: widget.height,
          width: widget.width,
          color: null,
          placeholderImage: widget.placeholderImage,
          isAvatar: widget.isAvatar,
          loadingPlaceholder: _buildLoadingPlaceholder(),
          memCacheWidth: 600,
          blur: widget.blur,
          previousUrl: _previousNetworkPath,
        );
      } else {
        return _flipIfLtr(
          Image.asset(
            path,
            height: widget.height,
            width: widget.width,
            fit: widget.fit,
          ),
          context,
        );
      }
    }

    // Network image
    if (path.startsWith("http")) {
      return _ConnectivityNetworkImage(
        imageUrl: path,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        color: widget.color,
        placeholderImage: widget.placeholderImage,
        isAvatar: widget.isAvatar,
        loadingPlaceholder: _buildLoadingPlaceholder(),
        memCacheWidth: 600,
        blur: widget.blur,
        previousUrl: _previousNetworkPath,
      );
    }

    // Asset image
    return _flipIfLtr(
      Image.asset(
        path,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
        color: widget.color,
      ),
      context,
    );
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
}

// ══════════════════════════════════════════════════════════════════════════════
// 🔄 صورة شبكة مع إعادة تحميل تلقائية عند عودة الاتصال
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
  final int? memCacheWidth;
  final double? blur;
  final String? previousUrl; // ⭐ الـ URL القديم من الـ parent

  const _ConnectivityNetworkImage({
    required this.imageUrl,
    required this.fit,
    this.height,
    this.width,
    this.color,
    this.placeholderImage,
    required this.isAvatar,
    required this.loadingPlaceholder,
    this.memCacheWidth,
    this.blur,
    this.previousUrl,
  });

  @override
  State<_ConnectivityNetworkImage> createState() =>
      _ConnectivityNetworkImageState();
}

class _ConnectivityNetworkImageState extends State<_ConnectivityNetworkImage> {
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
      // نحتفظ بالـ URL القديم من الـ parent أو من الـ local state
      _localPreviousUrl = widget.previousUrl ?? oldWidget.imageUrl;
      _hasFailed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listenWhen: (prev, curr) => !prev.isConnected && curr.isConnected,
      listener: (_, __) {
        if (_hasFailed && mounted) {
          setState(() {
            _retryKey++;
            _hasFailed = false;
          });
        }
      },
      child: CachedNetworkImage(
        key: ValueKey('${widget.imageUrl}_$_retryKey'),
        memCacheWidth: widget.memCacheWidth,
        imageUrl: widget.imageUrl,
        fit: widget.fit,
        height: widget.height,
        width: widget.width,
        color: widget.color,
        fadeOutDuration: Duration.zero,
        fadeInDuration: Duration.zero,
        placeholderFadeInDuration: Duration.zero,
        useOldImageOnUrlChange: true,
        // ⭐ لو فيه URL قديم، استخدمه كـ placeholder بدل الـ shimmer
        placeholder: (_, __) {
          final prev = _localPreviousUrl;
          if (prev != null && prev.isNotEmpty) {
            return CachedNetworkImage(
              imageUrl: prev,
              fit: widget.fit,
              height: widget.height,
              width: widget.width,
              fadeInDuration: Duration.zero,
              fadeOutDuration: Duration.zero,
              errorWidget: (_, __, ___) => _buildPlaceholder(),
            );
          }
          return _buildPlaceholder();
        },
        errorWidget: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasFailed) _hasFailed = true;
          });
          return _buildErrorWidget();
        },
        imageBuilder: widget.blur != null
            ? (context, imageProvider) => ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: widget.blur!,
                  sigmaY: widget.blur!,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: widget.fit,
                      colorFilter: widget.color != null
                          ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
                          : null,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholderImage != null) {
      return Image.asset(
        widget.placeholderImage!,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
      );
    }
    if (widget.isAvatar) {
      return Image.asset(
        AssetsData.defaultProfileImage,
        height: widget.height,
        width: widget.width,
        fit: BoxFit.cover,
      );
    }
    return widget.loadingPlaceholder;
  }

  Widget _buildErrorWidget() {
    if (widget.placeholderImage != null) {
      return Image.asset(
        widget.placeholderImage!,
        height: widget.height,
        width: widget.width,
        fit: widget.fit,
      );
    }
    if (widget.isAvatar) {
      return Image.asset(
        AssetsData.defaultProfileImage,
        height: widget.height,
        width: widget.width,
        fit: BoxFit.cover,
      );
    }
    return Container(
      height: widget.height,
      width: widget.width,
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image_outlined, color: Colors.grey[350], size: 32.sp),
      ),
    );
  }
}
