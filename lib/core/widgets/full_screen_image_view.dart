import 'package:tayseer/core/services/secure_window_service.dart';
import 'package:tayseer/core/widgets/secure_image_wrapper.dart';
import 'package:tayseer/my_import.dart';

class FullScreenImageView extends StatefulWidget {
  final String? imageUrl;
  final File? imageFile;
  final String heroTag;
  final String? userName;

  const FullScreenImageView({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.heroTag,
    this.userName,
  });

  static Future<void> show(
    BuildContext context, {
    String? imageUrl,
    File? imageFile,
    required String heroTag,
    String? userName,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => FullScreenImageView(
          imageUrl: imageUrl,
          imageFile: imageFile,
          heroTag: heroTag,
          userName: userName,
        ),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView>
    with TickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();

  late AnimationController _snapBackController;
  double _snapStartY = 0.0;
  double _dragY = 0.0;

  AnimationController? _doubleTapController;
  Animation<Matrix4>? _doubleTapAnimation;

  late AnimationController _arrowHintController;
  late Animation<double> _arrowHintAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ تفعيل الحماية بشكل مستقل — بغض النظر عن MarriageView
    // Android: FLAG_SECURE على الـ Window
    // iOS: الحماية عبر SecureImageWrapper (UiKitView)
    SecureWindowService.enable();

    _snapBackController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          setState(() {
            _dragY = _snapStartY * (1 - _snapBackController.value);
          });
        });

    _doubleTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _arrowHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _arrowHintAnimation =
        TweenSequence([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -14.0), weight: 25),
          TweenSequenceItem(tween: Tween(begin: -14.0, end: 0.0), weight: 25),
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 25),
          TweenSequenceItem(tween: Tween(begin: -10.0, end: 0.0), weight: 25),
        ]).animate(
          CurvedAnimation(
            parent: _arrowHintController,
            curve: Curves.easeInOut,
          ),
        );

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _arrowHintController.forward();
    });

    _transformationController.addListener(_clampScale);
  }

  void _clampScale() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if (scale < 1.0) {
      _transformationController.value = Matrix4.identity();
    }
  }

  @override
  void dispose() {
    // ✅ يشيل الحماية بس لو مفيش screen تاني محتاجها (مثلاً MarriageView لسه مفتوح)
    // SecureWindowService بيتتبع العداد تلقائياً
    SecureWindowService.disable();
    _transformationController.removeListener(_clampScale);
    _transformationController.dispose();
    _snapBackController.dispose();
    _doubleTapController?.dispose();
    _arrowHintController.dispose();
    super.dispose();
  }

  bool get _isZoomed =>
      _transformationController.value.getMaxScaleOnAxis() > 1.05;

  void _onDoubleTapDown(TapDownDetails details) {
    _doubleTapController!.stop();
    final begin = _transformationController.value;
    final Matrix4 end;

    if (_isZoomed) {
      end = Matrix4.identity();
    } else {
      final pos = details.localPosition;
      end = Matrix4.identity()
        ..translate(-pos.dx * 1.5, -pos.dy * 1.5)
        ..scale(2.5);
    }

    _doubleTapAnimation =
        Matrix4Tween(begin: begin, end: end).animate(
          CurvedAnimation(
            parent: _doubleTapController!,
            curve: Curves.easeInOut,
          ),
        )..addListener(() {
          _transformationController.value = _doubleTapAnimation!.value;
        });

    _doubleTapController!.forward(from: 0);
  }

  void _handleDragStart() {
    if (_isZoomed) return;
    _snapBackController.stop();
  }

  void _handleDragMove(double dy) {
    if (_isZoomed) return;
    _snapBackController.stop();
    setState(() => _dragY += dy);
  }

  void _handleDragEnd() {
    if (_isZoomed) return;
    const threshold = 120.0;
    if (_dragY.abs() > threshold) {
      Navigator.pop(context);
    } else {
      _snapStartY = _dragY;
      _snapBackController.forward(from: 0);
    }
  }

  Widget _buildImage() {
    if (widget.imageFile != null) {
      return Image.file(widget.imageFile!, fit: BoxFit.contain);
    }
    // ✅ نفس آلية الـ marriage profile card:
    // iOS  → UiKitView(secure_image_view) بـ instanceId مختلف عن الـ card
    //        عشان يمنع PlatformException(recreating_view)
    // Android → AppImage عادي، الحماية من FLAG_SECURE على الـ Window
    return SecureImageWrapper(
      imageUrl: widget.imageUrl,
      instanceId: 'fullscreen',
      child: AppImage(widget.imageUrl, fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_dragY.abs() / 350).clamp(0.0, 1.0);
    final bgOpacity = (1.0 - progress).clamp(0.0, 1.0);
    final scale = (1.0 - progress * 0.6).clamp(0.4, 1.0);
    final screenW = MediaQuery.of(context).size.width;
    final borderRadius = progress * (screenW * scale / 2);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // خلفية سوداء
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(bgOpacity)),
          ),

          // الصورة
          GestureDetector(
            onDoubleTapDown: _onDoubleTapDown,
            onDoubleTap: () {},
            child: Transform.translate(
              offset: Offset(0, _dragY),
              child: Transform.scale(
                scale: scale,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 1.0,
                    maxScale: 4.0,
                    panEnabled: true,
                    scaleEnabled: true,
                    constrained: true,
                    boundaryMargin: EdgeInsets.zero,
                    onInteractionStart: (details) {
                      if (details.pointerCount == 1 && !_isZoomed) {
                        _handleDragStart();
                      }
                    },
                    onInteractionUpdate: (details) {
                      if (details.pointerCount == 1 && !_isZoomed) {
                        _handleDragMove(details.focalPointDelta.dy);
                      }
                    },
                    onInteractionEnd: (details) {
                      if (!_isZoomed && _dragY != 0) {
                        _handleDragEnd();
                      }
                    },
                    child: SizedBox.expand(child: _buildImage()),
                  ),
                ),
              ),
            ),
          ),

          // سهم الإغلاق
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: (1.0 - progress * 2).clamp(0.0, 1.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                onVerticalDragStart: (_) => _handleDragStart(),
                onVerticalDragUpdate: (d) => _handleDragMove(d.delta.dy),
                onVerticalDragEnd: (_) => _handleDragEnd(),
                child: AnimatedBuilder(
                  animation: _arrowHintAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _arrowHintAnimation.value),
                    child: child,
                  ),
                  child: Container(
                    height: 80.h,
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(12.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white,
                        size: 40.w,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
