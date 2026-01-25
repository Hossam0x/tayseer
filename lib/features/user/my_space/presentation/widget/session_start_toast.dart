import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/colors.dart';
import 'package:tayseer/my_import.dart';

class SessionToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onJoinTap;
  final VoidCallback onDismiss;

  const SessionToastWidget({
    super.key,
    required this.message,
    required this.onJoinTap,
    required this.onDismiss,
  });

  @override
  State<SessionToastWidget> createState() => _SessionToastWidgetState();
}

class _SessionToastWidgetState extends State<SessionToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    _timer = Timer(const Duration(seconds: 5), () {
      _dismiss();
    });
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10.h,
      left: 16.w,
      right: 16.w,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.kWhiteColor,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.kprimaryColor.withOpacity(0.15),
                    blurRadius: 20.r,
                    offset: Offset(0, 10.h),
                    spreadRadius: 2.r,
                  ),
                ],
                border: Border.all(color: AppColors.primary100, width: 1.w),
              ),
              child: Row(
                children: [
                  AppImage(AssetsData.phoneIcon, width: 24.w, height: 24.h),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "بدأت الجلسة الآن",
                          style: TextStyle(
                            color: AppColors.kprimaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppColors.text2,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  CustomBotton(
                    width: 120.w,
                    title: 'انضم',
                    onPressed: () {
                      widget.onJoinTap();
                      _dismiss();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
