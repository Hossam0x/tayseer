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
  double _snapStartX = 0.0;

  double _dragY = 0.0;
  double _dragX = 0.0;

  AnimationController? _doubleTapController;
  Animation<Matrix4>? _doubleTapAnimation;

  @override
  void initState() {
    super.initState();

    _snapBackController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          final t = _snapBackController.value;
          setState(() {
            _dragY = _snapStartY * (1 - t);
            _dragX = _snapStartX * (1 - t);
          });
        });

    _doubleTapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _snapBackController.dispose();
    _doubleTapController?.dispose();
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

  @override
  Widget build(BuildContext context) {
    final progress = (_dragY / 350).clamp(0.0, 1.0);
    final bgOpacity = (1.0 - progress).clamp(0.0, 1.0);
    final scale = (1.0 - progress * 0.15).clamp(0.85, 1.0);
    final borderRadius = progress * 30.0;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(bgOpacity),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(bgOpacity),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: widget.userName != null
            ? Text(
                widget.userName!,
                style: Styles.textStyle16SemiBold.copyWith(color: Colors.white),
              )
            : null,
      ),
      body: Transform.translate(
        offset: Offset(_dragX, _dragY),
        child: Transform.scale(
          scale: scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              color: Colors.black,
              width: double.infinity,
              height: double.infinity,
              child: GestureDetector(
                onDoubleTapDown: _onDoubleTapDown,
                onDoubleTap: () {},
                // السحب للأسفل فقط لما مفيش zoom
                onVerticalDragStart: (_) {
                  if (_isZoomed) return;
                  _snapBackController.stop();
                },
                onVerticalDragUpdate: (d) {
                  if (_isZoomed) return;
                  setState(() {
                    _dragY += d.delta.dy;
                    _dragX += d.delta.dx * 0.3;
                  });
                },
                onVerticalDragEnd: (d) {
                  if (_isZoomed) return;
                  final vel = d.velocity.pixelsPerSecond.dy;
                  if (_dragY > 120 || vel > 800) {
                    Navigator.pop(context);
                  } else {
                    _snapStartY = _dragY;
                    _snapStartX = _dragX;
                    _snapBackController.forward(from: 0);
                  }
                },
                child: Hero(
                  tag: widget.heroTag,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.8,
                    maxScale: 4.0,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    // نخلي InteractiveViewer يتحكم في الـ pan والـ scale بحرية
                    panEnabled: true,
                    scaleEnabled: true,
                    child: SizedBox.expand(
                      child: widget.imageFile != null
                          ? Image.file(widget.imageFile!, fit: BoxFit.contain)
                          : AppImage(widget.imageUrl, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
