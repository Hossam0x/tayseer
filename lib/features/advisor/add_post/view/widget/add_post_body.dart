import 'package:tayseer/core/enum/add_post_enum.dart';
import 'package:tayseer/core/utils/helper/picker_helper.dart';
import 'package:tayseer/core/widgets/pick_image_bottom_sheet.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/ai_assistant_banner.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/custom_profile_header.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_cubit.dart';
import 'package:tayseer/features/advisor/add_post/view_model/add_post_state.dart';
import 'package:tayseer/features/advisor/add_post/view_model/upload_post/upload_post_cubit.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_uploaded_video_preview.dart';
import 'package:tayseer/my_import.dart';

// add_post_body.dart

class AddPostBody extends StatelessWidget {
  const AddPostBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddPostCubit, AddPostState>(
      // ✅ مش محتاجين نسمع لـ addPostState خالص
      listenWhen: (previous, current) => false,
      listener: (context, state) {
        // ❌ شيلنا كل الـ loading / success / failure listeners
      },
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
                    // ────────────────────────────────────
                    // ✅ التعديل الرئيسي هنا
                    // ────────────────────────────────────
                    onPressed: isActive
                        ? () => _publishPost(context, cubit, state, postType)
                        : null,
                  ),
                ),
              ],
            ),

            // ─── باقي الـ body زي ما هو بالظبط ───
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomProfileHeader(
                    name: kCurrentUserData?.name ?? 'user',
                    initialSubtitle: context.tr('select_group'),
                    isVerified: false,
                    imageUrl: kCurrentUserData?.image ?? AssetsData.kUserImage,
                    groups: state.categories,
                    onGroupSelectedId: (group) =>
                        cubit.setSelectedCategoryId(group),
                  ),

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

                  // صور من الجاليري
                  if (state.selectedImages.isNotEmpty &&
                      postType != AddPostEnum.reel)
                    _buildGalleryImages(context, state, cubit),

                  // صور من الكاميرا
                  if (state.capturedImages.isNotEmpty &&
                      postType != AddPostEnum.reel)
                    _buildCapturedImages(context, state, cubit),

                  // فيديو
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

            bottomNavigationBar: _buildBottomBar(context, state, cubit),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────
  // ✅ الميثود الجديدة: نشر البوست + الرجوع للهوم
  // ──────────────────────────────────────────────
  void _publishPost(
    BuildContext context,
    AddPostCubit cubit,
    AddPostState state,
    AddPostEnum postType,
  ) {
    // 1. جمع بيانات البوست
    final content = state.draftText.trim();
    final categoryId = state.selectedCategoryId!;
    final images = List<File>.from(state.capturedImages);
    final video = state.capturedVideo;

    // 2. إطلاق الرفع في الخلفية عبر الـ UploadPostCubit
    getIt<UploadPostCubit>().startUploadWithRetry(
      categoryId: categoryId,
      postType: postType.name,
      content: content,
      images: images,
      video: video,
    );

    // 3. الرجوع للهوم فوراً
    context.pushNamedAndRemoveUntil(
      AppRouter.kAdvisorLayoutView,
      predicate: (route) => false,
    );
  }

  // ──────────────────────────────────────────────
  // باقي الـ Helper Methods (نفس الكود القديم)
  // ──────────────────────────────────────────────

  Widget _buildGalleryImages(
    BuildContext context,
    AddPostState state,
    AddPostCubit cubit,
  ) {
    return SizedBox(
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
                        return Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: HexColor('4d4d4d'),
                            ),
                          ),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(snap.data!, fit: BoxFit.cover),
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
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCapturedImages(
    BuildContext context,
    AddPostState state,
    AddPostCubit cubit,
  ) {
    return SizedBox(
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
                    child: Image.file(imageFile, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => cubit.removeCapturedImage(imageFile),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
          AiAssistantBanner(
            isLoading: state.isAiLoading,
            onTap: () => cubit.enhanceTextWithGemini(context),
          ),
          const Divider(color: Colors.grey, thickness: 0.5),
          Row(
            children: [
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
            ],
          ),
        ],
      ),
    );
  }

  bool _hasImages(AddPostState state) {
    return state.selectedImages.isNotEmpty || state.capturedImages.isNotEmpty;
  }

  bool _hasVideo(AddPostState state) {
    return state.selectedVideos.isNotEmpty || state.capturedVideo != null;
  }
}
