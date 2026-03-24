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

    // منع الـ zoom out من تعدي الـ 1x
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

  void _handleDragMove(double dy) {
    if (_isZoomed) return;
    if (dy < 0) {
      _snapBackController.stop();
      setState(() => _dragY += dy);
    }
  }

  void _handleDragEnd() {
    if (_isZoomed) return;
    if (_dragY < -120) {
      Navigator.pop(context);
    } else if (_dragY < 0) {
      _snapStartY = _dragY;
      _snapBackController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (-_dragY / 350).clamp(0.0, 1.0);
    final bgOpacity = (1.0 - progress).clamp(0.0, 1.0);
    final scale = (1.0 - progress * 0.15).clamp(0.85, 1.0);
    final borderRadius = progress * 40.0;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(bgOpacity),
      body: Stack(
        children: [
          // الصورة
          Listener(
            onPointerMove: (e) {
              if (!_isZoomed) _handleDragMove(e.delta.dy);
            },
            onPointerUp: (_) {
              if (!_isZoomed) _handleDragEnd();
            },
            child: GestureDetector(
              onDoubleTapDown: _onDoubleTapDown,
              onDoubleTap: () {},
              child: Transform.translate(
                offset: Offset(0, _dragY),
                child: Transform.scale(
                  scale: scale,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: Container(
                      color: Colors.black,
                      width: double.infinity,
                      height: double.infinity,
                      child: Hero(
                        tag: widget.heroTag,
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 1.0,
                          maxScale: 4.0,
                          panEnabled: true,
                          scaleEnabled: true,
                          constrained: true,
                          boundaryMargin: EdgeInsets.zero,
                          child: SizedBox.expand(
                            child: widget.imageFile != null
                                ? Image.file(
                                    widget.imageFile!,
                                    fit: BoxFit.contain,
                                  )
                                : AppImage(
                                    widget.imageUrl,
                                    fit: BoxFit.contain,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // سهم الإغلاق مع hint animation وسحب
          Positioned(
            bottom: 10.h,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: (1.0 - progress * 2).clamp(0.0, 1.0),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                onVerticalDragUpdate: (d) => _handleDragMove(d.delta.dy),
                onVerticalDragEnd: (_) => _handleDragEnd(),
                child: AnimatedBuilder(
                  animation: _arrowHintAnimation,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _arrowHintAnimation.value),
                    child: child,
                  ),
                  child: Container(
                    height: 80,
                    alignment: Alignment.center,
                    child: Container(
                      padding: const EdgeInsets.all(12),
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
