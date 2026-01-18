import 'dart:async';
import 'package:tayseer/my_import.dart';

class AnimatedBeFirstButton extends StatefulWidget {
  const AnimatedBeFirstButton({super.key});

  @override
  State<AnimatedBeFirstButton> createState() => _AnimatedBeFirstButtonState();
}

class _AnimatedBeFirstButtonState extends State<AnimatedBeFirstButton> {
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
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutBack,
        padding: EdgeInsets.symmetric(
          horizontal: _isExpanded ? 12.w : 15.w,
          vertical: 15.h,
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
              color: const Color(0xFFE91E63).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppImage(
              AssetsData.koneIcon,
              width: 24.w,
              height: 24.h,
              color: Colors.white,
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              child: SizedBox(
                width: _isExpanded ? null : 0,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 8.w),
                  child: AnimatedOpacity(
                    opacity: _isExpanded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      context.tr('enhance'),
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
