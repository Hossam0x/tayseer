import 'dart:async';
import 'package:tayseer/my_import.dart';

class AnimatedHistoryButton extends StatefulWidget {
  const AnimatedHistoryButton({
    super.key,
    this.onTap,
    this.notificationCount = 0,
  });

  final VoidCallback? onTap;
  final int notificationCount;

  @override
  State<AnimatedHistoryButton> createState() => _AnimatedHistoryButtonState();
}

class _AnimatedHistoryButtonState extends State<AnimatedHistoryButton> {
  bool _isExpanded = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimationLoop();
  }

  void _startAnimationLoop() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutBack,
        padding: EdgeInsets.symmetric(
          horizontal: _isExpanded ? 12.w : 0.w,
          vertical: _isExpanded ? 15.h : 0.h,
        ),
        decoration: BoxDecoration(
          // ✅ gradient بس لما expanded | شفاف خالص لما collapsed
          gradient: _isExpanded
              ? LinearGradient(
                  colors: [AppColors.primary300, AppColors.primary200],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                )
              : null,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // ── لما expanded: النص بس ──
            // ── لما collapsed: الأيكون بس ──
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _isExpanded
                  ? Text(
                      key: const ValueKey('text'),
                      context.tr('view_who_interacted'),
                      style: Styles.textStyle12Bold.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      softWrap: false,
                    )
                  : SvgPicture.asset(
                      key: const ValueKey('icon'),
                      AssetsData.archiveIcon,
                      width: 44.w,
                      height: 44.h,
                    ),
            ),

            // ── Badge فوق الأيكون لما collapsed ──
            if (widget.notificationCount > 0 && !_isExpanded)
              Positioned(
                top: -3.w,
                right: 0.w,
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                  child: Text(
                    widget.notificationCount > 99
                        ? '99+'
                        : widget.notificationCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
