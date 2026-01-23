import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';

class ImageMessageWidget extends StatelessWidget {
  final List<String> images;
  final List<String>? localFilePaths; // ✅ New parameter
  final double maxWidth;
  final void Function(int index)? onImageTap;
  final double? uploadProgress; // ✅ Upload progress (0.0 to 1.0)

  const ImageMessageWidget({
    super.key,
    required this.images,
    this.localFilePaths,
    required this.maxWidth,
    this.onImageTap,
    this.uploadProgress,
  });

  @override
  Widget build(BuildContext context) {
    // If we have local files, use them
    final hasLocalFiles = localFilePaths != null && localFilePaths!.isNotEmpty;
    final displayList = hasLocalFiles ? localFilePaths! : images;

    if (displayList.isEmpty) return const SizedBox.shrink();

    if (displayList.length == 1) {
      return GestureDetector(
        onTap: () => onImageTap?.call(0),
        child: _buildSingleImage(displayList.first, isLocal: hasLocalFiles),
      );
    }

    return GestureDetector(
      onTap: () => onImageTap?.call(0),
      child: _buildImageGrid(context, displayList, isLocal: hasLocalFiles),
    );
  }

  Widget _buildSingleImage(String imagePath, {required bool isLocal}) {
    const double fixedHeight = 250.0; // Fixed height for consistency

    return ClipRRect(
      borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
      child: SizedBox(
        width: maxWidth - 8,
        height: fixedHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            isLocal
                ? Image.file(
                    File(imagePath),
                    width: maxWidth - 8,
                    height: fixedHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildErrorWidget(),
                  )
                : CachedNetworkImage(
                    imageUrl: imagePath,
                    width: maxWidth - 8,
                    height: fixedHeight,
                    fit: BoxFit.cover,
                    memCacheHeight: (fixedHeight * 2).toInt(), // Optimization
                    useOldImageOnUrlChange: true,
                    placeholder: (context, url) => _buildPlaceholder(),
                    errorWidget: (context, url, error) => _buildErrorWidget(),
                  ),
            // Upload progress overlay
            if (uploadProgress != null && uploadProgress! < 1.0)
              _buildUploadProgressOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgressOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: uploadProgress,
            strokeWidth: 4,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: maxWidth - 8,
      height: 250,
      color: Colors.grey[300],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: maxWidth - 8,
      height: 250,
      color: Colors.grey[300],
      child: const Icon(Icons.error, color: Colors.red),
    );
  }

  Widget _buildImageGrid(
    BuildContext context,
    List<String> displayList, {
    required bool isLocal,
  }) {
    final imageCount = displayList.length;
    final gridWidth = maxWidth - 8;
    const spacing = 4.0;

    if (imageCount == 2) {
      return _buildTwoImageGrid(gridWidth, spacing, displayList, isLocal);
    } else if (imageCount == 3) {
      return _buildThreeImageGrid(gridWidth, spacing, displayList, isLocal);
    } else {
      return _buildFourPlusImageGrid(
        gridWidth,
        spacing,
        displayList,
        imageCount,
        isLocal,
      );
    }
  }

  Widget _buildTwoImageGrid(
    double gridWidth,
    double spacing,
    List<String> list,
    bool isLocal,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
      child: SizedBox(
        width: gridWidth,
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onImageTap?.call(0),
                    child: _gridImage(list[0], isLocal: isLocal, height: 150),
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onImageTap?.call(1),
                    child: _gridImage(list[1], isLocal: isLocal, height: 150),
                  ),
                ),
              ],
            ),
            // Upload progress overlay on entire grid
            if (uploadProgress != null && uploadProgress! < 1.0)
              _buildUploadProgressOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeImageGrid(
    double gridWidth,
    double spacing,
    List<String> list,
    bool isLocal,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
      child: SizedBox(
        width: gridWidth,
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => onImageTap?.call(0),
                    child: _gridImage(list[0], isLocal: isLocal, height: 200),
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onImageTap?.call(1),
                          child: _gridImage(list[1], isLocal: isLocal),
                        ),
                      ),
                      SizedBox(height: spacing),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onImageTap?.call(2),
                          child: _gridImage(list[2], isLocal: isLocal),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Upload progress overlay on entire grid
            if (uploadProgress != null && uploadProgress! < 1.0)
              _buildUploadProgressOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildFourPlusImageGrid(
    double gridWidth,
    double spacing,
    List<String> list,
    int imageCount,
    bool isLocal,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
      child: SizedBox(
        width: gridWidth,
        height: 200,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onImageTap?.call(0),
                          child: _gridImage(list[0], isLocal: isLocal),
                        ),
                      ),
                      SizedBox(height: spacing),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onImageTap?.call(2),
                          child: _gridImage(list[2], isLocal: isLocal),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onImageTap?.call(1),
                          child: _gridImage(list[1], isLocal: isLocal),
                        ),
                      ),
                      SizedBox(height: spacing),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => onImageTap?.call(3),
                          child: imageCount > 4
                              ? _gridImageWithOverlay(
                                  list[3],
                                  imageCount - 4,
                                  isLocal: isLocal,
                                )
                              : _gridImage(list[3], isLocal: isLocal),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Upload progress overlay on entire grid
            if (uploadProgress != null && uploadProgress! < 1.0)
              _buildUploadProgressOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _gridImage(String path, {required bool isLocal, double? height}) {
    if (isLocal) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        height: height,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error, color: Colors.red, size: 20),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: path,
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
      memCacheHeight: height != null ? (height * 2).toInt() : 400,
      useOldImageOnUrlChange: true,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.error, color: Colors.red, size: 20),
      ),
    );
  }

  Widget _gridImageWithOverlay(
    String path,
    int remainingCount, {
    required bool isLocal,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _gridImage(path, isLocal: isLocal),
        Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Text(
              '+$remainingCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final bool isLocal; // ✅ Add isLocal parameter

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
    this.isLocal = false, // ✅ Default to false
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: widget.images.length > 1
            ? Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(color: Colors.white),
              )
            : null,
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: widget.isLocal
                  ? Image.file(
                      File(widget.images[index]),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                    )
                  : CachedNetworkImage(
                      imageUrl: widget.images[index],
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error, color: Colors.red, size: 50),
                      ),
                    ),
            ),
          );
        },
      ),
      bottomNavigationBar: widget.images.length > 1
          ? _buildThumbnailBar()
          : null,
    );
  }

  Widget _buildThumbnailBar() {
    return Container(
      height: 80,
      color: Colors.black,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: ChatAnimations.scrollDuration,
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _currentIndex == index
                      ? ChatColors.bubbleSender
                      : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: widget.isLocal
                    ? Image.file(
                        File(widget.images[index]),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.error, color: Colors.red),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: widget.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.grey[800]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.error, color: Colors.red),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
