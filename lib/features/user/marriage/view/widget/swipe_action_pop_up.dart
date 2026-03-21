import 'dart:math' as math;
import 'package:tayseer/my_import.dart';

enum SwipeActionType { like, dislike, favorite, regard }

class SwipeActionPopup extends StatefulWidget {
  final SwipeActionType type;
  final String? labelOverride; // ✅ أضف دي

  const SwipeActionPopup({
    super.key,
    required this.type,
    this.labelOverride, // ✅
  });

  @override
  State<SwipeActionPopup> createState() => _SwipeActionPopupState();
}

class _SwipeActionPopupState extends State<SwipeActionPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _iconScaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);

    _fadeAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 15,
      ),
    ]).animate(_controller);

    _rotationAnim = Tween<double>(
      begin: 0,
      end: 4 * math.pi,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.85, curve: Curves.easeInOutCubic),
      ),
    );

    _iconScaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 0.85),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.2),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 25,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.85, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ActionConfig get _config {
    switch (widget.type) {
      case SwipeActionType.like:
        return _ActionConfig(
          icon: Icons.check,
          color: HexColor('f8d3da'),
          iconColor: AppColors.kprimaryTextColor,
          label: 'like_action',
        );
      case SwipeActionType.dislike:
        return _ActionConfig(
          icon: Icons.close,
          color: HexColor('e44e6c'),
          iconColor: Colors.white,
          label: 'dislike_action',
        );
      case SwipeActionType.favorite:
        return _ActionConfig(
          icon: Icons.favorite,
          color: Colors.white,
          iconColor: Colors.red,
          label: 'favorite_action',
        );
      case SwipeActionType.regard:
        return _ActionConfig(
          icon: Icons.star,
          color: HexColor('cccab3'),
          iconColor: Colors.white,
          label: 'regard_action',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    // ✅ استخدم الـ labelOverride لو موجود، غير كده جرب context.tr
    final label = widget.labelOverride ?? context.tr(config.label);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 190.w,
                height: 190.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.80),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: config.color.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 6,
                    ),
                    BoxShadow(
                      color: config.color.withOpacity(0.2),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.rotate(
                      angle: _rotationAnim.value,
                      child: Transform.scale(
                        scale: _iconScaleAnim.value,
                        child: CircleAvatar(
                          radius: 40.r,
                          backgroundColor: config.color,
                          child: Icon(
                            config.icon,
                            color: config.iconColor,
                            size: 40.r,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      label, // ✅ استخدم الـ label المحلول
                      style: Styles.textStyle18Bold.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActionConfig {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final String label;

  const _ActionConfig({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.label,
  });
}