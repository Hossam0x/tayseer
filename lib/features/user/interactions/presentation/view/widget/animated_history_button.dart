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
          gradient:  LinearGradient(
            colors: [AppColors.primary300, AppColors.primary200],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ الأيكون بيختفي مع الـ animation
            Stack(
              
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    opacity: _isExpanded ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    child: SizedBox(
                      width: _isExpanded ? 0 : 50.w,
                      height: _isExpanded ? 22.h : 50.h,
                      child: _isExpanded
                          ? null
                          : SvgPicture.asset(
                              AssetsData.archiveIcon,
                              width: 50.w,
                              height: 50.h,
                            ),
                    ),
                  ),
                ),
                if (widget.notificationCount > 0)
                  Positioned(
                    top: -3.w,
                    right: 0.w,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 18.w,
                        minHeight: 18.w,
                      ),
                      child: Text(
                        widget.notificationCount > 99
                            ? '99+'
                            : widget.notificationCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: _isExpanded ? null : 0,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                    start: _isExpanded ? 0 : 8.w,
                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
