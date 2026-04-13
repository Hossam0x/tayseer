import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/assets.dart';

VoidCallback showGifOverlay(           // ← غيّرنا void لـ VoidCallback
  BuildContext context, {
  String? gifPath,
  double? size,
  int repeatCount = 3,
  Duration gifDuration = const Duration(milliseconds: 900),
  double topOffset = 0,
}) {
  final String asset = gifPath ?? AssetsData.kGifOverlayLoading;
  final double imageSize = size ?? 400.w;

  OverlayEntry? gifEntry;
  int currentKey = 0;
  int currentRepeat = 0;

  void dismiss() {
    gifEntry?.remove();
    gifEntry = null;
  }

  void insertGif() {
    gifEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: topOffset,
        left: 0,
        right: 0,
        bottom: 0,
        child: IgnorePointer(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Image.asset(AssetsData.userBGImage, fit: BoxFit.cover),
              ),
              Positioned.fill(
                child: Container(color: Colors.white.withOpacity(0.55)),
              ),
              Center(
                child: Image.asset(
                  asset,
                  key: ValueKey(currentKey),
                  width: imageSize,
                  height: imageSize,
                  gaplessPlayback: false,
                ),
              ),
            ],
          ),
        ),
      ),
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

  return dismiss;                       // ← رجّعنا الـ dismiss
}