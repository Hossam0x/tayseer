import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/utils/helper/picker_helper.dart';
import 'package:tayseer/core/widgets/custtom_glass_button.dart';
import 'package:tayseer/core/widgets/pick_image_bottom_sheet.dart';
import 'package:tayseer/core/widgets/custom_video_and_edit/custom_uploaded_video_preview.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/style_gallery_grid.dart';
import 'package:tayseer/features/advisor/update_posts/view/widget/existing_video_review.dart';
import 'package:tayseer/features/advisor/update_posts/view/widget/update_profileا_header.dart';
import 'package:tayseer/features/advisor/update_posts/view_model/update_posts_cubit.dart';
import 'package:tayseer/features/advisor/update_posts/view_model/update_posts_state.dart';
import 'package:tayseer/my_import.dart';

class UpdatePostBody extends StatelessWidget {
  const UpdatePostBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UpdatePostCubit, UpdatePostState>(
      listenWhen: (previous, current) =>
          previous.updatePostState != current.updatePostState,
      listener: (context, state) {
        if (state.updatePostState == CubitStates.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('post_updated_successfully'),
              isSuccess: true,
            ),
          );
          Navigator.of(context).pop(true);
        }
        if (state.updatePostState == CubitStates.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: state.errorMessage ?? 'حدث خطأ',
              isError: true,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<UpdatePostCubit>();
        final postType = state.resolvedPostType;

        final hasCategory =
            state.selectedCategoryId != null &&
            state.selectedCategoryId!.isNotEmpty;

        final hasText = state.draftText.trim().isNotEmpty;

        // ✅ الزرار يتفعل بس لو في content + categoryId
        final bool isActive = hasCategory && hasText;

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
              centerTitle: true,
              title: Text(
                context.tr('edit_post'),
                style: Styles.textStyle16SemiBold,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: state.updatePostState == CubitStates.loading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: CustomloadingApp(),
                        )
                      : CustomBotton(
                          backGroundcolor: AppColors.kgreyColor,
                          useGradient: isActive,
                          height: 40,
                          width: context.responsiveWidth(100),
                          title: context.tr('save'),
                          onPressed: isActive ? () => cubit.updatePost() : null,
                        ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ════════════════════════════════
                  // Profile Header + Category
                  // ════════════════════════════════
                  UpdateProfileHeader(
                    cubit: cubit,
                    name: kCurrentUserData?.name ?? 'user',
                    initialSubtitle: _getCategoryName(state),
                    isVerified: false,
                    imageUrl: kCurrentUserData?.image ?? AssetsData.kUserImage,
                    groups: state.categories,
                    onGroupSelectedId: cubit.setSelectedCategoryId,
                  ),

                  // ════════════════════════════════
                  // Text Input
                  // ════════════════════════════════
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: cubit.contentController,
                      onChanged: cubit.updateText,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: postType == AddPostEnum.reel
                            ? context.tr('add_caption_optional')
                            : context.tr('you_like_to_share'),
                        border: InputBorder.none,
                        hintStyle: Styles.textStyle16.copyWith(
                          color: AppColors.kgreyColor,
                        ),
                      ),
                    ),
                  ),

                  // ════════════════════════════════
                  // ✅ الصور (السيرفر + الجديدة معاً)
                  // ════════════════════════════════
                  if ((state.existingImageUrls.isNotEmpty ||
                          state.capturedImages.isNotEmpty) &&
                      postType != AddPostEnum.reel)
                    StyleCombinedGrid(
                      existingImageUrls: state.existingImageUrls,
                      onRemoveExisting: cubit.removeExistingImage,
                      capturedImages: state.capturedImages,
                      onRemoveCaptured: cubit.removeCapturedImage,
                      galleryImages: const [],
                      onRemoveGallery: (_) {},
                    ),

                  // ════════════════════════════════
                  // ✅ فيديو موجود من السيرفر
                  // ════════════════════════════════
                  if (state.existingVideoUrl != null &&
                      state.capturedVideo == null)
                    ExistingVideoPreview(
                      videoUrl: state.existingVideoUrl!,
                      onRemove: cubit.removeExistingVideo,
                      onVideoEdited: (editedVideo) {
                        cubit.removeExistingVideo();
                        cubit.addCapturedVideo(editedVideo);
                      },
                    ),

                  // ════════════════════════════════
                  // ✅ فيديو جديد
                  // ════════════════════════════════
                  if (state.capturedVideo != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomUploadedVideoPreview(
                        key: ValueKey(state.capturedVideo!.path),
                        height: 0.7,
                        width: 0.9,
                        video: state.capturedVideo!,
                        onInitialized: () {},
                        onRemove: cubit.removeCapturedVideo,
                        showEditButton: true,
                        onVideoEdited: cubit.updateCapturedVideo,
                      ),
                    ),
                ],
              ),
            ),
            bottomNavigationBar: _buildBottomBar(context, state, cubit),
          ),
        );
      },
    );
  }

  // ✅ اسم الكاتيجوري الحالي
  String _getCategoryName(UpdatePostState state) {
    if (state.selectedCategoryId == null) return '';
    final match = state.categories.where(
      (c) => c.id == state.selectedCategoryId,
    );
    return match.isNotEmpty ? match.first.name : '';
  }

  Widget _buildBottomBar(
    BuildContext context,
    UpdatePostState state,
    UpdatePostCubit cubit,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CusttomGlassButton(
            text: context.tr('generate_ai_content'),
            showIcon: state.isAiLoading,
            onTap: () => cubit.enhanceTextWithGemini(context),
          ),
          const Divider(color: Colors.grey, thickness: 0.5),
          Row(
            children: [
              // ════════════════════════════════
              // 📷 Camera
              // ════════════════════════════════
              IconButton(
                icon: Icon(
                  Icons.camera_alt_outlined,
                  color: _hasVideo(state)
                      ? Colors.grey.shade400
                      : HexColor('4d4d4d'),
                  size: 28,
                ),
                onPressed: _hasVideo(state)
                    ? null
                    : () async {
                        final picker = MediaPickerController(
                          config: PickerConfig(
                            allowMultiple: false,
                            maxCount: 1,
                            requestType: RequestType.image,
                          ),
                        );
                        final SelectedMedia? picked = await picker
                            .pickFromCamera();
                        if (picked != null && picked.type == AssetType.image) {
                          cubit.addCapturedImage(picked.file);
                        }
                      },
              ),

              // ════════════════════════════════
              // 🖼️ Gallery
              // ════════════════════════════════
              GestureDetector(
                onTap: _hasVideo(state)
                    ? null
                    : () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => CustomGallerySheet(
                            config: PickerConfig(
                              allowMultiple: true,
                              maxCount: 10,
                              requestType: RequestType.image,
                            ),
                            onMediaSelected: (list) {
                              if (list.isEmpty) return;
                              for (var item in list) {
                                if (item.type == AssetType.image) {
                                  cubit.addCapturedImage(item.file);
                                }
                              }
                            },
                          ),
                        );
                      },
                child: Opacity(
                  opacity: _hasVideo(state) ? 0.4 : 1.0,
                  child: AppImage(AssetsData.kopenGalIcon),
                ),
              ),
              const SizedBox(width: 8),

              // ════════════════════════════════
              // 🎥 Video
              // ════════════════════════════════
              IconButton(
                icon: Icon(
                  Icons.video_library_outlined,
                  color: _hasImages(state)
                      ? Colors.grey.shade400
                      : state.capturedVideo != null
                      ? AppColors.kprimaryColor
                      : HexColor('4d4d4d'),
                  size: 28,
                ),
                onPressed: _hasImages(state) || state.capturedVideo != null
                    ? null
                    : () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => CustomGallerySheet(
                          config: PickerConfig(
                            allowMultiple: false,
                            maxCount: 1,
                            requestType: RequestType.video,
                          ),
                          onMediaSelected: (list) {
                            if (list.isEmpty) return;
                            final videoItem = list.first;
                            if (videoItem.type == AssetType.video) {
                              cubit.addCapturedVideo(
                                XFile(videoItem.file.path),
                              );
                            }
                          },
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasImages(UpdatePostState state) =>
      state.capturedImages.isNotEmpty || state.existingImageUrls.isNotEmpty;

  bool _hasVideo(UpdatePostState state) =>
      state.capturedVideo != null || state.existingVideoUrl != null;
}
