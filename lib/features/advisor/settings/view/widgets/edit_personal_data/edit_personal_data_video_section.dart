import 'package:chewie/chewie.dart';
import 'package:tayseer/core/widgets/advisor_video_player/advisor_video_player_widget.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_cubit.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_state.dart';
import 'package:tayseer/features/advisor/settings/view/cubit/edit_personal_data/edit_personal_data_ui_cubit.dart';
import 'package:tayseer/my_import.dart';

class EditPersonalDataVideoSection extends StatelessWidget {
  final EditPersonalDataCubit cubit;
  final EditPersonalDataState state;
  final ChewieController? chewieController;
  final VoidCallback onPickVideo;
  final VoidCallback onRemoveVideo;

  const EditPersonalDataVideoSection({
    super.key,
    required this.cubit,
    required this.state,
    required this.chewieController,
    required this.onPickVideo,
    required this.onRemoveVideo,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditPersonalDataUiCubit, EditPersonalDataUiState>(
      builder: (context, uiState) {
        final videoFile = state.videoFile;
        final videoPreviewUrl = state.videoPreviewUrl;
        final isVideoDeleted = state.currentData.video == "";

        final hasVideo =
            videoFile != null ||
            (!isVideoDeleted &&
                videoPreviewUrl != null &&
                videoPreviewUrl.isNotEmpty &&
                (videoPreviewUrl.startsWith('http') ||
                    chewieController != null));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (uiState.isVideoLoading)
              _VideoLoadingIndicator(progress: uiState.uploadProgress)
            else if (hasVideo)
              _VideoPlayer(
                videoFile: videoFile,
                videoPreviewUrl: videoPreviewUrl,
                chewieController: chewieController,
                onRemove: onRemoveVideo,
              )
            else
              _VideoPickerPlaceholder(
                isVideoDeleted: isVideoDeleted,
                onTap: onPickVideo,
              ),
            Gap(8.h),
            Text(
              context.tr("video_size_limit_10mb"),
              style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
            ),
          ],
        );
      },
    );
  }
}

class _VideoLoadingIndicator extends StatelessWidget {
  final double progress;
  const _VideoLoadingIndicator({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250.h,
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60.w,
              height: 60.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    color: AppColors.primary500,
                    backgroundColor: AppColors.primary100,
                    strokeWidth: 4,
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: Styles.textStyle14.copyWith(
                      color: AppColors.primary500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Gap(16.h),
            Text(
              context.tr("loading_video"),
              style: Styles.textStyle14.copyWith(color: AppColors.secondary600),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoPlayer extends StatelessWidget {
  final File? videoFile;
  final String? videoPreviewUrl;
  final ChewieController? chewieController;
  final VoidCallback onRemove;

  const _VideoPlayer({
    required this.videoFile,
    required this.videoPreviewUrl,
    required this.chewieController,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary100),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              if (videoFile != null)
                Container(
                  width: double.infinity,
                  height: 250.h,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child:
                      chewieController != null &&
                          chewieController!
                              .videoPlayerController
                              .value
                              .isInitialized
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Chewie(controller: chewieController!),
                        )
                      : Center(
                          child: Icon(
                            Icons.video_library_rounded,
                            size: 50.w,
                            color: Colors.white70,
                          ),
                        ),
                )
              else if (videoPreviewUrl != null &&
                  videoPreviewUrl!.startsWith('http'))
                SizedBox(
                  height: 250.h,
                  child: AdvisorVideoPlayerWidget(
                    videoUrl: videoPreviewUrl!,
                    showFullScreenButton: true,
                  ),
                ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.primary500,
                      size: 18.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (videoFile != null)
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16.sp,
                    color: AppColors.primary500,
                  ),
                  Gap(4.w),
                  Text(
                    context.tr("new_video_selected"),
                    style: Styles.textStyle12.copyWith(
                      color: AppColors.secondary600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _VideoPickerPlaceholder extends StatelessWidget {
  final bool isVideoDeleted;
  final VoidCallback onTap;

  const _VideoPickerPlaceholder({
    required this.isVideoDeleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 250.h,
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppImage(AssetsData.kvideoIcon, width: 60.w, height: 60.h),
            Gap(12.h),
            Text(
              textAlign: TextAlign.center,
              isVideoDeleted
                  ? context.tr("video_deleted_click_to_add")
                  : context.tr("click_to_upload_intro_video"),
              style: Styles.textStyle16.copyWith(
                color: isVideoDeleted
                    ? AppColors.kRedColor
                    : AppColors.secondary600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
