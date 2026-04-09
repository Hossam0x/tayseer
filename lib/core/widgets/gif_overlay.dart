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

  void dismiss() {
    entry?.remove();
    entry = null;
  }

  void insert() {
    entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.white,
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  asset,
                  key: ValueKey(currentKey),
                  width: imageSize,
                  height: imageSize,
                  gaplessPlayback: false,
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () {
                      dismiss();
                      Navigator.maybePop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Overlay.of(context).insert(entry!);
  }

  insert();

  Future.doWhile(() async {
    await Future.delayed(gifDuration);
    if (entry == null) return false;
    currentRepeat++;
    if (currentRepeat >= repeatCount) {
      dismiss();
      return false;
    }
    entry?.remove();
    currentKey++;
    insert();
    return true;
  });
}
