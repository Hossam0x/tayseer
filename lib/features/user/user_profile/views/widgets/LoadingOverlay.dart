import 'package:lottie/lottie.dart';
import 'package:tayseer/my_import.dart';

class MarriageLoadingOverlay extends StatefulWidget {
  const MarriageLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  State<MarriageLoadingOverlay> createState() => _MarriageLoadingOverlayState();
}

class _MarriageLoadingOverlayState extends State<MarriageLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    if (widget.isLoading) _fadeController.forward();
  }

  @override
  void didUpdateWidget(MarriageLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _fadeController.forward();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _fadeController.reverse();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            if (_fadeAnimation.value == 0) return const SizedBox.shrink();
            return Positioned.fill(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: child,
              ),
            );
          },
          child: _buildOverlayContent(context),
        ),
      ],
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return ColoredBox(
      color: Colors.white.withOpacity(0.88),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnimation(),
            if (widget.message != null) ...[
              Gap(8.h),
              Text(
                widget.message!,
                style: Styles.textStyle16.copyWith(
                  color: AppColors.primary400,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimation() {
  return Image.asset(
    AssetsData.loading,
    // width: 120.w,
    // height: 120.w,
    fit: BoxFit.contain,
    gaplessPlayback: true, // مهم أحيانًا
  );
}

  Widget _fallbackSpinner() {
    return SizedBox(
      width: 56.w,
      height: 56.w,
      child: CircularProgressIndicator(
        color: AppColors.primary300,
        strokeWidth: 3,
      ),
    );
  }
}

extension MarriageLoadingOverlayX on Widget {
  Widget withMarriageLoading({
    required bool isLoading,
    String? message,
  }) {
    return MarriageLoadingOverlay(
      isLoading: isLoading,
      message: message,
      child: this,
    );
  }
}