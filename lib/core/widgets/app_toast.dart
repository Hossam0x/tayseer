import 'package:tayseer/my_import.dart';

/// نوع التوست
enum ToastType { success, error, info, warning }

/// ويدجت التوست المخصص
class AppToast {
  static OverlayEntry? _currentToast;

  /// عرض التوست
  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.success,
    Duration duration = const Duration(seconds: 2),
    IconData? icon,
  }) {
    // إزالة أي توست موجود
    _currentToast?.remove();
    _currentToast = null;

    final overlay = Overlay.of(context);

    _currentToast = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        icon: icon,
        onDismiss: () {
          _currentToast?.remove();
          _currentToast = null;
        },
        duration: duration,
      ),
    );

    overlay.insert(_currentToast!);
  }

  /// عرض توست نجاح
  static void success(BuildContext context, String message) {
    show(
      context,
      message: message,
      type: ToastType.success,
      icon: Icons.check_circle_rounded,
    );
  }

  /// عرض توست خطأ
  static void error(BuildContext context, String message) {
    show(
      context,
      message: message,
      type: ToastType.error,
      icon: Icons.error_rounded,
    );
  }

  /// عرض توست معلومات
  static void info(BuildContext context, String message) {
    show(
      context,
      message: message,
      type: ToastType.info,
      icon: Icons.info_rounded,
    );
  }

  /// عرض توست تحذير
  static void warning(BuildContext context, String message) {
    show(
      context,
      message: message,
      type: ToastType.warning,
      icon: Icons.warning_rounded,
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final IconData? icon;
  final VoidCallback onDismiss;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.type,
    this.icon,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // إخفاء التوست بعد المدة المحددة
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  Color get _backgroundColor {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.kprimaryColor;
      case ToastType.error:
        return const Color(0xFFE53935);
      case ToastType.info:
        return AppColors.kGreyB3;
      case ToastType.warning:
        return const Color(0xFFFFA726);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 70.h,
      left: 16.w,
      right: 16.w,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (_) => _dismiss(),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.circular(18.r),
                  boxShadow: [
                    BoxShadow(
                      color: _backgroundColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
