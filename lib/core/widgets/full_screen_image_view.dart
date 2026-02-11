import 'package:tayseer/my_import.dart';

/// Full screen image viewer with Hero animation, pinch-to-zoom, and swipe-to-dismiss
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
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();

  double _dragDistance = 0.0;
  bool _isDragging = false;
  late AnimationController _dismissController;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    // Only allow dragging if not zoomed in
    if (_transformationController.value.getMaxScaleOnAxis() <= 1.0) {
      setState(() {
        _isDragging = true;
        _dragDistance += details.delta.dy;
      });
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    final shouldDismiss = _dragDistance.abs() > 100 || velocity.abs() > 700;

    if (shouldDismiss) {
      // Animate to dismiss
      _dismissController.forward().then((_) {
        Navigator.pop(context);
      });
    } else {
      // Reset position with animation
      setState(() {
        _isDragging = false;
        _dragDistance = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate opacity based on drag distance (smoother fade)
    final opacity = (1.0 - (_dragDistance.abs() / 400)).clamp(0.0, 1.0);

    // Calculate scale based on drag distance (shrink effect)
    final scale = (1.0 - (_dragDistance.abs() / 1000)).clamp(0.85, 1.0);

    return GestureDetector(
      // Wrap entire screen to detect swipe anywhere
      onVerticalDragUpdate: _handleVerticalDragUpdate,
      onVerticalDragEnd: _handleVerticalDragEnd,
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(opacity),
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(opacity),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: widget.userName != null
              ? Text(
                  widget.userName!,
                  style: Styles.textStyle16SemiBold.copyWith(
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        body: AnimatedContainer(
          duration: _isDragging
              ? Duration.zero
              : const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _dragDistance, 0.0)
            ..scale(scale),
          child: Center(
            child: Hero(
              tag: widget.heroTag,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: widget.imageFile != null
                    ? Image.file(widget.imageFile!, fit: BoxFit.contain)
                    : AppImage(widget.imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
