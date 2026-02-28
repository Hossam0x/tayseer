import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/full_image_editor_screen.dart';

class StyleCombinedGrid extends StatelessWidget {
  final List<File> capturedImages;
  final List<AssetEntity> galleryImages;
  final Function(File image) onRemoveCaptured;
  final Function(AssetEntity image) onRemoveGallery;
  final double spacing;

  const StyleCombinedGrid({
    super.key,
    required this.capturedImages,
    required this.galleryImages,
    required this.onRemoveCaptured,
    required this.onRemoveGallery,
    this.spacing = 3,
  });

  int get totalCount => capturedImages.length + galleryImages.length;

  // ════════════════════════════════════════════════════
  // ✅ فتح شاشة التعديل (من تحت لفوق زي الفيس)
  // ════════════════════════════════════════════════════

  void _openEditor(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.95,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          child: FullImageEditorScreen(
            capturedImages: capturedImages,
            galleryImages: galleryImages,
            onRemoveCaptured: onRemoveCaptured,
            onRemoveGallery: onRemoveGallery,
            initialIndex: index,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildLayout(context),
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    switch (totalCount) {
      case 1:
        return _buildSingleImage(context);
      case 2:
        return _buildTwoImages(context);
      case 3:
        return _buildThreeImages(context);
      case 4:
        return _buildFourImages(context);
      default:
        return _buildFiveOrMoreImages(context);
    }
  }

  // ═══════════════════════════════════════════════════
  // Helper: Get image widget at index (✅ مع onTap)
  // ═══════════════════════════════════════════════════
  Widget _getImageAt(
    BuildContext context,
    int index, {
    bool showRemove = true,
  }) {
    if (index < capturedImages.length) {
      return _fileImageItem(
        context: context,
        image: capturedImages[index],
        index: index,
        showRemove: showRemove,
      );
    } else {
      final galleryIndex = index - capturedImages.length;
      return _assetImageItem(
        context: context,
        asset: galleryImages[galleryIndex],
        index: index,
        showRemove: showRemove,
      );
    }
  }

  // ═══════════════════════════════════════════════════
  // 1 صورة
  // ═══════════════════════════════════════════════════
  Widget _buildSingleImage(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.height * 0.45,
      child: _getImageAt(context, 0),
    );
  }

  // ═══════════════════════════════════════════════════
  // 2 صور
  // ═══════════════════════════════════════════════════
  Widget _buildTwoImages(BuildContext context) {
    final height = context.height * 0.4;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(child: _getImageAt(context, 0)),
          SizedBox(width: spacing),
          Expanded(child: _getImageAt(context, 1)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // 3 صور
  // ═══════════════════════════════════════════════════
  Widget _buildThreeImages(BuildContext context) {
    final height = context.height * 0.45;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(flex: 1, child: _getImageAt(context, 0)),
          SizedBox(width: spacing),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(child: _getImageAt(context, 1)),
                SizedBox(height: spacing),
                Expanded(child: _getImageAt(context, 2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // 4 صور
  // ═══════════════════════════════════════════════════
  Widget _buildFourImages(BuildContext context) {
    final height = context.height * 0.5;
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(flex: 1, child: _getImageAt(context, 0)),
          SizedBox(width: spacing),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(child: _getImageAt(context, 1)),
                SizedBox(height: spacing),
                Expanded(child: _getImageAt(context, 2)),
                SizedBox(height: spacing),
                Expanded(child: _getImageAt(context, 3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // 5+ صور
  // ═══════════════════════════════════════════════════
  Widget _buildFiveOrMoreImages(BuildContext context) {
    final height = context.height * 0.5;
    final remaining = totalCount - 4;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(flex: 1, child: _getImageAt(context, 0)),
          SizedBox(width: spacing),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(child: _getImageAt(context, 1)),
                SizedBox(height: spacing),
                Expanded(child: _getImageAt(context, 2)),
                SizedBox(height: spacing),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _openEditor(context, 3),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _getImageAt(context, 3, showRemove: false),
                        if (remaining > 0)
                          Container(
                            color: Colors.black.withOpacity(0.55),
                            child: Center(
                              child: Text(
                                '+$remaining',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // File Image Item (من الكاميرا) ✅ مع onTap
  // ═══════════════════════════════════════════════════
  Widget _fileImageItem({
    required BuildContext context,
    required File image,
    required int index,
    bool showRemove = true,
  }) {
    return GestureDetector(
      onTap: () => _openEditor(context, index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            image,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          if (showRemove)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => onRemoveCaptured(image),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16.sp, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Asset Image Item (من الجاليري) ✅ مع onTap
  // ═══════════════════════════════════════════════════
  Widget _assetImageItem({
    required BuildContext context,
    required AssetEntity asset,
    required int index,
    bool showRemove = true,
  }) {
    return GestureDetector(
      onTap: () => _openEditor(context, index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder(
            future: asset.thumbnailDataWithSize(const ThumbnailSize(600, 600)),
            builder: (_, snap) {
              if (!snap.hasData) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }
              return Image.memory(
                snap.data!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
          if (showRemove)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => onRemoveGallery(asset),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 16.sp, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
