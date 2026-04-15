import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/my_import.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Open Post Button Overlay
// ─────────────────────────────────────────────────────────────────────────────
class StoryOpenPostButtonOverlay extends StatefulWidget {
  final Offset position;
  final VoidCallback onTap;

  const StoryOpenPostButtonOverlay({
    super.key,
    required this.position,
    required this.onTap,
  });

  @override
  State<StoryOpenPostButtonOverlay> createState() =>
      _StoryOpenPostButtonOverlayState();
}

class _StoryOpenPostButtonOverlayState extends State<StoryOpenPostButtonOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _slideAnim = Tween<double>(
      begin: 12,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const buttonWidth = 160.0;
    double left = widget.position.dx - buttonWidth / 2;
    left = left.clamp(16.0, screenWidth - buttonWidth - 16.0);
    final top = widget.position.dy - 60.0;

    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnim.value,
            child: Transform.translate(
              offset: Offset(0, _slideAnim.value),
              child: Transform.scale(
                scale: _scaleAnim.value,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
            ),
          );
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: buttonWidth,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.open_in_new_rounded,
                  size: 16.sp,
                  color: AppColors.kprimaryColor,
                ),
                Gap(6.w),
                Text(
                  context.tr('open_post'),
                  style: Styles.textStyle14SemiBold.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mute Button for Story Videos
// ─────────────────────────────────────────────────────────────────────────────
class StoryMuteButton extends StatelessWidget {
  const StoryMuteButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: GlobalMuteManager.instance.isMuted,
      builder: (context, isMuted, _) {
        return GestureDetector(
          onTap: () => GlobalMuteManager.instance.toggleMute(),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: Icon(
                isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                color: Colors.white,
                size: 22.sp,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Love Button
// ─────────────────────────────────────────────────────────────────────────────
class StoryLoveButton extends StatelessWidget {
  const StoryLoveButton({
    super.key,
    required this.isLiked,
    required this.onTap,
  });

  final bool isLiked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 45.w,
          height: 45.w,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.24),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.white,
            size: 26.sp,
          ),
        ),
      ),
    );
  }
}
