import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/my_import.dart';

/// CachedNetworkImage مع إعادة تحميل تلقائية عند عودة الاتصال
/// بدل ما يظهر broken image، يعرض placeholder رمادي ثابت (زي الفيسبوك)
/// ولما النت يرجع → يعيد التحميل تلقائي
class ConnectivityCachedImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final Alignment alignment;
  final Widget Function(BuildContext, String)? placeholder;
  final double? width;
  final double? height;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const ConnectivityCachedImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.placeholder,
    this.width,
    this.height,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  State<ConnectivityCachedImage> createState() =>
      _ConnectivityCachedImageState();
}

class _ConnectivityCachedImageState extends State<ConnectivityCachedImage> {
  /// مفتاح لإعادة بناء CachedNetworkImage عند عودة الاتصال
  int _retryKey = 0;
  bool _hasFailed = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listenWhen: (prev, curr) => !prev.isConnected && curr.isConnected,
      listener: (_, __) {
        // لما النت يرجع ولو الصورة فشلت → أعد المحاولة
        if (_hasFailed && mounted) {
          setState(() {
            _retryKey++;
            _hasFailed = false;
          });
        }
      },
      child: CachedNetworkImage(
        key: ValueKey('${widget.imageUrl}_$_retryKey'),
        imageUrl: widget.imageUrl,
        fit: widget.fit,
        alignment: widget.alignment,
        width: widget.width,
        height: widget.height,
        memCacheWidth: widget.memCacheWidth,
        memCacheHeight: widget.memCacheHeight,
        fadeInDuration: Duration.zero,
        fadeOutDuration: Duration.zero,
        placeholderFadeInDuration: Duration.zero,
        placeholder: widget.placeholder ?? (_, __) => _buildPlaceholder(),
        errorWidget: (_, __, ___) {
          // سجّل إن الصورة فشلت
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hasFailed) {
              _hasFailed = true;
            }
          });
          return _buildPlaceholder();
        },
      ),
    );
  }

  /// placeholder رمادي ثابت (زي الفيسبوك)
  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: Center(
        child: Icon(Icons.image_outlined, color: Colors.grey[350], size: 32.sp),
      ),
    );
  }
}
