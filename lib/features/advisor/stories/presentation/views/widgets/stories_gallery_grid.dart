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
          return _buildShimmerGrid();
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
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.0,
            ),
            itemCount: state.galleryAssets.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCameraItem(context);
              }
              final asset = state.galleryAssets[index - 1];
              return _GalleryItem(
                asset: asset,
                onTap: () =>
                    context.read<AddStoryCubit>().selectAsset(asset, context),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCameraItem(BuildContext context) {
    return GestureDetector(
      onTap: widget.onCameraTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: widget.isInitialized && widget.controller != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CameraPreview(widget.controller!),
                  ),
                ),
              )
            : Icon(Icons.camera_alt, size: 30.w, color: AppColors.kprimaryColor),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<Uint8List?>(
              future: _thumbnailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  );
                }
                return Container(color: Colors.grey.withOpacity(0.2));
              },
            ),

            // Video indicator
            if (isVideo)
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
