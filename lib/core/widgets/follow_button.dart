import 'package:flutter/services.dart';
import 'package:tayseer/core/widgets/cubit/follow_cubit.dart';
import 'package:tayseer/my_import.dart';

class FollowButton extends StatefulWidget {
  final VoidCallback? onTap;
  final bool isFollowing;

  const FollowButton({super.key, this.onTap, this.isFollowing = false});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.85,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap(BuildContext context) async {
    // Heavy vibration on tap
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 60));
    HapticFeedback.heavyImpact();

    // Scale-down then back animation
    await _controller.forward();
    await _controller.reverse();

    // Call the external callback first
    if (widget.onTap != null) {
      widget.onTap!();
    }

    // Then toggle the local cubit state
    context.read<FollowCubit>().toggle();
  }

  @override
  Widget build(BuildContext context) {
    // Hide if initially following (same logic as PostCard)
    if (widget.isFollowing) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (context) => FollowCubit(widget.isFollowing),
      child: BlocBuilder<FollowCubit, bool>(
        builder: (context, following) {
          return GestureDetector(
            onTap: () => _handleTap(context),
            child: ScaleTransition(
              scale: _scaleAnim,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Row(
                  key: ValueKey(following),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (following)
                      Icon(Icons.check, color: Colors.white70, size: 16.sp),
                    if (following) Gap(4.w),
                    Text(
                      following
                          ? context.tr("following")
                          : context.tr("follow"),
                      style: Styles.textStyle14SemiBold.copyWith(
                        color: following ? Colors.white70 : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
