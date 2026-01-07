import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';

class ImageMessageWidget extends StatelessWidget {
  final List<String> images;
  final double maxWidth;
  final void Function(int index)? onImageTap;

  const ImageMessageWidget({
    super.key,
    required this.images,
    required this.maxWidth,
    this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    if (images.length == 1) {
      return GestureDetector(
        onTap: () => onImageTap?.call(0),
        child: _buildSingleImage(images.first),
      );
    }

    return GestureDetector(
      onTap: () => onImageTap?.call(0),
      child: _buildImageGrid(context),
    );
  }

  Widget _buildSingleImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: maxWidth - 8,
        fit: BoxFit.contain,
        placeholder: (context, url) => Container(
          width: maxWidth - 8,
          height: 200,
          color: Colors.grey[300],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          width: maxWidth - 8,
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.error, color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    final imageCount = images.length;
    final gridWidth = maxWidth - 8;
    const spacing = 4.0;

    if (imageCount == 2) {
      return _buildTwoImageGrid(gridWidth, spacing);
    } else if (imageCount == 3) {
      return _buildThreeImageGrid(gridWidth, spacing);
    } else {
      return _buildFourPlusImageGrid(gridWidth, spacing, imageCount);
    }
  }

  Widget _buildTwoImageGrid(double gridWidth, double spacing) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
      child: SizedBox(
        width: gridWidth,
        height: 150,
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => onImageTap?.call(0),
                child: _gridImage(images[0], height: 150),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: GestureDetector(
                onTap: () => onImageTap?.call(1),
                child: _gridImage(images[1], height: 150),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeImageGrid(double gridWidth, double spacing) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
      child: SizedBox(
        width: gridWidth,
        height: 200,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => onImageTap?.call(0),
                child: _gridImage(images[0], height: 200),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onImageTap?.call(1),
                      child: _gridImage(images[1]),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onImageTap?.call(2),
                      child: _gridImage(images[2]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFourPlusImageGrid(
    double gridWidth,
    double spacing,
    int imageCount,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ChatDimensions.bubbleRadiusSmall),
      child: SizedBox(
        width: gridWidth,
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onImageTap?.call(0),
                      child: _gridImage(images[0]),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onImageTap?.call(2),
                      child: _gridImage(images[2]),
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
                      child: _gridImage(images[1]),
                    ),
                  ),
                  SizedBox(height: spacing),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onImageTap?.call(3),
                      child: imageCount > 4
                          ? _gridImageWithOverlay(images[3], imageCount - 4)
                          : _gridImage(images[3]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gridImage(String url, {double? height}) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      height: height,
      width: double.infinity,
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

  Widget _gridImageWithOverlay(String url, int remainingCount) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _gridImage(url),
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

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
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
              child: CachedNetworkImage(
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
                child: CachedNetworkImage(
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
