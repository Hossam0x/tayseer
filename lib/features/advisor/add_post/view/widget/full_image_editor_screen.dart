import 'package:tayseer/my_import.dart';

class FullImageEditorScreen extends StatefulWidget {
  final List<File> capturedImages;
  final List<AssetEntity> galleryImages;
  final Function(File image) onRemoveCaptured;
  final Function(AssetEntity image) onRemoveGallery;
  final int initialIndex;

  const FullImageEditorScreen({
    super.key,
    required this.capturedImages,
    required this.galleryImages,
    required this.onRemoveCaptured,
    required this.onRemoveGallery,
    this.initialIndex = 0,
  });

  @override
  State<FullImageEditorScreen> createState() => _FullImageEditorScreenState();
}

class _FullImageEditorScreenState extends State<FullImageEditorScreen> {
  late ScrollController _scrollController;
  late List<File> _capturedImages;
  late List<AssetEntity> _galleryImages;

  int get totalCount => _capturedImages.length + _galleryImages.length;

  @override
  void initState() {
    super.initState();
    _capturedImages = List.from(widget.capturedImages);
    _galleryImages = List.from(widget.galleryImages);
    _scrollController = ScrollController();

    // ✅ Scroll to initial image
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex > 0 && _scrollController.hasClients) {
        final itemHeight = context.height * 0.75;
        _scrollController.jumpTo(widget.initialIndex * itemHeight);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _removeAtIndex(int index) {
    setState(() {
      if (index < _capturedImages.length) {
        final image = _capturedImages[index];
        _capturedImages.removeAt(index);
        widget.onRemoveCaptured(image);
      } else {
        final galleryIndex = index - _capturedImages.length;
        final asset = _galleryImages[galleryIndex];
        _galleryImages.removeAt(galleryIndex);
        widget.onRemoveGallery(asset);
      }
    });

    if (totalCount == 0) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ════════════════════════════════════════════
          // ✅ SliverAppBar
          // ════════════════════════════════════════════
          SliverAppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              context.tr('edit'),
              style: Styles.textStyle18Bold.copyWith(color: Colors.white),
            ),
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Text(
                  context.tr('done'),
                  style: Styles.textStyle16.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Center(
                  child: Text(
                    '$totalCount ${context.tr('photos')}',
                    style: Styles.textStyle14.copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ════════════════════════════════════════════
          // ✅ قائمة الصور
          // ════════════════════════════════════════════
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildImageCard(context, index),
              childCount: totalCount,
            ),
          ),

          // ✅ مسافة في الأسفل
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Image Card
  // ═══════════════════════════════════════════════════
  Widget _buildImageCard(BuildContext context, int index) {
    return Column(
      children: [
        Stack(
          children: [
            // ✅ الصورة
            SizedBox(
              width: double.infinity,
              height: context.height * 0.65,
              child: _getImageWidget(index),
            ),

            // ✅ Top Bar (X + ...)
            Positioned(
              top: 12.h,
              left: 12.w,
              right: 12.w,
              child: Row(
                children: [
                  _buildActionButton(
                    icon: Icons.close,
                    onTap: () => _removeAtIndex(index),
                  ),
                  SizedBox(width: 8.w),
                  _buildActionButton(
                    icon: Icons.more_horiz,
                    onTap: () => _showImageOptions(context, index),
                  ),
                ],
              ),
            ),
          ],
        ),

        // // ✅ Caption
        // Container(
        //   width: double.infinity,
        //   color: Colors.black,
        //   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        //   child: Text(
        //     context.tr('add_caption'),
        //     style: Styles.textStyle14.copyWith(color: Colors.grey.shade500),
        //     textAlign: TextAlign.right,
        //   ),
        // ),

        // Divider
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(
            color: Colors.grey.shade800,
            thickness: 0.5,
            height: 1,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════
  // Get Image Widget by index
  // ═══════════════════════════════════════════════════
  Widget _getImageWidget(int index) {
    if (index < _capturedImages.length) {
      return Image.file(
        _capturedImages[index],
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
    } else {
      final galleryIndex = index - _capturedImages.length;
      final asset = _galleryImages[galleryIndex];
      return FutureBuilder(
        future: asset.thumbnailDataWithSize(const ThumbnailSize(1200, 1200)),
        builder: (_, snap) {
          if (!snap.hasData) {
            return Container(
              color: Colors.grey.shade900,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            );
          }
          return Image.memory(
            snap.data!,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          );
        },
      );
    }
  }

  // ═══════════════════════════════════════════════════
  // Action Button (X, ...)
  // ═══════════════════════════════════════════════════
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // Bottom Sheet Options
  // ═══════════════════════════════════════════════════
  void _showImageOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  context.tr('delete_image'),
                  style: Styles.textStyle16.copyWith(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeAtIndex(index);
                },
              ),
              ListTile(
                leading: Icon(Icons.swap_vert, color: Colors.grey.shade300),
                title: Text(
                  context.tr('move_up'),
                  style: Styles.textStyle16.copyWith(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _moveImageUp(index);
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════
  // ✅ نقل الصورة لأعلى
  // ═══════════════════════════════════════════════════
  void _moveImageUp(int index) {
    if (index <= 0) return;

    setState(() {
      if (index < _capturedImages.length) {
        // نقل داخل الـ capturedImages
        final image = _capturedImages.removeAt(index);
        _capturedImages.insert(index - 1, image);
        widget.onRemoveCaptured; // no-op, just reorder locally
      } else {
        final galleryIndex = index - _capturedImages.length;
        if (galleryIndex > 0) {
          // نقل داخل الـ galleryImages
          final asset = _galleryImages.removeAt(galleryIndex);
          _galleryImages.insert(galleryIndex - 1, asset);
        } else if (_capturedImages.isNotEmpty) {
          // الصورة أول واحدة في الجاليري ← مينفعش تتنقل لفوق في الكاميرا
          // ممكن تسيبها أو تعمل swap
        }
      }
    });
  }
}
