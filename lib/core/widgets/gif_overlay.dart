import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/custom_app_image.dart';

/// Shows a full-screen white overlay with a repeating GIF animation.
///
/// [context]   - BuildContext used to access the Overlay.
/// [gifPath]   - Asset path of the GIF (defaults to [AssetsData.kGifOverlayLoading]).
/// [size]      - Width & height of the GIF image.
/// [repeatCount] - How many times the GIF should replay before dismissing.
/// [gifDuration] - Duration of a single GIF loop cycle.
void showGifOverlay(
  BuildContext context, {
  String? gifPath,
  double? size,
  int repeatCount = 3,
  Duration gifDuration = const Duration(milliseconds: 900),
}) {
  final String asset = gifPath ?? AssetsData.kGifOverlayLoading;
  final double imageSize = size ?? 400.w;
  final bool flipX = Directionality.of(context) == TextDirection.ltr;

  OverlayEntry? gifEntry;
  OverlayEntry? backEntry;
  int currentKey = 0;
  int currentRepeat = 0;

  void dismiss() {
    gifEntry?.remove();
    gifEntry = null;
    backEntry?.remove();
    backEntry = null;
  }

  void insertGif() {
    gifEntry = OverlayEntry(
      builder: (_) => IgnorePointer(
        child: Container(
          color: Colors.white,
          child: Center(
            child: Image.asset(
              asset,
              key: ValueKey(currentKey),
              width: imageSize,
              height: imageSize,
              gaplessPlayback: false,
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(gifEntry!);
  }

  // الـ back button في overlay منفصل ثابت لا يتأثر بالـ GIF loop
  backEntry = OverlayEntry(
    builder: (_) => SafeArea(
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                dismiss();
                Navigator.maybePop(context);
              },
              borderRadius: BorderRadius.circular(24.r),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Transform.flip(
                  flipX: flipX,
                  child: AppImage(AssetsData.backArrow, width: 19.w),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  insertGif();
  Overlay.of(context).insert(backEntry!);

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
    // نعيد insert الـ backEntry فوق الـ gifEntry الجديد
    backEntry?.remove();
    Overlay.of(context).insert(backEntry!);
    return true;
  });
}
