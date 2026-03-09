import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/utils/helper/picker_helper.dart';
import 'package:tayseer/core/widgets/custtom_glass_button.dart';
import 'package:tayseer/core/widgets/pick_image_bottom_sheet.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/custom_profile_header.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/style_gallery_grid.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_cubit.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_state.dart';
import 'package:tayseer/features/advisor/add_post/view_model/upload_post/upload_post_cubit.dart';
import 'package:tayseer/core/widgets/custom_video_and_edit/custom_uploaded_video_preview.dart';
import 'package:tayseer/my_import.dart';

class AddPostBody extends StatelessWidget {
  const AddPostBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddPostCubit, AddPostState>(
      listenWhen: (previous, current) => false,
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = context.read<AddPostCubit>();
        final postType = state.resolvedPostType;

        final hasCategory =
            state.selectedCategoryId != null &&
            state.selectedCategoryId!.isNotEmpty;

        final hasImage =
            state.selectedImages.isNotEmpty || state.capturedImages.isNotEmpty;
        final hasVideo =
            state.selectedVideos.isNotEmpty || state.capturedVideo != null;
        final hasText = state.draftText.trim().isNotEmpty;

        final bool isActive;
        if (postType == AddPostEnum.reel) {
          isActive = hasCategory && hasVideo;
        } else {
          isActive = hasCategory && (hasText || hasImage);
        }

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
                        ? () => _publishPost(context, cubit, state, postType)
                        : null,
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ════════════════════════════════════════════
                  // Profile Header + Category
                  // ════════════════════════════════════════════
                  CustomProfileHeader(
                    cubit: cubit,
                    name: kCurrentUserData?.name ?? 'user',
                    initialSubtitle: context.tr('select_group'),
                    isVerified: false,
                    imageUrl: kCurrentUserData?.image ?? AssetsData.kUserImage,
                    groups: state.categories,
                    onGroupSelectedId: (group) =>
                        cubit.setSelectedCategoryId(group),
                  ),

                  // ════════════════════════════════════════════
                  // Text Input
                  // ════════════════════════════════════════════
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

                  // ════════════════════════════════════════════
                  // ✅ صور (Facebook Style Grid) - كاميرا + جاليري معاً
                  // ════════════════════════════════════════════
                  if ((state.capturedImages.isNotEmpty ||
                          state.selectedImages.isNotEmpty) &&
                      postType != AddPostEnum.reel)
                    StyleCombinedGrid(
                      capturedImages: state.capturedImages,
                      galleryImages: state.selectedImages,
                      onRemoveCaptured: (image) =>
                          cubit.removeCapturedImage(image),
                      onRemoveGallery: (image) => cubit.removeSelected(image),
                    ),

                  // ════════════════════════════════════════════
                  // فيديو (زي ما هو - بدون تعديل)
                  // ════════════════════════════════════════════
                  if (state.capturedVideo != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CustomUploadedVideoPreview(
                        key: ValueKey(state.capturedVideo!.path),
                        height: 0.7,
                        width: 0.9,
                        video: state.capturedVideo!,
                        onInitialized: () {},
                        onRemove: () => cubit.removeCapturedVideo(),
                        showEditButton: true,
                        onVideoEdited: (editedVideo) {
                          cubit.updateCapturedVideo(editedVideo);
                        },
                      ),
                    ),
                ],
              ),
            ),

            // ════════════════════════════════════════════
            // Bottom Bar
            // ════════════════════════════════════════════
            bottomNavigationBar: _buildBottomBar(context, state, cubit),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // ✅ نشر البوست + الرجوع للهوم
  // ──────────────────────────────────────────────
  void _publishPost(
    BuildContext context,
    AddPostCubit cubit,
    AddPostState state,
    AddPostEnum postType,
  ) {
    final content = state.draftText.trim();
    final categoryId = state.selectedCategoryId!;
    final images = List<File>.from(state.capturedImages);
    final video = state.capturedVideo;

    getIt<UploadPostCubit>().startUploadWithRetry(
      categoryId: categoryId,
      postType: postType.name,
      content: content,
      images: images,
      video: video,
    );

    context.pushNamedAndRemoveUntil(
      AppRouter.kAdvisorLayoutView,
      predicate: (route) => false,
    );
  }

  // ──────────────────────────────────────────────
  // Bottom Bar
  // ──────────────────────────────────────────────
  Widget _buildBottomBar(
    BuildContext context,
    AddPostState state,
    AddPostCubit cubit,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CusttomGlassButton(
            text: context.tr('generate_ai_content'),
            showIcon: state.isAiLoading,
            onTap: () {
              cubit.enhanceTextWithGemini(context);
            },
          ),
          const Divider(color: Colors.grey, thickness: 0.5),
          Row(
            children: [
              // ════════════════════════════════════════
              // 📷 Camera Button
              // ════════════════════════════════════════
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

              // ════════════════════════════════════════
              // 🖼️ Gallery Button
              // ════════════════════════════════════════
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

              // ════════════════════════════════════════
              // 🎥 Video Button
              // ════════════════════════════════════════
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
                onPressed: _hasImages(state)
                    ? null
                    : state.capturedVideo != null
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
              Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.event_outlined,
                  color: HexColor('4d4d4d'),
                  size: 28,
                ),
                onPressed: () {
                  context.pushNamed(AppRouter.kCreatEventView);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────
  bool _hasImages(AddPostState state) {
    return state.selectedImages.isNotEmpty || state.capturedImages.isNotEmpty;
  }

  bool _hasVideo(AddPostState state) {
    return state.selectedVideos.isNotEmpty || state.capturedVideo != null;
  }
}
