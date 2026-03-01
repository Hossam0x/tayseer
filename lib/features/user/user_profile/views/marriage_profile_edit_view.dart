import 'package:device_info_plus/device_info_plus.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:tayseer/core/constant/marriage_constants.dart';
import 'package:tayseer/core/widgets/custom_video_and_edit/custom_uploaded_video_preview.dart';
import 'package:tayseer/core/widgets/full_screen_image_view.dart';
import 'package:tayseer/features/user/marriage/view/widget/video_section.dart';
import 'package:tayseer/features/user/questions/view/widget/image_guidelines_bottom_sheet.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/audioWidget.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/image_slot_card.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_field_selection_view.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/voiceWidget.dart';
import 'package:tayseer/my_import.dart';
import 'package:file_picker/file_picker.dart';

// ignore: must_be_immutable
class MarriageProfileEditView extends StatefulWidget {
  MarriageProfileEditView({
    super.key,
    required this.cubit,
    required this.profile,
    required this.state,
    required this.selectedTabIndex,
    required this.maxImages,
    this.onTabChanged,
    this.scrollToSection,
  });

  final int maxImages;
  final MarriageProfileCubit cubit;
  final MarriageUserProfileModel profile;
  final MarriageProfileState state;
  late int selectedTabIndex;
  final Function(int)? onTabChanged;
  final String? scrollToSection;

  @override
  State<MarriageProfileEditView> createState() =>
      _MarriageProfileEditViewState();
}

class _MarriageProfileEditViewState extends State<MarriageProfileEditView> {
  bool _isRecordingInPlace = false;
  bool _isDragMode = false;

