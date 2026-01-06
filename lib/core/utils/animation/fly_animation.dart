import 'package:flutter/material.dart';

class FlyAnimation {
  static void flyWidget({
    required BuildContext context,
    GlobalKey? startKey,
    Offset? startOffset,
    required GlobalKey endKey,
    required Widget child,
    VoidCallback? onComplete,
  }) {
    // 1. تحديد نقطة البداية
    Offset? startPos = startOffset;
    if (startPos == null && startKey != null) {
      final RenderBox? startBox = startKey.currentContext?.findRenderObject() as RenderBox?;
      startPos = startBox?.localToGlobal(Offset.zero);
    }

    if (startPos == null) return;

    // 2. تحديد نقطة النهاية
    final RenderBox? endBox = endKey.currentContext?.findRenderObject() as RenderBox?;
    if (endBox == null) {
      onComplete?.call();
      return;
    }
    final endPos = endBox.localToGlobal(Offset.zero);

    // 3. إنشاء الـ Overlay
    final overlayState = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) => _FlyingWidget(
        startPos: startPos!,
        endPos: endPos,
        onComplete: () {
          entry.remove();
          onComplete?.call();
        },
        child: child,
      ),
    );

    overlayState.insert(entry);
  }
}

class _FlyingWidget extends StatefulWidget {
  final Offset startPos;
  final Offset endPos;
  final Widget child;
  final VoidCallback onComplete;

  const _FlyingWidget({
    required this.startPos,
    required this.endPos,
    required this.child,
    required this.onComplete,
  });

  @override
  State<_FlyingWidget> createState() => _FlyingWidgetState();
}

class _FlyingWidgetState extends State<_FlyingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack);

    _positionAnimation = Tween<Offset>(
      begin: widget.startPos,
      end: widget.endPos,
    ).animate(curve);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(curve);
    
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
       CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0)),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}