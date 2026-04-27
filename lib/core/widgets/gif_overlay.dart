import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/assets.dart';

VoidCallback showGifOverlay(
  BuildContext context, {
  String? gifPath,
  double? size,
  int repeatCount = 3,
  Duration gifDuration = const Duration(milliseconds: 900),
  // topOffset مش بيتستخدم بعد كده — بيغطي كل الصفحة دايمًا
  double topOffset = 0,
}) {
  final String asset = gifPath ?? AssetsData.kGifOverlayLoading;
  final double imageSize = size ?? 400.w;

  OverlayEntry? gifEntry;
  int currentKey = 0;
  int currentRepeat = 0;

  // ✅ لتتبع موضع السحب
  double _dragStartX = 0;
  double _dragOffsetX = 0;

  void dismiss() {
    gifEntry?.remove();
    gifEntry = null;
  }

  void rebuild() {
    gifEntry?.markNeedsBuild();
  }

  void insertGif() {
    gifEntry = OverlayEntry(
      builder: (_) {
        return Positioned.fill(
          child: GestureDetector(
            // ✅ السحب من الجنب يشيل الـ overlay
            onHorizontalDragStart: (details) {
              _dragStartX = details.globalPosition.dx;
              _dragOffsetX = 0;
            },
            onHorizontalDragUpdate: (details) {
              _dragOffsetX = details.globalPosition.dx - _dragStartX;
              rebuild();
            },
            onHorizontalDragEnd: (details) {
              // لو سحب أكتر من 80 بكسل في أي اتجاه → اشيله
              if (_dragOffsetX.abs() > 80) {
                dismiss();
              } else {
                _dragOffsetX = 0;
                rebuild();
              }
            },
            child: AnimatedSlide(
              offset: Offset(_dragOffsetX / MediaQueryData.fromView(
                WidgetsBinding.instance.platformDispatcher.views.first,
              ).size.width, 0),
              duration: _dragOffsetX == 0
                  ? const Duration(milliseconds: 200)
                  : Duration.zero,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ✅ خلفية تغطي كل الصفحة
                  Positioned.fill(
                    child: Image.asset(AssetsData.userBGImage, fit: BoxFit.cover),
                  ),
                  Positioned.fill(
                    child: Container(color: Colors.white.withOpacity(0.55)),
                  ),
                  // ✅ GIF في المنتصف
                  Center(
                    child: Image.asset(
                      asset,
                      key: ValueKey(currentKey),
                      width: imageSize,
                      height: imageSize,
                      gaplessPlayback: false,
                    ),
                  ),
                  // ✅ hint للسحب في الأسفل
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swipe,
                          color: Colors.grey.withOpacity(0.5),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'اسحب للإغلاق',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(gifEntry!);
  }

  insertGif();

  Future.doWhile(() async {
    await Future.delayed(gifDuration);
    if (gifEntry == null) return false;
    currentRepeat++;
    if (currentRepeat >= repeatCount) {
      dismiss();
      return false;
    }
    gifEntry?.remove();
    currentKey++;
    insertGif();
    return true;
  });

  return dismiss;
}