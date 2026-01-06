import 'dart:ui';
import 'dart:typed_data';

import 'package:tayseer/features/advisor/add_post/view/widget/gallery_segment_switch.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_cubit.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_state.dart';
import 'package:tayseer/my_import.dart';

class GalleryBottomSheet extends StatefulWidget {
  const GalleryBottomSheet({super.key, required this.cubit});
  final AddPostCubit cubit;

  @override
  State<GalleryBottomSheet> createState() => _GalleryBottomSheetState();
}

class _GalleryBottomSheetState extends State<GalleryBottomSheet> {
  late final ValueNotifier<Set<AssetEntity>> _tempSelectedNotifier;

  final Map<String, Uint8List> _thumbnailCache = {};

  bool _showAlbums = false;
  AssetPathEntity? _currentAlbum;
  List<AssetEntity> _currentAlbumImages = [];

  @override
  void initState() {
    super.initState();
    _tempSelectedNotifier = ValueNotifier<Set<AssetEntity>>(
      Set<AssetEntity>.from(widget.cubit.state.selectedImages),
    );
  }

  void _toggleTemp(AssetEntity image) {
    final current = Set<AssetEntity>.from(_tempSelectedNotifier.value);
    current.contains(image) ? current.remove(image) : current.add(image);
    _tempSelectedNotifier.value = current;
  }

  Future<Uint8List?> _getThumbnail(AssetEntity image) async {
    if (_thumbnailCache.containsKey(image.id)) {
      return _thumbnailCache[image.id];
    }

    final data = await image.thumbnailDataWithSize(
      const ThumbnailSize(200, 200),
    );

    if (data != null) {
      _thumbnailCache[image.id] = data;
    }

    return data;
  }

  @override
  void dispose() {
    _tempSelectedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = widget.cubit;

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<AddPostCubit, AddPostState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SafeArea(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                  child: Container(
                    height: context.height * 0.9,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.grey.withOpacity(0.1),
                          Colors.grey.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          context.tr('select_photos'),
                          style: Styles.textStyle16,
                        ),

                        /// HEADER
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  cubit.commitSelectedImages(
                                    _tempSelectedNotifier.value.toList(),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  context.tr('lode'),
                                  style: Styles.textStyle18SemiBold.copyWith(
                                    color: AppColors.kBlueColor,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: GallerySegmentSwitch(
                                  isAlbums: _showAlbums,
                                  onChanged: (v) {
                                    setState(() {
                                      _showAlbums = v;
                                      _currentAlbum = null;
                                      _currentAlbumImages.clear();
                                    });
                                  },
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.pop(),
                                child: Text(
                                  context.tr('close'),
                                  style: Styles.textStyle18SemiBold.copyWith(
                                    color: AppColors.kBlueColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// CONTENT
                        Expanded(
                          child: _showAlbums
                              ? _buildAlbumsView(state)
                              : _buildImagesGrid(state.galleryImages),
                        ),

                        if (_tempSelectedNotifier.value.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Show Selected (${_tempSelectedNotifier.value.length})',
                              style: Styles.textStyle18SemiBold.copyWith(
                                color: AppColors.kBlueColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlbumsView(AddPostState state) {
    if (_currentAlbum == null) {
      return ListView.builder(
        itemCount: state.galleryAlbums.length,
        itemBuilder: (_, i) {
          final album = state.galleryAlbums[i];
          return ListTile(
            title: Text(album.name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final images = await album.getAssetListPaged(page: 0, size: 200);
              setState(() {
                _currentAlbum = album;
                _currentAlbumImages = images;
              });
            },
          );
        },
      );
    }

    return _buildImagesGrid(_currentAlbumImages);
  }

  Widget _buildImagesGrid(List<AssetEntity> images) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: images.length,
      itemBuilder: (_, index) {
        final image = images[index];
        return GestureDetector(
          onTap: () => _toggleTemp(image),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _GalleryImage(image: image, getThumbnail: _getThumbnail),
              ValueListenableBuilder<Set<AssetEntity>>(
                valueListenable: _tempSelectedNotifier,
                builder: (_, selectedSet, __) {
                  if (!selectedSet.contains(image)) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    color: Colors.black.withOpacity(0.35),
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.check_circle,
                      color: AppColors.kBlueColor,
                      size: 22,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GalleryImage extends StatelessWidget {
  final AssetEntity image;
  final Future<Uint8List?> Function(AssetEntity) getThumbnail;

  const _GalleryImage({required this.image, required this.getThumbnail});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: getThumbnail(image),
      builder: (_, snap) {
        if (!snap.hasData) {
          return Container(color: Colors.grey.shade300);
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            snap.data!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          ),
        );
      },
    );
  }
}
