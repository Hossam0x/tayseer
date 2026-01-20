import 'package:flutter/services.dart';

import '../../my_import.dart';

void CustomshowDialog(
  BuildContext context, {
  String? title,
  String? subTitle,
  String? trueChoice,
  required bool islogIn,
  void Function()? onPressed,
}) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Barrier",
    transitionDuration: Duration(milliseconds: 300),
    pageBuilder: (context, anim1, anim2) {
      return SizedBox(); // هذا لن يُستخدم، التحريك يكون بالـ transitionBuilder
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return Transform.scale(
        scale: anim1.value,
        child: Opacity(
          opacity: anim1.value,
          child: AlertDialog(
            title: Text(
              title ?? context.tr('alert'),
              style: Styles.textStyle14.copyWith(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            content: Text(
              subTitle ?? context.tr("guest_login_first"),
              style: Styles.textStyle12.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  context.tr('skip'),
                  style: Styles.textStyle12.copyWith(color: Colors.red),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: islogIn
                    ? () {
                        // context.pushReplacementNamed(AppRouter.kLoginScreen);
                        CachNetwork.removeData(key: 'token');
                      }
                    : onPressed,
                child: Text(
                  trueChoice ?? context.tr("login_button"),
                  style: Styles.textStyle12.copyWith(
                    color: AppColors.kprimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void CustomshowDialogWithImage(
  BuildContext context, {
  required String title,
  required String supTitle,
  required String imageUrl,
  required String bottonText,
  required void Function() onPressed,
  // ✅ Optional parameters
  String? cancelText,
  void Function()? onCancel,
  bool showCancelButton = false,
}) {
  HapticFeedback.mediumImpact();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _DialogContent(
        title: title,
        supTitle: supTitle,
        imageUrl: imageUrl,
        bottonText: bottonText,
        onPressed: onPressed,
        cancelText: cancelText,
        onCancel: onCancel,
        showCancelButton: showCancelButton,
        animation: animation,
      );
    },
  );
}

class _DialogContent extends StatelessWidget {
  final String title;
  final String supTitle;
  final String imageUrl;
  final String bottonText;
  final void Function() onPressed;
  final String? cancelText;
  final void Function()? onCancel;
  final bool showCancelButton;
  final Animation<double> animation;

  const _DialogContent({
    required this.title,
    required this.supTitle,
    required this.imageUrl,
    required this.bottonText,
    required this.onPressed,
    required this.animation,
    this.cancelText,
    this.onCancel,
    this.showCancelButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
        child: FadeTransition(
          opacity: animation,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            constraints: const BoxConstraints(maxWidth: 380),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  // ✅ الخلفية المتدرجة
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE8B4B8), // وردي فاتح
                        Color(0xFFF5E6E8), // وردي أفتح
                        Color(0xFFFAF5F5), // أبيض مائل للوردي
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // الصورة/الأيقونة
                        _buildImage(),

                        const SizedBox(height: 24),

                        // العنوان
                        _buildTitle(),

                        const SizedBox(height: 12),

                        // العنوان الفرعي
                        _buildSubtitle(),

                        const SizedBox(height: 28),

                        // الأزرار
                        _buildButtons(context),
                      ],
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

  Widget _buildImage() {
    return AppImage(imageUrl, width: 90, height: 90)
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
        )
        .shake(
          delay: const Duration(milliseconds: 500),
          duration: const Duration(milliseconds: 500),
          hz: 2,
          rotation: 0.05,
        );
  }

  Widget _buildTitle() {
    return Text(
          title,
          style: Styles.textStyle16.copyWith(
            color: const Color(0xFF2D2D2D),
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 400),
        )
        .slideY(
          begin: 0.5,
          end: 0,
          delay: const Duration(milliseconds: 200),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildSubtitle() {
    return Text(
          supTitle,
          style: Styles.textStyle12.copyWith(
            color: const Color(0xFF6B6B6B),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        )
        .animate()
        .fadeIn(
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 400),
        )
        .slideY(
          begin: 0.5,
          end: 0,
          delay: const Duration(milliseconds: 300),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildButtons(BuildContext context) {
    if (showCancelButton || cancelText != null) {
      // زرين جنب بعض
      return Row(
        children: [
          // زر التأكيد (نعم) - أخضر
          Expanded(
            child: _AnimatedDialogButton(
              text: bottonText,
              backgroundColor: const Color(0xFF4CAF50),
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
                onPressed();
              },
              delay: const Duration(milliseconds: 400),
            ),
          ),

          const SizedBox(width: 12),

          // زر الإلغاء (لا) - أحمر
          Expanded(
            child: _AnimatedDialogButton(
              text: cancelText ?? context.tr('no'),
              backgroundColor: const Color(0xFFE53935),
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              delay: const Duration(milliseconds: 500),
            ),
          ),
        ],
      );
    }

    // زر واحد فقط
    return _AnimatedDialogButton(
      text: bottonText,
      backgroundColor: AppColors.kprimaryColor,
      textColor: Colors.white,
      onPressed: () {
        Navigator.of(context).pop();
        onPressed();
      },
      delay: const Duration(milliseconds: 400),
      fullWidth: true,
    );
  }
}

/// زر متحرك للـ Dialog
class _AnimatedDialogButton extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final Duration delay;
  final bool fullWidth;

  const _AnimatedDialogButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    required this.delay,
    this.fullWidth = false,
  });

  @override
  State<_AnimatedDialogButton> createState() => _AnimatedDialogButtonState();
}

class _AnimatedDialogButtonState extends State<_AnimatedDialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onPressed();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.fullWidth ? double.infinity : null,
            transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
            transformAlignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: _isPressed
                  ? widget.backgroundColor.withOpacity(0.85)
                  : widget.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withOpacity(
                    _isPressed ? 0.2 : 0.35,
                  ),
                  blurRadius: _isPressed ? 4 : 10,
                  offset: Offset(0, _isPressed ? 2 : 5),
                ),
              ],
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: widget.textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
        .animate()
        .fadeIn(
          delay: widget.delay,
          duration: const Duration(milliseconds: 300),
        )
        .slideY(
          begin: 0.5,
          end: 0,
          delay: widget.delay,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
  }
}

void CustomSHowDetailsDialog(
  BuildContext context, {
  String? title, // عنوان الدايلوج (مثلاً: ارسال تحية)
  String? buttonLabel, // نص الزر (مثلاً: ارسال)
  VoidCallback? onSendPressed, // أكشن زر الارسال
  required Widget contantWidget, // المحتوى (التيكست فيلد)
}) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) {
      return const SizedBox(); // غير مستخدم هنا لأننا نستخدم transitionBuilder
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // انيميشن الانبثاق (Scale + Fade)
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack, // يعطي تأثير الارتداد الخفيف (Pop effect)
        ),
        child: FadeTransition(
          opacity: animation,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  // ✅ الخلفية المتدرجة (مثل الصورة)
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFCE4EC), // وردي فاتح جداً
                      Color(0xFFF3E5F5), // بنفسجي فاتح جداً
                      Color(0xFFE1F5FE), // أزرق سماوي فاتح
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. الهيدر (عنوان + زر إغلاق)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر الإغلاق
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey.shade600,
                            size: 24.sp,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        // العنوان
                        Text(
                          title ?? "ارسال تحية",
                          style: Styles.textStyle16Bold.copyWith(
                            color: const Color(0xFF5D1028), // لون نبيتي غامق
                          ),
                        ),
                        // مسافة وهمية عشان العنوان يبقى في النص بالظبط
                        SizedBox(width: 24.sp),
                      ],
                    ),

                    Gap(20.h),

                    // 2. المحتوى (الخلفية البيضاء)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w), // حواف داخلية
                      decoration: BoxDecoration(
                        color: Colors.white, // خلفية بيضاء للمحتوى
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: contantWidget,
                    ),

                    Gap(24.h),

                    CustomBotton(
                      useGradient: true,
                      title: context.tr('send'),
                      onPressed: onSendPressed,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
