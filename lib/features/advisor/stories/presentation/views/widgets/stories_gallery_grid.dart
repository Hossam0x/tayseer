import 'dart:typed_data';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_state.dart';
import 'package:tayseer/my_import.dart';

import 'package:camera/camera.dart';

class StoriesGalleryGrid extends StatefulWidget {
  final CameraController? controller;
  final bool isInitialized;
  final VoidCallback onCameraTap;
  const StoriesGalleryGrid({
    super.key,
    required this.onCameraTap,
    this.controller,
    this.isInitialized = false,
  });

  @override
  State<StoriesGalleryGrid> createState() => _StoriesGalleryGridState();
}

class _StoriesGalleryGridState extends State<StoriesGalleryGrid> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddStoryCubit, AddStoryState>(
      builder: (context, state) {
        if (state.galleryAssets.isEmpty && state.isLoadingAssets) {
          return const Center(child: CircularProgressIndicator());
        }

        // Handle case where no assets are found (permission or generic failure)
        if (state.galleryAssets.isEmpty && !state.isLoadingAssets) {
          // Re-trigger load if assets list is unexpectedly empty to be sure
          if (state.hasMoreAssets) {
            context.read<AddStoryCubit>().loadGalleryAssets();
          }
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              context.read<AddStoryCubit>().loadGalleryAssets();
            }
            return false;
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 0.65,
            ),
            itemCount: state.galleryAssets.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCameraItem(context);
              }
              final asset = state.galleryAssets[index - 1];
              return _GalleryItem(
                asset: asset,
                onTap: () => context.read<AddStoryCubit>().selectAsset(asset),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCameraItem(BuildContext context) {
    return GestureDetector(
      onTap: widget.onCameraTap,
      child: Container(
        color: Colors.black,
        child: widget.isInitialized && widget.controller != null
            ? ClipRRect(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 0.65,
                    child: CameraPreview(widget.controller!),
                  ),
                ),
              )
            : const Icon(Icons.camera_alt, size: 40, color: Colors.white),
      ),
    );
  }
}

class _GalleryItem extends StatefulWidget {
  final AssetEntity asset;
  final VoidCallback onTap;
  const _GalleryItem({required this.asset, required this.onTap});

  @override
  State<_GalleryItem> createState() => _GalleryItemState();
}

class _GalleryItemState extends State<_GalleryItem> {
  late Future<Uint8List?> _thumbnailFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailFuture = widget.asset.thumbnailDataWithSize(
      const ThumbnailSize.square(300),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.asset.type == AssetType.video;

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder<Uint8List?>(
            future: _thumbnailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data != null) {
                return Image.memory(snapshot.data!, fit: BoxFit.cover);
              }
              return Container(color: AppColors.kgreyColor.withOpacity(0.1));
            },
          ),

          // Video indicator
          if (isVideo)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(Icons.videocam, color: Colors.white, size: 16.sp),
              ),
            ),
        ],
      ),
    );
  }
}
