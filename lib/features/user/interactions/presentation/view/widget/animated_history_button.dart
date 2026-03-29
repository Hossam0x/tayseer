import 'dart:async';
import 'package:tayseer/my_import.dart';

class AnimatedHistoryButton extends StatefulWidget {
  const AnimatedHistoryButton({super.key, this.onTap});
  final VoidCallback? onTap;

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
          vertical:_isExpanded ? 15.h: 0.h,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFC107), Color(0xFFFF9800), Color(0xFFE91E63)],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B2FF7).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ الأيكون بيختفي مع الـ animation
            AnimatedSize(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: _isExpanded ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: _isExpanded ? 0 : 50.w,
                  height: _isExpanded ? 24.h : 50.h,
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
