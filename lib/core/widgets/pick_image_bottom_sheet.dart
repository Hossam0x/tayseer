import 'dart:typed_data';
import 'package:tayseer/core/utils/helper/picker_helper.dart';
import 'package:tayseer/my_import.dart';

class CustomGallerySheet extends StatefulWidget {
  final PickerConfig config;
  final Function(List<SelectedMedia> mediaList) onMediaSelected;

  const CustomGallerySheet({
    super.key,
    required this.config,
    required this.onMediaSelected,
  });

  @override
  State<CustomGallerySheet> createState() => _CustomGallerySheetState();
}

class _CustomGallerySheetState extends State<CustomGallerySheet> {
  late final MediaPickerController _controller;
  final ScrollController _scrollController = ScrollController();
  bool _isConverting = false;

  @override
  void initState() {
    super.initState();
    _controller = MediaPickerController(config: widget.config);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 500) {
        // زودنا الرقم لتحميل أسرع
        _controller.loadMoreAssets();
      }
    });
  }

  void _onAssetTap(AssetEntity asset) {
    if (widget.config.allowMultiple) {
      bool success = _controller.toggleSelection(asset);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("الحد الأقصى ${widget.config.maxCount} عناصر"),
            duration: const Duration(milliseconds: 1000),
          ),
        );
      }
    } else {
      _controller.toggleSelection(asset);
      _confirmSelection();
    }
  }

  Future<void> _confirmSelection() async {
    if (_controller.selectedCount == 0) return;
    setState(() {
      _isConverting = true;
    });
    final result = await _controller.submitSelection();
    widget.onMediaSelected(result);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.height * 0.7,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // --- Header ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SizedBox(
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // centered handle
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: context.width * 0.2,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // confirm button on the left when multi-select
                  if (widget.config.allowMultiple)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final count = _controller.selectedCount;
                          final bool isEnabled = count > 0 && !_isConverting;
                          return GestureDetector(
                            onTap: isEnabled ? _confirmSelection : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isEnabled
                                    ? AppColors.kprimaryColor
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: _isConverting
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      "${context.tr('confirm')}($count)",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // --- Grid ---
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.isLoading && _controller.assets.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.assets.isEmpty) {
                  return const Center(
                    child: Text(
                      "لا توجد ميديا",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  // addAutomaticKeepAlives: true, // مهم للأداء
                  cacheExtent:
                      1000, // يحفظ الصور في الذاكرة قبل ظهورها لمنع التقطيع
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _controller.assets.length + 1,
                  itemBuilder: (context, index) {
                    // زر الكاميرا
                    if (index == 0) {
                      return GestureDetector(
                        onTap: () async {
                          final result = await _controller.pickFromCamera();
                          if (result != null) {
                            widget.onMediaSelected([result]);
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            color: AppColors.kprimaryColor,
                            size: 30,
                          ),
                        ),
                      );
                    }

                    // --- استخدام الويدجت المفصول هنا ---
                    final asset = _controller.assets[index - 1];
                    final isSelected = _controller.isSelected(asset);

                    return _MediaItem(
                      key: ValueKey(asset.id), // Key مهم جداً لثبات الصورة
                      asset: asset,
                      isSelected: isSelected,
                      isMultiSelect: widget.config.allowMultiple,
                      onTap: () => _onAssetTap(asset),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================
// WIDGET منفصل لحل مشكلة الوميض وإعادة التحميل
// =========================================================
class _MediaItem extends StatefulWidget {
  final AssetEntity asset;
  final bool isSelected;
  final bool isMultiSelect;
  final VoidCallback onTap;

  const _MediaItem({
    super.key,
    required this.asset,
    required this.isSelected,
    required this.isMultiSelect,
    required this.onTap,
  });

  @override
  State<_MediaItem> createState() => _MediaItemState();
}

class _MediaItemState extends State<_MediaItem> {
  // نعرف المتغير هنا ليتم تحميله مرة واحدة فقط
  late Future<Uint8List?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    // تحميل الصورة مرة واحدة عند إنشاء العنصر
    _thumbnailFuture = widget.asset.thumbnailDataWithSize(
      const ThumbnailSize.square(250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // الصورة: نستخدم الـ Future المحفوظ
            FutureBuilder<Uint8List?>(
              future: _thumbnailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true, // يمنع الوميض الأبيض عند التحديث
                  );
                }
                // لون الخلفية أثناء التحميل
                return Container(color: Colors.grey.withOpacity(0.2));
              },
            ),

            // طبقة التحديد (Overlay)
            if (widget.isSelected)
              Container(color: AppColors.kprimaryColor.withOpacity(0.4)),

            // علامة الصح
            if (widget.isMultiSelect && widget.isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.kprimaryColor,
                  child: Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),

            // مدة الفيديو
            if (widget.asset.type == AssetType.video)
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "${widget.asset.duration ~/ 60}:${(widget.asset.duration % 60).toString().padLeft(2, '0')}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.videocam, color: Colors.white, size: 10),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
