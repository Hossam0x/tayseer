import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tayseer/core/utils/assets.dart';

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

  OverlayEntry? entry;
  int currentKey = 0;
  int currentRepeat = 0;

  void insert() {
    entry = OverlayEntry(
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
    Overlay.of(context).insert(entry!);
  }

  insert();

  Future.doWhile(() async {
    await Future.delayed(gifDuration);
    currentRepeat++;
    if (currentRepeat >= repeatCount) {
      entry?.remove();
      entry = null;
      return false;
    }
    entry?.remove();
    currentKey++;
    insert();
    return true;
  });
}
