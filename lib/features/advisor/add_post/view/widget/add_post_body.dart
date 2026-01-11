import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/utils/helper/picker_helper.dart';
import 'package:tayseer/core/widgets/pick_image_bottom_sheet.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/ai_assistant_banner.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/custom_profile_header.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_cubit.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_state.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_uploaded_video_preview.dart';
import 'package:tayseer/my_import.dart';

class AddPostBody extends StatelessWidget {
  const AddPostBody({super.key, required this.postType});
  final AddPostEnum? postType;
  @override
  Widget build(BuildContext context) {
    // debugPrint('AddPostBody build called with postType: ${postType?.name}');
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
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              isSuccess: true,
              text: context.tr('post_published_successfully'),
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            context.pushNamedAndRemoveUntil(
              AppRouter.kAdvisorLayoutView,
              predicate: (route) => false,
            );
          });
        } else if (state.addPostState == CubitStates.failure) {
          context.pop(); // Dismiss loading dialog
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
        // require a selected category id before enabling publish
        final hasCategory =
            state.selectedCategoryId != null &&
            state.selectedCategoryId!.isNotEmpty;

        // Determine required media based on postType
        final bool requiresImage = postType == AddPostEnum.post;
        final bool requiresVideo =
            postType == AddPostEnum.video || postType == AddPostEnum.reel;

        final hasImage =
            state.selectedImages.isNotEmpty || state.capturedImages.isNotEmpty;
        final hasVideo =
            state.selectedVideos.isNotEmpty || state.capturedVideo != null;

        // If postType requires specific media, enforce it.
        // For `post` we allow text-only posts (text + category) without images/videos.
        final bool hasRequiredMedia = requiresImage
            ? (hasImage || state.draftText.trim().isNotEmpty)
            : requiresVideo
            ? hasVideo
            : (hasImage || hasVideo || state.draftText.trim().isNotEmpty);

        final isActive = hasCategory && hasRequiredMedia;

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
                            postType: postType?.name ?? 'post',
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

                  // Captured Video (single) from Camera or CustomGallerySheet
                  if (state.capturedVideo != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomUploadedVideoPreview(
                        height: 0.3,
                        width: 0.9,
                        key: ValueKey(state.capturedVideo!.path),
                        video: state.capturedVideo!,
                        onInitialized: () {},
                        onRemove: () => cubit.removeCapturedVideo(),
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
                  AiAssistantBanner(
                    isLoading: state.isAiLoading,
                    onTap: () => cubit.enhanceTextWithGemini(context),
                  ),
                  Divider(color: Colors.grey, thickness: 0.5),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt_outlined,
                          color: HexColor('4d4d4d'),
                          size: 28,
                        ),
                        onPressed: () async {
                          // choose camera type based on postType
                          final reqType = postType == AddPostEnum.post
                              ? RequestType.image
                              : (postType == AddPostEnum.video ||
                                    postType == AddPostEnum.reel)
                              ? RequestType.video
                              : RequestType.common;

                          final picker = MediaPickerController(
                            config: PickerConfig(
                              allowMultiple: false,
                              maxCount: 1,
                              requestType: reqType,
                            ),
                          );
                          final SelectedMedia? picked = await picker
                              .pickFromCamera();
                          if (picked != null) {
                            if (picked.type == AssetType.image) {
                              cubit.addCapturedImage(picked.file);
                            } else if (picked.type == AssetType.video) {
                              cubit.addCapturedVideo(XFile(picked.file.path));
                            }
                          }
                        },
                      ),
                      GestureDetector(
                        child: AppImage(AssetsData.kopenGalIcon),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => CustomGallerySheet(
                              config: PickerConfig(
                                allowMultiple: true,
                                maxCount: 10,
                                requestType: postType == AddPostEnum.post
                                    ? RequestType.image
                                    : postType == AddPostEnum.video
                                    ? RequestType.video
                                    : postType == AddPostEnum.reel
                                    ? RequestType.video
                                    : RequestType.common,
                              ),
                              onMediaSelected: (list) {
                                if (list.isEmpty) return;

                                final List<File> imageFiles = [];
                                final List<File> videoFiles = [];

                                for (var item in list) {
                                  if (item.type == AssetType.video) {
                                    // log('Video selected: ${item.file.path}');
                                    videoFiles.add(item.file);
                                  } else if (item.type == AssetType.image) {
                                    // log('Image selected: ${item.file.path}');
                                    imageFiles.add(item.file);
                                  }
                                }

                                // Commit to cubit: captured images/videos
                                if (imageFiles.isNotEmpty) {
                                  for (final f in imageFiles) {
                                    cubit.addCapturedImage(f);
                                  }
                                }

                                if (videoFiles.isNotEmpty) {
                                  // Only allow a single captured video — take the first one
                                  cubit.addCapturedVideo(
                                    XFile(videoFiles.first.path),
                                  );
                                }
                              },
                            ),
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