  final GlobalKey _imagesKey = GlobalKey();
  final GlobalKey _videoKey = GlobalKey();
  final GlobalKey _audioKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.scrollToSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSection(widget.scrollToSection!);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String section) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 400), () {
        GlobalKey? targetKey;
        switch (section) {
          case 'images':
            targetKey = _imagesKey;
            break;
          case 'video':
            targetKey = _videoKey;
            break;
          case 'audio':
            targetKey = _audioKey;
            break;
        }
        if (targetKey?.currentContext != null) {
          Scrollable.ensureVisible(
            targetKey!.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        } else {
          debugPrint('⚠️ Retrying scroll for $section...');
          Future.delayed(const Duration(milliseconds: 200), () {
            if (targetKey?.currentContext != null)
              Scrollable.ensureVisible(
                targetKey!.currentContext!,
                alignment: 0.1,
              );
          });
        }
      });
    });
  }

  String _formatHobbiesForDisplay(dynamic hobbyKeys, BuildContext context) {
    final List<String> hobbiesList = MarriageConstants.parseKeysFromRaw(
      hobbyKeys,
    );
    if (hobbiesList.isEmpty) return '';
    return hobbiesList
        .map((key) => '${MarriageConstants.getEmoji(key)} ${context.tr(key)}')
        .join(', ');
  }

  String _translateValue(String value, BuildContext context) {
    if (value.isEmpty || value == 'اختر' || value == 'select')
      return context.tr('select');
    final translated = context.tr(value);
    if (translated == value && !value.contains(' ')) return value;
    return translated;
  }

  // ════════════════════════════════════════════════════════════════
  // ✅ Open image in FullScreen
  // ════════════════════════════════════════════════════════════════
  void _openFullScreen(BuildContext context, String imageUrl, String heroTag) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageView(
          imageUrl: imageUrl,
          heroTag: heroTag,
          userName: context.tr('my_profile'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      cacheExtent: 3000,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Gap(24.h),
              _buildPersonalInfoSection(context, widget.cubit, widget.profile),
              Gap(20.h),
              Container(
                key: _imagesKey,
                child: _buildImagesSection(
                  context,
                  widget.cubit,
                  widget.profile,
                ),
              ),
              Gap(24.h),
              _buildProfessionalInfoSection(
                context,
                widget.cubit,
                widget.profile,
              ),
              Gap(24.h),
              Container(key: _videoKey, child: _buildVideoSection(context)),
              Gap(24.h),
              Container(key: _audioKey, child: _buildAudioSection(context)),
              Gap(24.h),
              _buildFamilyAndPreferencesSection(
                context,
                widget.cubit,
                widget.profile,
              ),
              Gap(24.h),
              _buildGoalsSection(context, widget.cubit, widget.profile),
              Gap(24.h),
              _buildKnowMeMoreSection(context, widget.cubit, widget.profile),
              Gap(32.h),
              _buildSaveButton(context, widget.cubit, widget.state),
              Gap(100.h),
            ]),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ✅ IMAGES SECTION
  // ════════════════════════════════════════════════════════════════
  Widget _buildImagesSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    final serverImages = profile.userMedia?.images ?? [];
    final serverSingleImage = profile.userMedia?.singleImage;
    final pendingSingle = widget.state.pendingSingleImage;
    final pendingImgs = widget.state.pendingImages;
    final deletedSingleUrl = widget.state.deletedSingleImageUrl;

    final displaySingleUrl = deletedSingleUrl != null
        ? null
        : serverSingleImage;
    final hasSingleToShow = pendingSingle != null || displaySingleUrl != null;

    final filteredServerImages = serverImages
        .where((url) => !widget.state.deletedImageUrls.contains(url))
        .toList();
    final allDisplayImages = [
      ...filteredServerImages,
      ...pendingImgs.map((f) => f.path),
    ];
    final secondaryImages = allDisplayImages.length > 4
        ? allDisplayImages.sublist(0, 4)
        : allDisplayImages;
    final totalCount = (hasSingleToShow ? 1 : 0) + allDisplayImages.length;
    final canDrag = secondaryImages.length > 1;

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${context.tr('images_count')} ( $totalCount ${context.tr('images_count')})',
                style: Styles.textStyle18Meduim,
              ),
              Row(
                children: [
                  if (pendingSingle != null || pendingImgs.isNotEmpty)
                    _buildPendingBadge(
                      context,
                      context.tr('images_pending_save'),
                    ),
                  if (canDrag) ...[
                    Gap(8.w),
                    GestureDetector(
                      onTap: () => setState(() => _isDragMode = !_isDragMode),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _isDragMode
                              ? AppColors.primary300.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: _isDragMode
                                ? AppColors.primary300
                                : Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isDragMode
                                  ? Icons.check_rounded
                                  : Icons.swap_vert_rounded,
                              size: 14.w,
                              color: _isDragMode
                                  ? AppColors.primary300
                                  : Colors.grey,
                            ),
                            Gap(4.w),
                            Text(
                              _isDragMode
                                  ? context.tr('done')
                                  : context.tr('reorder'),
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: _isDragMode
                                    ? AppColors.primary300
                                    : Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          if (_isDragMode) ...[
            Gap(8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary50.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 14.w,
                    color: AppColors.primary400,
                  ),
                  Gap(6.w),
                  Text(
                    context.tr('long_press_to_drag'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.primary400,
                    ),
                  ),
                ],
              ),
            ),
          ],

          Gap(12.h),

          _isDragMode
              ? _buildDragGrid(
                  context,
                  cubit,
                  profile,
                  displaySingleUrl: displaySingleUrl,
                  pendingSingle: pendingSingle,
                  hasSingleToShow: hasSingleToShow,
                  secondaryImages: secondaryImages,
                  filteredServerImages: filteredServerImages,
                  allDisplayImages: allDisplayImages,
                )
              : _buildNormalGrid(
                  context,
                  cubit,
                  profile,
                  displaySingleUrl: displaySingleUrl,
                  pendingSingle: pendingSingle,
                  hasSingleToShow: hasSingleToShow,
                  secondaryImages: secondaryImages,
                  filteredServerImages: filteredServerImages,
                  allDisplayImages: allDisplayImages,
                ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ✅ NORMAL GRID — with FullScreenImageView on tap
  // ════════════════════════════════════════════════════════════════
  Widget _buildNormalGrid(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile, {
    required String? displaySingleUrl,
    required File? pendingSingle,
    required bool hasSingleToShow,
    required List<String> secondaryImages,
    required List<String> filteredServerImages,
    required List<String> allDisplayImages,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.7,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          // ── SLOT 0: Main Image ──
          if (index == 0) {
            return GestureDetector(
              // ✅ tap = open fullscreen (only if image exists)
              onTap: hasSingleToShow && displaySingleUrl != null
                  ? () =>
                        _openFullScreen(context, displaySingleUrl, 'main_image')
                  : !hasSingleToShow
                  ? () => _pickSingleImage(context, cubit, profile)
                  : null,
              child: ImageSlotCard(
                imageUrl: displaySingleUrl,
                localFile: pendingSingle,
                isMain: true,
                onTap: null, // handled by GestureDetector above
                onRemove: hasSingleToShow
                    ? () => _removeSingleImage(context, cubit)
                    : null,
              ),
            );
          }

          // ── SLOT 5: Guidelines ──
          if (index == 5) {
            return GestureDetector(
              onTap: () => ImageGuidelinesBottomSheet.show(
                context,
                onNext: () => context.pop(),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: context.height * 0.06),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 28,
                      color: AppColors.kscandryTextColor,
                    ),
                    SizedBox(height: 8),
                    Text(
                      context.tr('photo_guidelines'),
                      textAlign: TextAlign.center,
                      style: Styles.textStyle16.copyWith(
                        color: AppColors.kscandryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── SLOTS 1-4: Secondary Images ──
          final listIndex = index - 1;
          if (listIndex < secondaryImages.length) {
            final isLocal = listIndex >= filteredServerImages.length;
            final pendingIndex = listIndex - filteredServerImages.length;
            final imageUrl = isLocal ? null : secondaryImages[listIndex];
            final heroTag = 'secondary_image_$listIndex';

            return GestureDetector(
              // ✅ tap = open fullscreen (only server images, not local pending)
              onTap: !isLocal && imageUrl != null
                  ? () => _openFullScreen(context, imageUrl, heroTag)
                  : null,
              child: ImageSlotCard(
                imageUrl: imageUrl,
                localFile: isLocal
                    ? widget.state.pendingImages[pendingIndex]
                    : null,
                isMain: false,
                onTap: null, // handled by GestureDetector above
                onRemove: () {
                  if (isLocal) {
                    cubit.removePendingImage(pendingIndex);
                  } else {
                    _removeImage(
                      context,
                      cubit,
                      listIndex,
                      filteredServerImages,
                    );
                  }
                },
              ),
            );
          }

          // ── Empty slot ──
          return ImageSlotCard(
            imageUrl: null,
            isMain: false,
            onTap: allDisplayImages.length < 4
                ? () => _pickImage(context, cubit, profile, isMain: false)
                : null,
            onRemove: null,
          );
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ✅ DRAG GRID — main image FIXED (non-draggable), secondary draggable
  // ════════════════════════════════════════════════════════════════
Widget _buildDragGrid(
  BuildContext context,
  MarriageProfileCubit cubit,
  MarriageUserProfileModel profile, {
  required String? displaySingleUrl,
  required File? pendingSingle,
  required bool hasSingleToShow,
  required List<String> secondaryImages,
  required List<String> filteredServerImages,
  required List<String> allDisplayImages,
}) {
  final screenWidth = MediaQuery.of(context).size.width - 40.w - 20.w;
  final cellWidth = (screenWidth - 24) / 3;
  final cellHeight = cellWidth / 0.7;

  // ✅ Fixed Main Image
  Widget mainFixed = SizedBox(
    width: cellWidth,
    height: cellHeight, // spans 2 rows height + gap
    child: ImageSlotCard(
      imageUrl: displaySingleUrl,
      localFile: pendingSingle,
      isMain: true,
      onTap: null,
      onRemove: null,
    ),
  );

  // ✅ Drag hint banner
  Widget dragHint = Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: AppColors.primary50.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.touch_app_outlined, size: 14.w, color: AppColors.primary400),
        Gap(6.w),
        Text(
          context.tr('long_press_to_drag'),
          style: TextStyle(fontSize: 11.sp, color: AppColors.primary400),
        ),
      ],
    ),
  );

  // ✅ Build each secondary slot
  Widget secSlot(int listIndex) {
    if (listIndex >= secondaryImages.length) {
      return Container(
        key: ValueKey('empty_$listIndex'),
        child: ImageSlotCard(
          imageUrl: null,
          isMain: false,
          onTap: null,
          onRemove: null,
        ),
      );
    }
    final isLocal = listIndex >= filteredServerImages.length;
    final pendingIndex = listIndex - filteredServerImages.length;
    final imageUrl = isLocal ? null : secondaryImages[listIndex];

    return AnimatedContainer(
      key: ValueKey('sec_${secondaryImages[listIndex]}'),
      duration: const Duration(milliseconds: 200),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: ImageSlotCard(
              imageUrl: imageUrl,
              localFile: isLocal ? widget.state.pendingImages[pendingIndex] : null,
              isMain: false,
              onTap: null,
              onRemove: null,
            ),
          ),
          Positioned(
            top: 6.h,
            right: 6.w,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Icon(
                Icons.drag_indicator_rounded,
                color: Colors.white,
                size: 13.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  return Directionality(
    textDirection: TextDirection.rtl,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── LEFT: Main image FIXED (spans full height) ──
        mainFixed,

        SizedBox(width: 12.w),

        // ── RIGHT: ReorderableGridView للـ 4 صور الثانوية ──
        Expanded(
          child: SizedBox(
            // height = 2 rows + 1 gap
            height: cellHeight * 2 + 12,
            child: ReorderableGridView.count(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIdx, newIdx) {
                if (oldIdx == newIdx) return;

                // ✅ Reorder locally in the list
                final updatedImages = List<String>.from(secondaryImages);
                if (newIdx >= updatedImages.length) return;

                final item = updatedImages.removeAt(oldIdx);
                updatedImages.insert(newIdx, item);

                cubit.reorderSecondaryImages(updatedImages, filteredServerImages);

                setState(() {});

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    CustomSnackBar(
                      context,
                      text: context.tr('image_reordered_successfully'),
                      isError: false,
                    ),
                  );
                }
              },
              children: List.generate(4, (i) => secSlot(i)),
            ),
          ),
        ),
      ],
    ),
  );
}
  // ════════════════════════════════════════════════════════════════
  // VIDEO SECTION
  // ════════════════════════════════════════════════════════════════
  Widget _buildVideoSection(BuildContext context) {
    final serverVideoUrl = widget.profile.userMedia?.video;
    final pendingVideo = widget.state.pendingVideo;
    final pendingDeleteVideo = widget.state.pendingDeleteVideo;
    final hasVideo =
        !pendingDeleteVideo &&
        (pendingVideo != null ||
            (serverVideoUrl != null && serverVideoUrl.isNotEmpty));

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(252, 255, 255, 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('intro_video'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          if (pendingVideo != null) ...[
            _buildPendingBadge(context, context.tr('video_pending_save')),
            Gap(8.h),
            Center(
              child: CustomUploadedVideoPreview(
                key: ValueKey(pendingVideo.path),
                video: XFile(pendingVideo.path),
                height: 0.3,
                width: 0.9,
                onInitialized: () {},
                onRemove: () => _deleteVideo(context),
              ),
            ),
          ] else
            VideoSection(
              videoUrl:
                  (!pendingDeleteVideo &&
                      serverVideoUrl != null &&
                      serverVideoUrl.isNotEmpty)
                  ? serverVideoUrl
                  : null,
              onDelete: hasVideo ? () => _deleteVideo(context) : null,
              onUpload: !hasVideo ? () => _showVideoOptions(context) : null,
              showControls: true,
            ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // AUDIO SECTION
  // ════════════════════════════════════════════════════════════════
  Widget _buildAudioSection(BuildContext context) {
    final serverAudioUrl = widget.profile.userMedia?.audio;
    final pendingAudio = widget.state.pendingAudio;
    final pendingDeleteAudio = widget.state.pendingDeleteAudio;
    final hasAudio =
        !pendingDeleteAudio &&
        (pendingAudio != null ||
            (serverAudioUrl != null && serverAudioUrl.isNotEmpty));

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(252, 255, 255, 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('audio_clip'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          if (_isRecordingInPlace)
            _buildRecordingWidget(context)
          else if (hasAudio)
            _buildAudioPreviewFull(context, pendingAudio: pendingAudio)
          else
            _buildAudioUploadButton(context),
        ],
      ),
    );
  }

  Widget _buildPendingBadge(BuildContext context, String message) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.orange.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 14.w, color: Colors.orange),
          Gap(4.w),
          Text(
            message,
            style: Styles.textStyle12.copyWith(color: Colors.orange),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // PICK / REMOVE
  // ════════════════════════════════════════════════════════════════
  Future<void> _pickSingleImage(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      cubit.addPendingSingleImage(File(image.path));
      if (mounted) setState(() {});
    }
  }

  void _removeSingleImage(BuildContext context, MarriageProfileCubit cubit) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('delete_image'),
      supTitle: context.tr('delete_image_confirm'),
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: context.tr('cancel'),
      showCancelButton: true,
      cancelText: context.tr('delete'),
      onCancel: () {
        cubit.markDeleteSingleImage();
        if (mounted) setState(() {});
      },
      onPressed: () {},
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile, {
    bool isMain = false,
  }) async {
    final serverCount =
        (profile.userMedia?.images.length ?? 0) -
        widget.state.deletedImageUrls.length;
    if (serverCount + widget.state.pendingImages.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: context.tr('max_secondary_images_4'),
          isError: true,
        ),
      );
      return;
    }
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (image != null) {
      cubit.addPendingImage(File(image.path));
      if (mounted) setState(() {});
    }
  }

  void _removeImage(
    BuildContext context,
    MarriageProfileCubit cubit,
    int index,
    List<String> allImages,
  ) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('delete_image'),
      supTitle: context.tr('delete_image_confirm'),
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: context.tr('cancel'),
      showCancelButton: true,
      cancelText: context.tr('delete'),
      onCancel: () {
        cubit.markDeleteImage(allImages[index]);
        if (mounted) setState(() {});
      },
      onPressed: () {},
    );
  }

  // ════════════════════════════════════════════════════════════════
  // VIDEO HANDLERS
  // ════════════════════════════════════════════════════════════════
  void _showVideoOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          context.tr('attach_video'),
          style: Styles.textStyle18Meduim,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.videocam,
                color: AppColors.primary200,
                size: 30.w,
              ),
              title: Text(
                context.tr('record_video_now'),
                style: Styles.textStyle16,
              ),
              subtitle: Text(
                context.tr('record_with_camera'),
                style: Styles.textStyle12.copyWith(color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromCamera(context);
              },
            ),
            Divider(height: 1, color: AppColors.secondary100),
            ListTile(
              leading: Icon(
                Icons.video_library,
                color: AppColors.primary200,
                size: 30.w,
              ),
              title: Text(
                context.tr('choose_from_gallery'),
                style: Styles.textStyle16,
              ),
              subtitle: Text(
                context.tr('choose_video_from_gallery'),
                style: Styles.textStyle12.copyWith(color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromGallery(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideoFromCamera(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        final s = await Permission.camera.request();
        if (!mounted) return;
        if (s.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('camera_permission_required'),
              isError: true,
            ),
          );
          return;
        }
        if (s.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('enable_camera_from_settings'),
              isError: true,
            ),
          );
          await openAppSettings();
          return;
        }
      }
      final XFile? v = await ImagePicker().pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );
      if (v != null) await _processVideoFile(context, v);
    } catch (e) {
      debugPrint('❌ $e');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: context.tr('error_recording_video'),
            isError: true,
          ),
        );
    }
  }

  Future<void> _pickVideoFromGallery(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        final s = info.version.sdkInt >= 33
            ? await Permission.videos.request()
            : await Permission.storage.request();
        if (!mounted) return;
        if (s.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('gallery_permission_required'),
              isError: true,
            ),
          );
          return;
        }
        if (s.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('enable_gallery_from_settings'),
              isError: true,
            ),
          );
          await openAppSettings();
          return;
        }
      }
      final XFile? v = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );
      if (v != null) await _processVideoFile(context, v);
    } catch (e) {
      debugPrint('❌ $e');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: context.tr('error_selecting_video'),
            isError: true,
          ),
        );
    }
  }

  Future<void> _processVideoFile(BuildContext context, XFile video) async {
    try {
      final file = File(video.path);
      if (await file.length() > 50 * 1024 * 1024) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('video_size_too_large'),
              isError: true,
            ),
          );
        return;
      }
      widget.cubit.addPendingVideo(file);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ $e');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: context.tr('error_uploading_video'),
            isError: true,
          ),
        );
    }
  }

  void _deleteVideo(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('delete_video'),
      supTitle: context.tr('delete_video_confirm'),
      icon: Icons.close_outlined,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: context.tr('cancel'),
      showCancelButton: true,
      cancelText: context.tr('delete'),
      onCancel: () {
        widget.cubit.markDeleteVideo();
        if (mounted) setState(() {});
      },
      onPressed: () {},
    );
  }

  // ════════════════════════════════════════════════════════════════
  // AUDIO HANDLERS
  // ════════════════════════════════════════════════════════════════
  void _showAudioOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          context.tr('attach_audio'),
          style: Styles.textStyle18Meduim,
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.mic, color: AppColors.primary200, size: 30.w),
              title: Text(context.tr('record_now'), style: Styles.textStyle16),
              subtitle: Text(
                context.tr('record_voice_now'),
                style: Styles.textStyle12.copyWith(color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context);
                _startRecordingInPlace(context);
              },
            ),
            Divider(height: 1, color: AppColors.secondary100),
            ListTile(
              leading: Icon(
                Icons.upload_file,
                color: AppColors.primary200,
                size: 30.w,
              ),
              title: Text(context.tr('upload_file'), style: Styles.textStyle16),
              subtitle: Text(
                context.tr('choose_audio_file'),
                style: Styles.textStyle12.copyWith(color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickAudio(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startRecordingInPlace(BuildContext context) async {
    if (mounted) setState(() => _isRecordingInPlace = true);
  }

  Future<void> _pickAudio(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        final info = await DeviceInfoPlugin().androidInfo;
        final s = info.version.sdkInt >= 33
            ? await Permission.audio.request()
            : await Permission.storage.request();
        if (!mounted) return;
        if (s.isDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('allow_files_access'),
              isError: true,
            ),
          );
          return;
        }
        if (s.isPermanentlyDenied) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('enable_permission_settings'),
              isError: true,
            ),
          );
          await openAppSettings();
          return;
        }
      }
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'aac', 'wav', 'm4a', 'ogg', 'opus', 'flac'],
        allowCompression: false,
      );
      if (!mounted) return;
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        if (!await file.exists()) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('file_not_found'),
              isError: true,
            ),
          );
          return;
        }
        if (await file.length() > 10 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('file_too_large'),
              isError: true,
            ),
          );
          return;
        }
        widget.cubit.addPendingAudio(file);
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: '${context.tr('error_picking_audio')}: $e',
            isError: true,
          ),
        );
    }
  }

  void _deleteAudio(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('delete_audio'),
      supTitle: context.tr('delete_audio_confirm'),
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: context.tr('cancel'),
      showCancelButton: true,
      cancelText: context.tr('delete'),
      onCancel: () {
        widget.cubit.markDeleteAudio();
        if (mounted) setState(() {});
      },
      onPressed: () {},
    );
  }

  Widget _buildAudioPreviewFull(BuildContext context, {File? pendingAudio}) {
    final audioPath =
        pendingAudio?.path ?? widget.profile.userMedia?.audio ?? '';
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary200.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('audio_clip'),
                style: Styles.textStyle16.copyWith(fontWeight: FontWeight.w600),
              ),
              IconButton(
                onPressed: () => _deleteAudio(context),
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 20.w,
                  ),
                ),
              ),
            ],
          ),
          if (pendingAudio != null)
            _buildPendingBadge(context, context.tr('audio_pending_save')),
          Gap(12.h),
          VoiceSection(audioPath: audioPath),
        ],
      ),
    );
  }

  Widget _buildAudioUploadButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAudioOptions(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.secondary50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primary200, width: 1.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr('attach_audio'), style: Styles.textStyle16),
                Gap(4.h),
                Text(
                  context.tr('record_or_upload'),
                  style: Styles.textStyle12.copyWith(color: Colors.grey),
                ),
              ],
            ),
            Icon(Icons.mic_none, color: AppColors.primary200, size: 30.w),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary200, width: 1.w),
      ),
      child: VoiceRecordingWidget(
        onAudioRecorded: (audioFile) {
          setState(() => _isRecordingInPlace = false);
          widget.cubit.addPendingAudio(audioFile);
        },
        onCancel: () => setState(() => _isRecordingInPlace = false),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // INFO SECTIONS
  // ════════════════════════════════════════════════════════════════
  Widget _buildPersonalInfoSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('personal_info'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            context.tr('country'),
            _translateValue(profile.aboutMe?.country ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'country',
              profile.aboutMe?.country,
            ),
          ),
          _buildInfoRow(
            context.tr('nationality'),
            _translateValue(profile.aboutMe?.nationality ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'nationality',
              profile.aboutMe?.nationality,
            ),
          ),
          _buildInfoRow(
            context.tr('height'),
            profile.aboutMe?.height ?? context.tr('select'),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'height',
              profile.aboutMe?.height,
            ),
          ),
          _buildInfoRow(
            context.tr('weight'),
            profile.aboutMe?.weight ?? context.tr('select'),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'weight',
              profile.aboutMe?.weight,
            ),
          ),
          _buildInfoRow(
            context.tr('skin_color'),
            _translateValue(profile.aboutMe?.skinColor ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'skinColor',
              profile.aboutMe?.skinColor,
            ),
          ),
          _buildInfoRow(
            context.tr('select_health_status_title'),
            _translateValue(profile.aboutMe?.healthStatus ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'healthStatus',
              profile.aboutMe?.healthStatus,
            ),
          ),
          _buildInfoRow(
            context.tr('commitment_to_religion'),
            _translateValue(
              profile.aboutMe?.religiousCommitment ?? '',
              context,
            ),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'religiousCommitment',
              profile.aboutMe?.religiousCommitment,
            ),
          ),
          _buildInfoRow(
            context.tr('smoking'),
            _translateValue(profile.aboutMe?.smoker ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'smoker',
              profile.aboutMe?.smoker,
            ),
          ),
          _buildInfoRow(
            context.tr('drink_alcohol'),
            _translateValue(profile.aboutMe?.drinkAlcohol ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'drinkAlcohol',
              profile.aboutMe?.drinkAlcohol,
            ),
          ),
          _buildInfoRow(
            context.tr('eat_halal_only'),
            _translateValue(profile.aboutMe?.eatHalalOnly ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'eatHalalOnly',
              profile.aboutMe?.eatHalalOnly,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalInfoSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('professional_info'),
            style: Styles.textStyle18Meduim,
          ),
          Gap(12.h),
          _buildInfoRow(
            context.tr('qualification'),
            _translateValue(
              profile.professionalLife?.educationLevel ?? '',
              context,
            ),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'education_level',
              profile.professionalLife?.educationLevel,
            ),
          ),
          Gap(12.h),
          _buildInfoRow(
            context.tr('job'),
            _translateValue(profile.professionalLife?.job ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'choose_job',
              profile.professionalLife?.job,
            ),
          ),
          Gap(12.h),
          _buildInfoRow(
            context.tr('employer'),
            _translateValue(
              profile.professionalLife?.chooseEmployer ?? '',
              context,
            ),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'choose_employer',
              profile.professionalLife?.chooseEmployer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyAndPreferencesSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    final hasChildren = profile.family?.hasChildren ?? '';
    final showChildrenDetails =
        hasChildren.isNotEmpty && hasChildren != 'no' && hasChildren != 'لا';
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('family_info'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            context.tr('marital_status'),
            _translateValue(profile.aboutMe?.socialStatus ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'maritalStatus',
              profile.aboutMe?.socialStatus,
            ),
          ),
          _buildInfoRow(
            context.tr('has_childrens'),
            _translateValue(profile.family?.hasChildren ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'hasChildren',
              profile.family?.hasChildren,
            ),
          ),
          if (showChildrenDetails) ...[
            _buildInfoRow(
              context.tr('children_count'),
              _translateValue(profile.family?.childrenNumber ?? '', context),
              () => _navigateToFieldSelection(
                context,
                cubit,
                'childrenNumber',
                profile.family?.childrenNumber,
              ),
            ),
            _buildInfoRow(
              context.tr('children_live_with_you'),
              _translateValue(
                profile.family?.childrenLivingStatus ?? '',
                context,
              ),
              () => _navigateToFieldSelection(
                context,
                cubit,
                'childrenLiveWithYou',
                profile.family?.childrenLivingStatus,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalsSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('my_goals'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            context.tr('engagement'),
            _translateValue(profile.yourGoals?.engagement ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'engagement',
              profile.yourGoals?.engagement,
            ),
          ),
          _buildInfoRow(
            context.tr('marriage'),
            _translateValue(profile.yourGoals?.marry ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'marriage_intentions',
              profile.yourGoals?.marry,
            ),
          ),
          _buildInfoRow(
            context.tr('family'),
            _translateValue(profile.yourGoals?.familyAcceptance ?? '', context),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'familyAcceptance',
              profile.yourGoals?.familyAcceptance,
            ),
          ),
          _buildInfoRow(
            context.tr('travel'),
            _translateValue(
              profile.yourGoals?.intendTravelAbroad ?? '',
              context,
            ),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'intendTravelAbroad',
              profile.yourGoals?.intendTravelAbroad,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowMeMoreSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    final faithHobbies = profile.faith;
    final interestHobbies = profile.hobbies;
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.tr('know_me_more'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            context.tr('my_cv'),
            profile.myDescription ?? context.tr('select'),
            () => _navigateToBioEdit(context, cubit, profile.myDescription),
          ),
          _buildInfoRow(
            context.tr('select_hobbies_title'),
            interestHobbies.isNotEmpty
                ? _formatHobbiesForDisplay(interestHobbies, context)
                : context.tr('select'),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'interests',
              interestHobbies.isNotEmpty ? interestHobbies.join(', ') : null,
            ),
          ),
          _buildInfoRow(
            context.tr('faith'),
            faithHobbies.isNotEmpty
                ? _formatHobbiesForDisplay(faithHobbies, context)
                : context.tr('select'),
            () => _navigateToFieldSelection(
              context,
              cubit,
              'faith',
              faithHobbies.isNotEmpty ? faithHobbies.join(', ') : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageProfileState state,
  ) {
    return BlocConsumer<MarriageProfileCubit, MarriageProfileState>(
      listener: (context, state) {
        if (state.state == CubitStates.success && !state.isUpdating) {
          widget.onTabChanged?.call(1);
        } else if (state.state == CubitStates.failure) {
          debugPrint('❌ [SAVE] Error: ${state.errorMessage}');
          if (state.errorMessage != null)
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(context, text: state.errorMessage!, isError: true),
            );
        }
      },
      builder: (context, state) => CustomBotton(
        title: state.isUpdating
            ? context.tr('saving')
            : context.tr('save_changes'),
        onPressed: state.isUpdating
            ? null
            : () {
                debugPrint('💾 [SAVE] Button pressed');
                cubit.saveProfile();
              },
        width: double.infinity,
        height: 54.h,
        useGradient: !state.isUpdating,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, VoidCallback onTap) {
    final isLongText = value.length > 20;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.kWhiteColor,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLongText) ...[
              Text(label, style: Styles.textStyle18),
              Gap(8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.left,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Styles.textStyle16,
                    ),
                  ),
                  Gap(8.w),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14.w,
                    color: AppColors.secondary400,
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      label,
                      style: Styles.textStyle18,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap(8.w),
                  Expanded(
                    flex: 3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            value,
                            textAlign: TextAlign.right,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Styles.textStyle16,
                          ),
                        ),
                        Gap(8.w),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14.w,
                          color: AppColors.secondary400,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            Gap(8.h),
            Divider(color: AppColors.secondary100, height: 1),
          ],
        ),
      ),
    );
  }

  void _navigateToFieldSelection(
    BuildContext context,
    MarriageProfileCubit cubit,
    String fieldKey,
    String? currentValue,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarriageFieldSelectionView(
          fieldName: fieldKey,
          currentValue: currentValue,
          onValueSelected: (value) {
            if (fieldKey == 'interests' || fieldKey == 'hobbies') {
              for (var part in value.split(', ')) {
                final isKey =
                    part.startsWith('interest_') || part.startsWith('faith_');
                debugPrint(
                  '  ${isKey ? "✅" : "❌"} $part ${isKey ? "(KEY)" : "(VALUE - WRONG!)"}',
                );
              }
            }
            debugPrint('═══════════════════════════════════════════');
            cubit.updateField(fieldKey, value);
          },
        ),
      ),
    );
  }

  void _navigateToBioEdit(
    BuildContext context,
    MarriageProfileCubit cubit,
    String? currentBio,
  ) {
    final controller = TextEditingController(text: currentBio);
    CustomSHowDetailsDialog(
      context,
      title: context.tr('edit_bio'),
      contantWidget: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: context.tr('write_about_yourself'),
          hintStyle: Styles.textStyle12.copyWith(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
      onSendPressed: () {
        final newBio = controller.text.trim();
        if (newBio.isNotEmpty) {
          cubit.updateField('bio', newBio);
          Navigator.pop(context);
        }
      },
    );
  }
}
