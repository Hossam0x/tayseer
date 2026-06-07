import 'dart:ui';
import 'package:tayseer/my_import.dart';

class SpotlightTarget {
  final Rect? rect;
  final Offset? center;
  final double? radius;

  SpotlightTarget({this.rect, this.center, this.radius});
}

class MarriageTutorialOverlay extends StatefulWidget {
  final VoidCallback onFinish;
  final bool isNavVisible;

  const MarriageTutorialOverlay({
    super.key,
    required this.onFinish,
    this.isNavVisible = false,
  });

  @override
  State<MarriageTutorialOverlay> createState() =>
      _MarriageTutorialOverlayState();
}

class _MarriageTutorialOverlayState extends State<MarriageTutorialOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  final int _totalSteps = 6;

  late AnimationController _spotlightController;
  late AnimationController _pulseController;

  SpotlightTarget? _startTarget;
  SpotlightTarget? _endTarget;

  @override
  void initState() {
    super.initState();

    _spotlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Initialize first target after layout is built to get accurate metrics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _endTarget = _getTargetForStep(0);
        _spotlightController.forward(from: 1.0);
      });
    });
  }

  @override
  void dispose() {
    _spotlightController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  SpotlightTarget _getTargetForStep(int step) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final statusBarHeight = mediaQuery.padding.top;

    final isRTL = Localizations.localeOf(context).languageCode == 'ar';

    // Bottom action button Y coordinate (shared by steps 0, 1, 2)
    final double buttonY =
        screenHeight - (widget.isNavVisible ? 130.h : 30.h) - 35.r;

    switch (step) {
      // ── Step 0: Like button ──────────────────────────────────────────────
      // LTR: Like is the leftmost button  (~21% from left)
      // RTL: Flutter mirrors the Row, so Like ends up on the right (~79%)
      case 0:
        return SpotlightTarget(
          center: Offset(
            isRTL ? screenWidth * 0.79 : screenWidth * 0.21,
            buttonY,
          ),
          radius: 34.r,
        );

      // ── Step 1: Regard button (always center) ────────────────────────────
      case 1:
        return SpotlightTarget(
          center: Offset(screenWidth * 0.50, buttonY),
          radius: 34.r,
        );

      // ── Step 2: Dislike button ───────────────────────────────────────────
      // LTR: Dislike is the rightmost button (~78% from left)
      // RTL: Dislike ends up on the left (~22%)
      case 2:
        return SpotlightTarget(
          center: Offset(
            isRTL ? screenWidth * 0.21 : screenWidth * 0.78,
            buttonY,
          ),
          radius: 34.r,
        );

      // ── Step 3: Section Toggle (Top Center) ─────────────────────────────
      case 3:
        return SpotlightTarget(
          rect: Rect.fromCenter(
            center: Offset(screenWidth / 2, statusBarHeight + 36.h),
            width: 220.w,
            height: 48.h,
          ),
        );

      // ── Step 4: Filter Button ────────────────────────────────────────────
      // LTR: top-left  |  RTL: top-right
      case 4:
        final x = isRTL ? screenWidth - 16.w - 20.r : 16.w + 20.r;
        return SpotlightTarget(
          center: Offset(x, statusBarHeight + 36.h),
          radius: 26.r,
        );

      // ── Step 5: Be First / Premium Button ───────────────────────────────
      // LTR: top-right  |  RTL: top-left
      case 5:
        final x = isRTL ? 16.w + 20.w : screenWidth - 5.w - 35.w;
        return SpotlightTarget(
          center: Offset(x, statusBarHeight + 36.h),
          radius: 30.r,
        );

      default:
        return SpotlightTarget(
          center: Offset(screenWidth / 2, screenHeight / 2),
          radius: 50.r,
        );
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _startTarget = _getTargetForStep(_currentStep);
        _currentStep++;
        _endTarget = _getTargetForStep(_currentStep);
        _spotlightController.forward(from: 0.0);
      });
    } else {
      widget.onFinish();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _startTarget = _getTargetForStep(_currentStep);
        _currentStep--;
        _endTarget = _getTargetForStep(_currentStep);
        _spotlightController.forward(from: 0.0);
      });
    }
  }

  String _getTitleKeyForStep(int step) {
    switch (step) {
      case 0:
        return 'tutorial_like_title';
      case 1:
        return 'tutorial_regard_title';
      case 2:
        return 'tutorial_dislike_title';
      case 3:
        return 'tutorial_toggle_title';
      case 4:
        return 'tutorial_filter_title';
      case 5:
        return 'tutorial_befirst_title';
      default:
        return '';
    }
  }

  String _getDescKeyForStep(int step) {
    switch (step) {
      case 0:
        return 'tutorial_like_desc';
      case 1:
        return 'tutorial_regard_desc';
      case 2:
        return 'tutorial_dislike_desc';
      case 3:
        return 'tutorial_toggle_desc';
      case 4:
        return 'tutorial_filter_desc';
      case 5:
        return 'tutorial_befirst_desc';
      default:
        return '';
    }
  }

  /// Returns vertical position (top edge of the card) so the card appears
  /// just below the spotlight, or [null] which means we use [bottom] instead.
  double? _cardTopForStep(
    int step,
    double statusBarHeight,
    double screenHeight,
  ) {
    final target = _endTarget;
    if (target == null) return null;

    // For top area targets (steps 3, 4, 5) place the card below the spotlight
    if (step >= 3) {
      if (target.rect != null) {
        return target.rect!.bottom + 20.h;
      }
      if (target.center != null && target.radius != null) {
        return target.center!.dy + target.radius! + 20.h;
      }
    }
    return null;
  }

  double? _cardBottomForStep(int step, double screenHeight) {
    final target = _endTarget;
    if (target == null) return null;

    // For bottom action button targets (steps 0, 1, 2) place the card above the spotlight
    if (step <= 2) {
      if (target.center != null && target.radius != null) {
        final topOfTarget = target.center!.dy - target.radius!;
        return screenHeight - topOfTarget + 20.h;
      }
      if (target.rect != null) {
        return screenHeight - target.rect!.top + 20.h;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_endTarget == null) return const SizedBox.shrink();

    final isRTL = Localizations.localeOf(context).languageCode == 'ar';
    final mediaQuery = MediaQuery.of(context);
    final statusBarHeight = mediaQuery.padding.top;
    final screenHeight = mediaQuery.size.height;

    final double? cardTop = _cardTopForStep(
      _currentStep,
      statusBarHeight,
      screenHeight,
    );
    final double? cardBottom = _cardBottomForStep(_currentStep, screenHeight);

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Stack(
        children: [
          // Spotlight and blur background
          AnimatedBuilder(
            animation: Listenable.merge([
              _spotlightController,
              _pulseController,
            ]),
            builder: (context, child) {
              final val = _spotlightController.value;
              final pulseVal = _pulseController.value;

              final currentTarget = SpotlightTarget(
                rect: _startTarget?.rect != null && _endTarget?.rect != null
                    ? Rect.lerp(_startTarget!.rect, _endTarget!.rect, val)
                    : _endTarget?.rect,
                center:
                    _startTarget?.center != null && _endTarget?.center != null
                    ? Offset.lerp(_startTarget!.center, _endTarget!.center, val)
                    : _endTarget?.center,
                radius:
                    _startTarget?.radius != null && _endTarget?.radius != null
                    ? lerpDouble(_startTarget!.radius, _endTarget!.radius, val)
                    : _endTarget?.radius,
              );

              return CustomPaint(
                size: Size.infinite,
                painter: SpotlightPainter(
                  target: currentTarget,
                  spotlightProgress: val,
                  pulseProgress: pulseVal,
                ),
              );
            },
          ),

          // Intercept clicks on the overlay to prevent clicks under it
          // ✅ نستخدم Positioned.fill مع GestureDetector عشان يمنع الـ clicks
          // من الوصول للـ platform views تحت الـ overlay
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              onPanDown: (_) {},
            ),
          ),

          // Glassmorphic Dialog Card – positioned close to the spotlight
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            left: 20.w,
            right: 20.w,
            top: cardTop,
            bottom: cardBottom,
            child: TweenAnimationBuilder<double>(
              key: ValueKey<int>(_currentStep),
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                // clamp to [0,1] – easeOutBack can overshoot above 1.0
                final opacity = ((value - 0.8) / 0.2).clamp(0.0, 1.0);
                return Transform.scale(
                  scale: value,
                  child: Opacity(opacity: opacity, child: child),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Step indicators and Skip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.kprimaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                context
                                    .tr('tutorial_step')
                                    .replaceAll(
                                      '{current}',
                                      '${_currentStep + 1}',
                                    )
                                    .replaceAll('{total}', '$_totalSteps'),
                                style: Styles.textStyle12Bold.copyWith(
                                  color: AppColors.kprimaryTextColor,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: widget.onFinish,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                context.tr('tutorial_skip'),
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.kgreyColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gap(16.h),

                        // Title
                        Text(
                          context.tr(_getTitleKeyForStep(_currentStep)),
                          style: Styles.textStyle16Bold.copyWith(
                            color: AppColors.kprimaryTextColor,
                          ),
                        ),
                        Gap(8.h),

                        // Description
                        Text(
                          context.tr(_getDescKeyForStep(_currentStep)),
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.kscandryTextColor,
                            height: 1.4,
                          ),
                        ),
                        Gap(20.h),

                        // Footer: Progress dots & Navigation buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Progress dots
                            Row(
                              children: List.generate(
                                _totalSteps,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                                  width: index == _currentStep ? 16.w : 6.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    color: index == _currentStep
                                        ? AppColors.kprimaryColor
                                        : AppColors.kgreyNormalColor
                                              .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(3.r),
                                  ),
                                ),
                              ),
                            ),

                            // Navigation buttons
                            Row(
                              children: [
                                if (_currentStep > 0) ...[
                                  GestureDetector(
                                    onTap: _previousStep,
                                    child: CircleAvatar(
                                      radius: 20.r,
                                      backgroundColor: AppColors
                                          .kgreyNormalColor
                                          .withOpacity(0.2),
                                      child: Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 16.r,
                                        color: AppColors.kprimaryTextColor,
                                      ),
                                    ),
                                  ),
                                  Gap(8.w),
                                ],
                                CustomBotton(
                                  title: _currentStep == _totalSteps - 1
                                      ? context.tr('tutorial_finish')
                                      : context.tr('tutorial_next'),
                                  width: 100.w,
                                  height: 40.h,
                                  useGradient: true,
                                  onPressed: _nextStep,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
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

class SpotlightPainter extends CustomPainter {
  final SpotlightTarget target;
  final double spotlightProgress;
  final double pulseProgress;

  SpotlightPainter({
    required this.target,
    required this.spotlightProgress,
    required this.pulseProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.65)
      ..style = PaintingStyle.fill;

    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final spotlightPath = Path();

    if (target.rect != null) {
      spotlightPath.addRRect(
        RRect.fromRectAndRadius(target.rect!, Radius.circular(16.r)),
      );
    } else if (target.center != null && target.radius != null) {
      spotlightPath.addOval(
        Rect.fromCircle(center: target.center!, radius: target.radius!),
      );
    }

    // Cut out the spotlight using path subtraction (evenOdd fill / difference)
    final combinedPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      spotlightPath,
    );
    canvas.drawPath(combinedPath, backgroundPaint);

    // Pulse highlight paint
    final pulsePaint = Paint()
      ..color = AppColors.kprimaryColor.withOpacity(0.5 * (1.0 - pulseProgress))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 + 3.0 * pulseProgress;

    // Glowing border paint
    final borderPaint = Paint()
      ..color = AppColors.kprimaryColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    if (target.rect != null) {
      // Draw static glowing border
      canvas.drawRRect(
        RRect.fromRectAndRadius(target.rect!, Radius.circular(16.r)),
        borderPaint,
      );

      // Draw expanding pulse ring
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          target.rect!.inflate(4.w + 8.w * pulseProgress),
          Radius.circular(18.r),
        ),
        pulsePaint,
      );
    } else if (target.center != null && target.radius != null) {
      // Draw static glowing border
      canvas.drawCircle(target.center!, target.radius!, borderPaint);

      // Draw expanding pulse ring
      canvas.drawCircle(
        target.center!,
        target.radius! + 4.w + 8.w * pulseProgress,
        pulsePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.target.rect != target.rect ||
        oldDelegate.target.center != target.center ||
        oldDelegate.target.radius != target.radius ||
        oldDelegate.spotlightProgress != spotlightProgress ||
        oldDelegate.pulseProgress != pulseProgress;
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  final bool pointingUp;

  TrianglePainter({required this.color, required this.pointingUp});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointingUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
