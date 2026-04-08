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
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: _isExpanded ? 12.w : 0.w,
          vertical: _isExpanded ? 12.w : 0.h,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary300, AppColors.primary200],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    width: _isExpanded ? 0 : null,
                    child: AnimatedOpacity(
                      opacity: _isExpanded ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 400),
                      child: SvgPicture.asset(
                        AssetsData.archiveIcon,
                        width: !_isExpanded? 45.w: 24.w,
                        height:! _isExpanded? 45.h: 24.h
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    width: _isExpanded ? null : 0,
                    child: AnimatedOpacity(
                      opacity: _isExpanded ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        context.tr('view_who_interacted'),
                        style: Styles.textStyle12Bold.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Badge فوق الأيكون لما collapsed
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
