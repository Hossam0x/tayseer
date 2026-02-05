import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/user/marriage/view/widget/video_section.dart';
import 'package:tayseer/features/user/questions/view/widget/custtom_image_grid.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/audioWidget.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_field_selection_view.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/voiceWidget.dart';
import 'package:tayseer/my_import.dart';
import 'package:file_picker/file_picker.dart';


class MarriageProfileEditView extends StatefulWidget {
  MarriageProfileEditView({
    super.key,
    required this.cubit,
    required this.profile,
    required this.state,
    required this.selectedTabIndex,
    required this.maxImages,
    this.onTabChanged,
  });
  
  final int maxImages;
  final MarriageProfileCubit cubit;
  final MarriageUserProfileModel profile;
  final MarriageProfileState state;
  late int selectedTabIndex;
  final Function(int)? onTabChanged;

  @override
  State<MarriageProfileEditView> createState() =>
      _MarriageProfileEditViewState();
}

class _MarriageProfileEditViewState extends State<MarriageProfileEditView> {
  bool _isRecordingInPlace = false;
  bool _isUploadingVideo = false;
  bool _isUploadingAudio = false;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Gap(24.h),
              _buildPersonalInfoSection(context, widget.cubit, widget.profile),
              Gap(20.h),
              _buildImagesSection(context, widget.cubit, widget.profile),
              Gap(24.h),
              _buildProfessionalInfoSection(
                context,
                widget.cubit,
                widget.profile,
              ),
              Gap(24.h),
              _buildMediaSection(context),
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
  // IMAGES SECTION
  // ════════════════════════════════════════════════════════════════
  Widget _buildImagesSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    final allImages = profile.userMedia?.images ?? [];
    final displayImages = allImages.length > 5
        ? allImages.sublist(allImages.length - 5)
        : allImages;

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
            '${context.tr('images_count')} ( ${displayImages.length} ${context.tr('images_count')})',
            style: Styles.textStyle18Meduim,
          ),
          Gap(12.h),
          CusttomImageGrid(
            imageUrls: displayImages,
            onAdd: () {
              if (displayImages.length < widget.maxImages) {
                _pickImage(context, cubit, profile);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  CustomSnackBar(
                    context,
                    text: '${context.tr('max_images')} ${widget.maxImages}',
                    isError: true,
                  ),
                );
              }
            },
            onRemove: (index) {
              final realIndex = allImages.length - displayImages.length + index;
              final imagePath = allImages[realIndex];
              CustomshowDialogWithImage(
                context,
                title: context.tr('delete_image'),
                supTitle: context.tr('delete_image_confirm'),
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                iconBackgroundColor: Colors.red.withOpacity(0.1),
                bottonText: context.tr('delete'),
                showCancelButton: true,
                cancelText: context.tr('cancel'),
                onPressed: () {
                  cubit.deleteImage(imagePath);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) async {
    final currentImageCount = profile.userMedia?.images.length ?? 0;
    final ImagePicker picker = ImagePicker();
    
    if (currentImageCount >= widget.maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: '${context.tr('max_images')} ${widget.maxImages}',
          isError: true,
        ),
      );
      return;
    }
    
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      cubit.uploadImage(File(image.path));
    }
  }

  // ════════════════════════════════════════════════════════════════
  // PROFESSIONAL INFO SECTION
  // ════════════════════════════════════════════════════════════════
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
          Text(context.tr('professional_info'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            context.tr('qualification'),
            profile.professionalLife?.educationLevel ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'education_level',
                profile.professionalLife?.educationLevel,
              );
            },
          ),
          Gap(12.h),
          _buildInfoRow(
            context.tr('job'),
            profile.professionalLife?.job ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'choose_job',
                profile.professionalLife?.job,
              );
            },
          ),
          Gap(12.h),
          _buildInfoRow(
            context.tr('employer'),
            profile.professionalLife?.chooseEmployer ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'choose_employer',
                profile.professionalLife?.chooseEmployer,
              );
            },
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // MEDIA SECTION
  // ════════════════════════════════════════════════════════════════
  Widget _buildMediaSection(BuildContext context) {
    final hasVideo = widget.profile.userMedia?.video != null &&
        widget.profile.userMedia!.video!.isNotEmpty;
    final hasAudio = widget.profile.userMedia?.audio != null &&
        widget.profile.userMedia!.audio!.isNotEmpty;

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
          // VIDEO SECTION
          Text(context.tr('intro_video'), style: Styles.textStyle18Meduim),
          Gap(12.h),

          if (_isUploadingVideo)
            _buildLoadingWidget(context.tr('uploading_video'))
          else
            VideoSection(
              videoUrl: widget.profile.userMedia?.video,
              onDelete: hasVideo ? () => _deleteVideo(context) : null,
              onUpload: !hasVideo ? () => _showVideoOptions(context) : null,
              showControls: true,
            ),

          Gap(16.h),

          // AUDIO SECTION
          Text(context.tr('audio_clip'), style: Styles.textStyle18Meduim),
          Gap(12.h),

          if (_isUploadingAudio)
            _buildLoadingWidget(context.tr('uploading_audio'))
          else if (_isRecordingInPlace)
            _buildRecordingWidget(context)
          else if (hasAudio)
            _buildAudioPreviewFull(context)
          else
            _buildAudioUploadButton(context),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // AUDIO PREVIEW FULL
  // ════════════════════════════════════════════════════════════════
  Widget _buildAudioPreviewFull(BuildContext context) {
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
                context.tr('audio_recording'),
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
          Gap(12.h),
          VoiceSection(
            audioPath: widget.profile.userMedia?.audio ?? '',
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // LOADING WIDGET
  // ════════════════════════════════════════════════════════════════
  Widget _buildLoadingWidget(String message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary200, width: 1.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary200),
            ),
          ),
          Gap(12.w),
          Text(
            message,
            style: Styles.textStyle14.copyWith(color: AppColors.primary200),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // AUDIO UPLOAD BUTTON
  // ════════════════════════════════════════════════════════════════
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

  // ════════════════════════════════════════════════════════════════
  // RECORDING WIDGET
  // ════════════════════════════════════════════════════════════════
  Widget _buildRecordingWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary200, width: 1.w),
      ),
      child: VoiceRecordingWidget(
        onAudioRecorded: (audioFile) async {
          setState(() {
            _isRecordingInPlace = false;
            _isUploadingAudio = true;
          });

          await widget.cubit.uploadAudio(audioFile);

          if (mounted) {
            setState(() {
              _isUploadingAudio = false;
            });
          }
        },
        onCancel: () {
          setState(() {
            _isRecordingInPlace = false;
          });
        },
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // SHOW VIDEO OPTIONS DIALOG
  // ════════════════════════════════════════════════════════════════
  void _showVideoOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
              // Camera Option
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
              
              // Gallery Option
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
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // PICK VIDEO FROM CAMERA
  // ════════════════════════════════════════════════════════════════
  Future<void> _pickVideoFromCamera(BuildContext context) async {
    try {
      final cameraStatus = await Permission.camera.request();
      
      if (cameraStatus.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('camera_permission_required'),
              isError: true,
            ),
          );
        }
        return;
      }

      if (cameraStatus.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('enable_camera_from_settings'),
              isError: true,
            ),
          );
          await openAppSettings();
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        await _processVideoFile(context, video);
      }
    } catch (e) {
      debugPrint('❌ Error picking video from camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: context.tr('error_recording_video'),
            isError: true,
          ),
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // PICK VIDEO FROM GALLERY
  // ════════════════════════════════════════════════════════════════
  Future<void> _pickVideoFromGallery(BuildContext context) async {
    try {
      PermissionStatus status;
      
      if (Platform.isIOS) {
        status = await Permission.photos.request();
      } else {
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          if (androidInfo.version.sdkInt >= 33) {
            status = await Permission.videos.request();
          } else {
            status = await Permission.storage.request();
          }
        } else {
          status = await Permission.storage.request();
        }
      }

      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('gallery_permission_required'),
              isError: true,
            ),
          );
        }
        return;
      }

      if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('enable_gallery_from_settings'),
              isError: true,
            ),
          );
          await openAppSettings();
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        await _processVideoFile(context, video);
      }
    } catch (e) {
      debugPrint('❌ Error picking video from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: context.tr('error_selecting_video'),
            isError: true,
          ),
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // PROCESS VIDEO FILE
  // ════════════════════════════════════════════════════════════════
  Future<void> _processVideoFile(BuildContext context, XFile video) async {
    try {
      final file = File(video.path);
      final fileSize = await file.length();

      if (fileSize > 50 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('video_size_too_large'),
              isError: true,
            ),
          );
        }
        return;
      }

      setState(() {
        _isUploadingVideo = true;
      });

      await widget.cubit.uploadVideo(file);

      if (mounted) {
        setState(() {
          _isUploadingVideo = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error processing video file: $e');
      
      if (mounted) {
        setState(() {
          _isUploadingVideo = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            context,
            text: context.tr('error_uploading_video'),
            isError: true,
          ),
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // SHOW AUDIO OPTIONS
  // ════════════════════════════════════════════════════════════════
  void _showAudioOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                leading: Icon(Icons.upload_file, color: AppColors.primary200, size: 30.w),
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
        );
      },
    );
  }

  void _startRecordingInPlace(BuildContext context) {
    setState(() {
      _isRecordingInPlace = true;
    });
  }

  // ════════════════════════════════════════════════════════════════
  // PICK AUDIO FILE
  // ════════════════════════════════════════════════════════════════
  Future<void> _pickAudio(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      PermissionStatus status;

      if (Platform.isIOS) {
        status = await Permission.mediaLibrary.request();
      } else {
        status = await Permission.storage.request();
      }

      if (status.isDenied) {
        scaffoldMessenger.showSnackBar(
          CustomSnackBar(
            context,
            text: context.tr('allow_files_access'),
            isError: true,
          ),
        );
        return;
      }

      if (status.isPermanentlyDenied) {
        scaffoldMessenger.showSnackBar(
          CustomSnackBar(
            context,
            text: context.tr('enable_permission_settings'),
            isError: true,
          ),
        );
        await openAppSettings();
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowCompression: true,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        if (fileSize > 10 * 1024 * 1024) {
          scaffoldMessenger.showSnackBar(
            CustomSnackBar(
              context,
              text: context.tr('file_too_large'),
              isError: true,
            ),
          );
          return;
        }

        setState(() {
          _isUploadingAudio = true;
        });

        await widget.cubit.uploadAudio(file);

        if (mounted) {
          setState(() {
            _isUploadingAudio = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error picking audio: $e');

      if (mounted) {
        setState(() {
          _isUploadingAudio = false;
        });

        scaffoldMessenger.showSnackBar(
          CustomSnackBar(
            context,
            text: context.tr('error_picking_audio'),
            isError: true,
          ),
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // DELETE VIDEO
  // ════════════════════════════════════════════════════════════════
  void _deleteVideo(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('delete_video'),
      supTitle: context.tr('delete_video_confirm'),
      icon: Icons.close_outlined,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: context.tr('delete'),
      showCancelButton: true,
      cancelText: context.tr('cancel'),
      onPressed: () async {
        await widget.cubit.deleteVideo();
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // DELETE AUDIO
  // ════════════════════════════════════════════════════════════════
  void _deleteAudio(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: context.tr('delete_audio'),
      supTitle: context.tr('delete_audio_confirm'),
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: context.tr('delete'),
      showCancelButton: true,
      cancelText: context.tr('cancel'),
      onPressed: () async {
        await widget.cubit.deleteAudio();
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // FAMILY AND PREFERENCES SECTION
  // ════════════════════════════════════════════════════════════════
  Widget _buildFamilyAndPreferencesSection(
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
          Text(context.tr('family_info'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            context.tr('marital_status'),
            profile.aboutMe?.socialStatus ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'maritalStatus',
                profile.aboutMe?.socialStatus,
              );
            },
          ),
          _buildInfoRow(
            context.tr('has_children'),
            profile.family?.hasChildren ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'hasChildren',
                profile.family?.hasChildren,
              );
            },
          ),
          _buildInfoRow(
            context.tr('children_count'),
            profile.family?.childrenNumber ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'childrenNumber',
                profile.family?.childrenNumber,
              );
            },
          ),
          _buildInfoRow(
            context.tr('children_live_with_you'),
            profile.family?.childrenLivingStatus ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'childrenLiveWithYou',
                profile.family?.childrenLivingStatus,
              );
            },
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // GOALS SECTION
  // ════════════════════════════════════════════════════════════════
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
            profile.yourGoals?.engagement ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'engagement',
                profile.yourGoals?.engagement,
              );
            },
          ),
          _buildInfoRow(
            context.tr('marriage'),
            profile.yourGoals?.marry ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'marry',
                profile.yourGoals?.marry,
              );
            },
          ),
          _buildInfoRow(
            context.tr('family'),
            profile.yourGoals?.children ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'children',
                profile.yourGoals?.children,
              );
            },
          ),
          _buildInfoRow(
            context.tr('travel'),
            profile.yourGoals?.travel ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'travel',
                profile.yourGoals?.travel,
              );
            },
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // KNOW ME MORE SECTION
  // ════════════════════════════════════════════════════════════════
  Widget _buildKnowMeMoreSection(
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
          Text(context.tr('know_me_more'), style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            context.tr('bio'),
            profile.myDescription ?? context.tr('select'),
            () {
              _navigateToBioEdit(context, cubit, profile.myDescription);
            },
          ),
          _buildInfoRow(
            context.tr('interests'),
            profile.hobbies.isNotEmpty
                ? profile.hobbies.join(', ')
                : context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'interests',
                profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : null,
              );
            },
          ),
          _buildInfoRow(
            context.tr('hobbies'),
            profile.hobbies.isNotEmpty
                ? profile.hobbies.join(', ')
                : context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'hobbies',
                profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : null,
              );
            },
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // SAVE BUTTON
  // ════════════════════════════════════════════════════════════════
  Widget _buildSaveButton(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageProfileState state,
  ) {
    return CustomBotton(
      title: state.isUpdating
          ? context.tr('saving')
          : context.tr('save_changes'),
      onPressed: state.isUpdating
          ? null
          : () async {
              await cubit.saveProfile();
              if (mounted && state.state == CubitStates.success) {
                widget.onTabChanged?.call(1);
              }
            },
      width: double.infinity,
      height: 54.h,
      useGradient: !state.isUpdating,
    );
  }

  // ════════════════════════════════════════════════════════════════
  // PERSONAL INFO SECTION
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
            profile.aboutMe?.country ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'country',
                profile.aboutMe?.country,
              );
            },
          ),
          _buildInfoRow(
            context.tr('nationality'),
            profile.aboutMe?.nationality ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'nationality',
                profile.aboutMe?.nationality,
              );
            },
          ),
          _buildInfoRow(
            context.tr('height'),
            profile.aboutMe?.height ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'height',
                profile.aboutMe?.height,
              );
            },
          ),
          _buildInfoRow(
            context.tr('weight'),
            profile.aboutMe?.weight ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'weight',
                profile.aboutMe?.weight,
              );
            },
          ),
          _buildInfoRow(
            context.tr('skin_color'),
            profile.aboutMe?.skinColor ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'skinColor',
                profile.aboutMe?.skinColor,
              );
            },
          ),
          _buildInfoRow(
            context.tr('health_status'),
            profile.aboutMe?.healthStatus ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'healthStatus',
                profile.aboutMe?.healthStatus,
              );
            },
          ),
          _buildInfoRow(
            context.tr('religious_commitment'),
            profile.aboutMe?.religiousCommitment ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'religiousCommitment',
                profile.aboutMe?.religiousCommitment,
              );
            },
          ),
          _buildInfoRow(
            context.tr('smoking'),
            profile.aboutMe?.smoker ?? context.tr('select'),
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'smoker',
                profile.aboutMe?.smoker,
              );
            },
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // INFO ROW
  // ════════════════════════════════════════════════════════════════
  Widget _buildInfoRow(String label, String value, VoidCallback onTap) {
    final isLongText = value.length > 30;
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
                      textAlign: TextAlign.right,
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: Styles.textStyle18),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
    final TextEditingController controller = TextEditingController(
      text: currentBio,
    );
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