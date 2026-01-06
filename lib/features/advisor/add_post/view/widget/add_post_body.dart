import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/custom_profile_header.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/gallery_bottom_sheet.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/gif_bottom_sheet.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_cubit.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_state.dart';
import 'package:tayseer/my_import.dart';

class AddPostBody extends StatelessWidget {
  const AddPostBody({super.key, required this.postType});
  final AddPostEnum postType;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddPostCubit, AddPostState>(
      listenWhen: (previous, current) =>
          previous.addPostState != current.addPostState,
      listener: (context, state) {
        if (state.addPostState == CubitStates.loading) {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const CustomloadingApp(),
          );
        } else if (state.addPostState == CubitStates.success) {
          FocusScope.of(context).unfocus();
          context.pop(); // Dismiss loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              isSuccess: true,
              text: context.tr('post_published_successfully'),
            ),
          );
        } else if (state.addPostState == CubitStates.failure) {
          context.pop(); // Dismiss loading dialog if shown
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              isSuccess: false,
              text:
                  state.errorMessage ??
                  context.tr('failed_to_publish_post_please_try_again'),
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddPostCubit>();

        final hasText = state.draftText.trim().isNotEmpty;
        final hasImages =
            state.selectedImages.isNotEmpty ||
            state.capturedImages.isNotEmpty ||
            state.selectedVideos.isNotEmpty ||
            state.selectedGifs.isNotEmpty;
        // require a selected category id before enabling publish
        final hasCategory =
            state.selectedCategoryId != null &&
            state.selectedCategoryId!.isNotEmpty;
        final isActive = (hasText || hasImages) && hasCategory;

        return CustomBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => context.pop(),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomBotton(
                    backGroundcolor: AppColors.kgreyColor,
                    useGradient: isActive,
                    height: 40,
                    width: context.responsiveWidth(100),
                    title: context.tr('to_publish'),
                    onPressed: isActive
                        ? () => cubit.createPost(
                            categoryId: state.selectedCategoryId!,
                            postType: "post",
                          )
                        : null,
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomProfileHeader(
                    name: 'Anna Mary',
                    initialSubtitle: context.tr('select_group'),
                    imageUrl:
                        'https://pbs.twimg.com/profile_images/1519640426956963840/zgFOntNM_400x400.jpg',
                    isVerified: true,
                    groups: state.categories,
                    onGroupSelectedId: (group) =>
                        cubit.setSelectedCategoryId(group),
                  ),
                  // TextField
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: cubit.contentController,
                      onChanged: cubit.updateText,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: context.tr('you_like_to_share'),
                        border: InputBorder.none,
                        hintStyle: Styles.textStyle16.copyWith(
                          color: AppColors.kgreyColor,
                        ),
                      ),
                    ),
                  ),

                  // Selected Images من الجاليري
                  if (state.selectedImages.isNotEmpty)
                    SizedBox(
                      height: context.height * 0.25,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: state.selectedImages.length,
                        itemBuilder: (_, index) {
                          final image = state.selectedImages[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: FutureBuilder(
                                    future: image.thumbnailDataWithSize(
                                      const ThumbnailSize(300, 300),
                                    ),
                                    builder: (_, snap) {
                                      if (!snap.hasData) {
                                        return Container(
                                          color: Colors.grey.shade300,
                                        );
                                      }
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          snap.data!,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () => cubit.removeSelected(image),
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.black54,
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // 🔥 Captured Images من الكاميرا
                  if (state.capturedImages.isNotEmpty)
                    SizedBox(
                      height: context.height * 0.25,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: state.capturedImages.length,
                        itemBuilder: (_, index) {
                          final imageFile = state.capturedImages[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      imageFile,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () =>
                                        cubit.removeCapturedImage(imageFile),
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.black54,
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Selected GIFs
                  if (state.selectedGifs.isNotEmpty)
                    SizedBox(
                      height: context.height * 0.18,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: state.selectedGifs.length,
                        itemBuilder: (_, index) {
                          final gifUrl = state.selectedGifs[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      gifUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () =>
                                        cubit.removeSelectedGif(gifUrl),
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.black54,
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Selected Videos
                  if (state.selectedVideos.isNotEmpty)
                    SizedBox(
                      height: context.height * 0.18,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: state.selectedVideos.length,
                        itemBuilder: (_, index) {
                          final video = state.selectedVideos[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: FutureBuilder(
                                    future: video.thumbnailDataWithSize(
                                      const ThumbnailSize(300, 300),
                                    ),
                                    builder: (_, snap) {
                                      if (!snap.hasData)
                                        return Container(
                                          color: Colors.grey.shade300,
                                        );
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.memory(
                                          snap.data!,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const Positioned(
                                  left: 8,
                                  top: 8,
                                  child: Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white70,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () =>
                                        cubit.removeSelectedVideo(video),
                                    child: const CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.black54,
                                      child: Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Action icons at bottom
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Divider(color: Colors.grey, thickness: 0.5),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: HexColor('4d4d4d'),
                          size: 28,
                        ),
                        onPressed: () {
                          context.pushNamed(
                            AppRouter.kCameraView,
                            arguments: {'cubit': cubit},
                          );
                        },
                      ),
                      GestureDetector(
                        child: AppImage(AssetsData.kopenGalIcon),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            barrierColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => GalleryBottomSheet(cubit: cubit),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        child: AppImage(AssetsData.kGifIcon),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            barrierColor: Colors.transparent,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => GifBottomSheet(cubit: cubit),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
