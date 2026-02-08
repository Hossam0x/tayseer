import 'package:tayseer/core/utils/helper/picker_helper.dart';
import 'package:tayseer/core/widgets/pick_image_bottom_sheet.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/ai_assistant_banner.dart';
import 'package:tayseer/features/advisor/add_post/view/widget/custom_profile_header.dart';
import 'package:tayseer/features/shared/auth/view/widget/custom_uploaded_video_preview.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/add_story_cubit/add_story_state.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/my_import.dart';

class AddStoryBody extends StatelessWidget {
  const AddStoryBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddStoryCubit, AddStoryState>(
      listener: (context, state) {
        if (state.addStoryState == CubitStates.loading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const CustomloadingApp(),
          );
        } else if (state.addStoryState == CubitStates.success) {
          context.pop(); // Dismiss loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              isSuccess: true,
              text: 'تم نشر القصة بنجاح',
            ),
          );
          // Refresh stories in the home
          getIt<StoriesCubit>().fetchStories();
          context.pop(); // Go back to profile
        } else if (state.addStoryState == CubitStates.failure) {
          context.pop(); // Dismiss loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              isSuccess: false,
              text: state.errorMessage ?? 'فشل نشر القصة',
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddStoryCubit>();
        final bool hasMedia =
            state.selectedImages.isNotEmpty ||
            state.capturedImages.isNotEmpty ||
            state.capturedVideo != null ||
            state.selectedVideos.isNotEmpty;
        final bool hasText = state.draftText.trim().isNotEmpty;
        final bool isActive = hasMedia || hasText;

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
                    onPressed: isActive ? () => cubit.createStory() : null,
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomProfileHeader(
                    name: kCurrentUserData?.name ?? '',
                    initialSubtitle:
                        'قصة جديدة', // Stories don't have categories
                    isVerified: true,
                  ),
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

                  // Captured Images
                  if (state.capturedImages.isNotEmpty)
                    _buildCapturedImages(context, state.capturedImages, cubit),

                  // Captured Video
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
                          final picker = MediaPickerController(
                            config: PickerConfig(
                              allowMultiple: false,
                              maxCount: 1,
                              requestType: RequestType.common,
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
                      IconButton(
                        icon: Icon(
                          Icons.photo_library_outlined,
                          color: HexColor('4d4d4d'),
                          size: 28,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => CustomGallerySheet(
                              config: PickerConfig(
                                allowMultiple: true,
                                maxCount: 10,
                                requestType: RequestType.common,
                              ),
                              onMediaSelected: (list) {
                                if (list.isEmpty) return;
                                for (var item in list) {
                                  if (item.type == AssetType.image) {
                                    cubit.addCapturedImage(item.file);
                                  } else if (item.type == AssetType.video) {
                                    cubit.addCapturedVideo(
                                      XFile(item.file.path),
                                    );
                                  }
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

  Widget _buildCapturedImages(
    BuildContext context,
    List<File> images,
    AddStoryCubit cubit,
  ) {
    return SizedBox(
      height: context.height * 0.25,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: images.length,
        itemBuilder: (_, index) {
          final file = images[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(file, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => cubit.removeCapturedImage(file),
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
}
