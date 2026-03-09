// core/services/nav_animation_service.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tayseer/my_import.dart';

class NavAnimationService {
  static final NavAnimationService _instance = NavAnimationService._();
  static NavAnimationService get instance => _instance;
  NavAnimationService._();

  // ⭐ Key على الـ nav item index 1 عشان نعرف مكانه على الشاشة
   GlobalKey navItem1Key = GlobalKey();
  // ✅ هنا الصح - جوه NavAnimationService مش جوه _FlyingIconWidgetState
  void resetKey() {
    navItem1Key = GlobalKey();
  }
  OverlayEntry? _overlayEntry;

  /// شغّل الـ fly animation
  /// [fromContext]     - context الـ زرار اللي ضغطنا منه
  /// [iconAsset]       - الأيكون اللي هيطير (marriage أو consultation)
  /// [overlay]         - الـ OverlayState للشاشة
  /// [onComplete]      - callback بعد ما الـ animation تخلص
  void flyIcon({
    required BuildContext fromContext,
    required String iconAsset,
    required OverlayState overlay,
    VoidCallback? onComplete,
  }) {
    // ── مكان الـ source (الزرار في الـ dialog) ──
    final RenderBox? sourceBox =
        fromContext.findRenderObject() as RenderBox?;
    final srcOffset = sourceBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final srcSize = sourceBox?.size ?? Size.zero;
    final sourceCenter = Offset(
      srcOffset.dx + srcSize.width / 2,
      srcOffset.dy + srcSize.height / 2,
    );

    // ── مكان الـ target (nav item 1) ──
    final RenderBox? targetBox =
        navItem1Key.currentContext?.findRenderObject() as RenderBox?;
    final tgtOffset =
        targetBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final tgtSize = targetBox?.size ?? Size.zero;
    final targetCenter = Offset(
      tgtOffset.dx + tgtSize.width / 2,
      tgtOffset.dy + tgtSize.height / 2,
    );

    // ── أنشئ الـ overlay ──
    _overlayEntry = OverlayEntry(
      builder: (_) => _FlyingIconWidget(
        startPosition: sourceCenter,
        endPosition: targetCenter,
        iconAsset: iconAsset,
        onComplete: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
          onComplete?.call();
        },
      ),
    );

    overlay.insert(_overlayEntry!);
  }
}

// ══════════════════════════════════════════════════════════════
// Widget الـ أيكون الطاير
// ══════════════════════════════════════════════════════════════
class _FlyingIconWidget extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final String iconAsset;
  final VoidCallback onComplete;

  const _FlyingIconWidget({
    required this.startPosition,
    required this.endPosition,
    required this.iconAsset,
    required this.onComplete,
  });

  @override
  State<_FlyingIconWidget> createState() => _FlyingIconWidgetState();
}

class _FlyingIconWidgetState extends State<_FlyingIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // موضع X و Y
  late Animation<double> _xAnim;
  late Animation<double> _yAnim;

  // scale: يكبر وسط الرحلة ثم يصغر
  late Animation<double> _scaleAnim;

  // opacity: يظهر ببطء ثم يختفي في الآخر
  late Animation<double> _opacityAnim;

  // rotation خفيف
  late Animation<double> _rotateAnim;

  static const double _iconSize = 32;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // ── X: مسار مستقيم ──
    _xAnim = Tween(
      begin: widget.startPosition.dx - _iconSize / 2,
      end: widget.endPosition.dx - _iconSize / 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // ── Y: arc curve (يطلع للأعلى في المنتصف) ──
    final midY = _getMidY();
    _yAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: widget.startPosition.dy - _iconSize / 2,
          end: midY,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: midY,
          end: widget.endPosition.dy - _iconSize / 2,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    // ── Scale: صغير → كبير → صغير ──
    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.1, end: 0.3)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_controller);

    // ── Opacity: ظهور سريع ثم اختفاء في الآخر ──
    _opacityAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_controller);

    // ── Rotation: دورة خفيفة أثناء الطيران ──
    _rotateAnim = Tween(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  // نقطة منتصف القوس: أعلى من المنتصف الحقيقي
  double _getMidY() {
    final midRealY = (widget.startPosition.dy + widget.endPosition.dy) / 2;
    final distance =
        (widget.endPosition - widget.startPosition).distance;
    // ارتفاع القوس = ربع المسافة (مع حد أدنى)
    final arcHeight = max(distance * 0.35, 80.0);
    return midRealY - arcHeight;
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
      builder: (_, __) {
        return Positioned(
          left: _xAnim.value,
          top: _yAnim.value,
          child: IgnorePointer(
            child: Opacity(
              opacity: _opacityAnim.value,
              child: Transform.rotate(
                angle: _rotateAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: SizedBox(
                    width: _iconSize,
                    height: _iconSize,
                    child: AppImage(
                      widget.iconAsset,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}