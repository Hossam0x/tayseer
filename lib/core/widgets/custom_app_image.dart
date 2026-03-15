import 'dart:ui';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import '../../my_import.dart';

class AppImage extends StatelessWidget {
  final String? path;
  final double? height, width;
  final BoxFit fit;
  final Color? color;
  final Gradient? gradientColorSvg;
  final String? placeholderImage;
  final bool flipOnLtr;
  final double? blur; // ✅ Add blur sigma

  /// لو true → الـ errorWidget تبقى Icons.person (للأفاتار/البروفايل)
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
    this.blur, // ✅ Add to constructor
  });

  Widget _flipIfLtr(Widget child, BuildContext context) {
    if (!flipOnLtr) return child;
    final isLtr = Directionality.of(context) == TextDirection.ltr;
    if (!isLtr) return child;
    return Transform.scale(scaleX: -1, child: child);
  }

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
      Widget svgWidget;

      if (path!.startsWith("http")) {
        svgWidget = SvgPicture.network(
          path!,
          fit: fit,
          height: height,
          width: width,
          color: gradientColorSvg == null ? color : null,
          placeholderBuilder: (context) => placeholderImage != null
              ? Image.asset(
                  placeholderImage!,
                  height: height,
                  width: width,
                  fit: fit,
                )
              : _buildLoadingPlaceholder(),
        );
      } else {
        svgWidget = SvgPicture.asset(
          path!,
          fit: fit,
          height: height,
          width: width,
          color: gradientColorSvg == null ? color : null,
          placeholderBuilder: (context) => placeholderImage != null
              ? Image.asset(
                  placeholderImage!,
                  height: height,
                  width: width,
                  fit: fit,
                )
              : _buildLoadingPlaceholder(),
        );
      }

      // لو فيه Gradient Wrap بـ ShaderMask
      if (gradientColorSvg != null) {
        return _flipIfLtr(
          ShaderMask(
            shaderCallback: (bounds) {
              return gradientColorSvg!.createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: svgWidget,
          ),
          context,
        );
      }

      return _flipIfLtr(svgWidget, context);
    }

    // Lottie
    if (path!.endsWith("json")) {
      return Lottie.asset(path!, fit: fit, height: height, width: width);
    }

    // GIF ✅
    if (path!.endsWith("gif")) {
      if (path!.startsWith("http")) {
        return _ConnectivityNetworkImage(
          imageUrl: path!,
          fit: fit,
          height: height,
          width: width,
          color: null,
          placeholderImage: placeholderImage,
          isAvatar: isAvatar,
          loadingPlaceholder: _buildLoadingPlaceholder(),
          memCacheWidth: 600,
          blur: blur, // ✅ Pass blur
        );
      } else {
        return _flipIfLtr(
          Image.asset(path!, height: height, width: width, fit: fit),
          context,
        );
      }
    }

    // Network image
    if (path!.startsWith("http")) {
      return _ConnectivityNetworkImage(
        imageUrl: path!,
        fit: fit,
        height: height,
        width: width,
        color: color,
        placeholderImage: placeholderImage,
        isAvatar: isAvatar,
        loadingPlaceholder: _buildLoadingPlaceholder(),
        memCacheWidth: 600,
        blur: blur, // ✅ Pass blur
      );
    }

    // Asset image
    return _flipIfLtr(
      Image.asset(path!, height: height, width: width, fit: fit, color: color),
      context,
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(height: height, width: width, color: Colors.white),
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
  final double? blur; // ✅ Add blur

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
    this.blur, // ✅ Add to constructor
  });

  @override
  State<_ConnectivityNetworkImage> createState() =>
      _ConnectivityNetworkImageState();
}

class _ConnectivityNetworkImageState extends State<_ConnectivityNetworkImage> {
  int _retryKey = 0;
  bool _hasFailed = false;

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
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholderFadeInDuration: Duration.zero,
        placeholder: (_, __) => _buildPlaceholder(),
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
    // أفاتار → صورة بروفايل افتراضية
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

    // أفاتار → صورة بروفايل افتراضية
    if (widget.isAvatar) {
      return Image.asset(
        AssetsData.defaultProfileImage,
        height: widget.height,
        width: widget.width,
        fit: BoxFit.cover,
      );
    }

    // صورة عادية → placeholder رمادي ثابت (زي الفيسبوك)
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
