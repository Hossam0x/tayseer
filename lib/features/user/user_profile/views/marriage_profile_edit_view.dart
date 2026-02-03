import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/user/marriage/view/widget/bio_voice_section.dart';
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
import 'package:image_picker/image_picker.dart';

class MarriageProfileEditView extends StatefulWidget {
  MarriageProfileEditView({
    super.key,
    required this.cubit,
    required this.profile,
    required this.state,
    required this.selectedTabIndex,
    required this.maxImages,
    this.onTabChanged, // ✅ Callback للتغيير
  });
  final int maxImages;
  final MarriageProfileCubit cubit;
  final MarriageUserProfileModel profile;
  final MarriageProfileState state;
  late int selectedTabIndex;
  final Function(int)? onTabChanged; // ✅ Callback للـ parent

  @override
  State<MarriageProfileEditView> createState() =>
      _MarriageProfileEditViewState();
}

class _MarriageProfileEditViewState extends State<MarriageProfileEditView> {
  // ✅ حالة التسجيل الصوتي
  bool _isRecordingInPlace = false;

  // ✅ حالات التحميل
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
            'الصور ( ${displayImages.length} صور)',
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
                    text: 'الحد الأقصى للصور هو ${widget.maxImages}',
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
                title: 'حذف الصورة',
                supTitle: 'هل أنت متأكد من حذف هذه الصورة؟',
                icon: Icons.delete_outline,
                iconColor: Colors.red,
                iconBackgroundColor: Colors.red.withOpacity(0.1),
                bottonText: 'حذف',
                showCancelButton: true,
                cancelText: 'إلغاء',
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
          text: 'الحد الأقصى للصور هو ${widget.maxImages}',
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
          Text('المعلومات المهنية', style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            'المؤهل',
            profile.professionalLife?.educationLevel ?? 'اختر',
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
          _buildInfoRow('الوظيفة', profile.professionalLife?.job ?? 'اختر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'choose_job',
              profile.professionalLife?.job,
            );
          }),
          Gap(12.h),
          _buildInfoRow(
            'الجهة الموظفة',
            profile.professionalLife?.chooseEmployer ?? 'اختر',
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

  Widget _buildMediaSection(BuildContext context) {
    final hasVideo =
        widget.profile.userMedia?.video != null &&
        widget.profile.userMedia!.video!.isNotEmpty;
    final hasAudio =
        widget.profile.userMedia?.audio != null &&
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
          // ════════════════════════════════════════════════════════════
          // VIDEO SECTION
          // ════════════════════════════════════════════════════════════
          Text('الفيديو التعريفي', style: Styles.textStyle18Meduim),
          Gap(12.h),

          // ✅ استخدام VideoSection مع callbacks
          if (_isUploadingVideo)
            _buildLoadingWidget('جاري رفع الفيديو...')
          else
            VideoSection(
              videoUrl: widget.profile.userMedia?.video,
              onDelete: hasVideo ? () => _deleteVideo(context) : null,
              onUpload: !hasVideo ? () => _pickVideo(context) : null,
              showControls: true,
            ),

          Gap(16.h),

          // ════════════════════════════════════════════════════════════
          // AUDIO SECTION
          // ════════════════════════════════════════════════════════════
          Text('مقطع صوتي', style:  Styles.textStyle18Meduim),  
          Gap(12.h),

          if (_isUploadingAudio)
            _buildLoadingWidget('جاري رفع التسجيل الصوتي...')
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
  // AUDIO PREVIEW - FULL PLAYER (زي صفحة العرض)
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
          // Header مع زر الحذف
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تسجيل صوتي',
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

          // Audio Player
          VoiceSection(
        
            audioPath: widget.profile.userMedia?.audio ?? '',
            // ⭐ هنضيف parameter جديد
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ✅ LOADING WIDGET
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
  // VIDEO UPLOAD BUTTON
  // ════════════════════════════════════════════════════════════════
  Widget _buildVideoUploadButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickVideo(context),
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
                Text('ارفاق فيديو تعريفي', style: Styles.textStyle16),
                Gap(4.h),
                Text(
                  'الحد الأقصى 50 ميجا',
                  style: Styles.textStyle12.copyWith(color: Colors.grey),
                ),
              ],
            ),
            Icon(
              Icons.play_circle_outline,
              color: AppColors.primary200,
              size: 30.w,
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // VIDEO PREVIEW
  // ════════════════════════════════════════════════════════════════
  Widget _buildVideoPreview(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary200, width: 1.w),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.primary200.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.videocam,
              color: AppColors.primary200,
              size: 30.w,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('فيديو تعريفي', style: Styles.textStyle16),
                Gap(4.h),
                Text(
                  'تم الرفع',
                  style: Styles.textStyle12.copyWith(color: Colors.green),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _deleteVideo(context);
            },
            icon: Icon(Icons.delete_outline, color: Colors.red, size: 24.w),
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
                Text('ارفاق تسجيل صوتي', style: Styles.textStyle16),
                Gap(4.h),
                Text(
                  'تسجيل مباشر أو رفع ملف',
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
  // AUDIO PREVIEW
  // ════════════════════════════════════════════════════════════════
  Widget _buildAudioPreview(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.secondary50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary200, width: 1.w),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: AppColors.primary200.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.audiotrack,
              color: AppColors.primary200,
              size: 30.w,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تسجيل صوتي', style: Styles.textStyle16),
                Gap(4.h),
                Text(
                  'تم الرفع',
                  style: Styles.textStyle12.copyWith(color: Colors.green),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteAudio(context),
            icon: Icon(Icons.delete_outline, color: Colors.red, size: 24.w),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // PICK VIDEO
  // ════════════════════════════════════════════════════════════════
  Future<void> _pickVideo(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 2),
      );

      if (video != null) {
        final file = File(video.path);
        final fileSize = await file.length();

        if (fileSize > 50 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              CustomSnackBar(
                context,
                text: 'حجم الفيديو كبير جداً (الحد الأقصى 50 ميجا)',
                isError: true,
              ),
            );
          }
          return;
        }

        // ✅ تفعيل حالة التحميل
        setState(() {
          _isUploadingVideo = true;
        });

        await widget.cubit.uploadVideo(file);

        // ✅ إيقاف حالة التحميل
        if (mounted) {
          setState(() {
            _isUploadingVideo = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error picking video: $e');

      if (mounted) {
        setState(() {
          _isUploadingVideo = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(context, text: 'خطأ في اختيار الفيديو', isError: true),
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
            'إرفاق تسجيل صوتي',
            style: Styles.textStyle18Meduim,
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.mic,
                  color: AppColors.primary200,
                  size: 30.w,
                ),
                title: Text('تسجيل مباشر', style: Styles.textStyle16),
                subtitle: Text(
                  'سجل صوتك الآن',
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
                title: Text('رفع ملف', style: Styles.textStyle16),
                subtitle: Text(
                  'اختر ملف صوتي من جهازك',
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
            text: 'يرجى السماح بالوصول للملفات',
            isError: true,
          ),
        );
        return;
      }

      if (status.isPermanentlyDenied) {
        scaffoldMessenger.showSnackBar(
          CustomSnackBar(
            context,
            text: 'يرجى تفعيل الصلاحية من الإعدادات',
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
              text: 'حجم الملف كبير جداً (الحد الأقصى 10 ميجا)',
              isError: true,
            ),
          );
          return;
        }

        // ✅ تفعيل حالة التحميل
        setState(() {
          _isUploadingAudio = true;
        });

        await widget.cubit.uploadAudio(file);

        // ✅ إيقاف حالة التحميل
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
            text: 'خطأ في اختيار الملف الصوتي',
            isError: true,
          ),
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // DELETE VIDEO - ✅ مع تحديث الـ State
  // ════════════════════════════════════════════════════════════════
  void _deleteVideo(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: 'حذف الفيديو',
      supTitle: 'هل أنت متأكد من حذف الفيديو التعريفي؟',
      icon: Icons.close_outlined,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: 'حذف',
      showCancelButton: true,
      cancelText: 'إلغاء',
      onPressed: () async {
        // Navigator.pop(context); // ✅ أغلق الـ Dialog أولاً

        await widget.cubit.deleteVideo();

        // ✅ تحديث الـ State بعد الحذف
        if (mounted) {
          setState(() {
            // Force rebuild to show the upload button
          });
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // DELETE AUDIO - ✅ مع تحديث الـ State
  // ════════════════════════════════════════════════════════════════
  void _deleteAudio(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: 'حذف التسجيل الصوتي',
      supTitle: 'هل أنت متأكد من حذف التسجيل الصوتي؟',
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: 'حذف',
      showCancelButton: true,
      cancelText: 'إلغاء',
      onPressed: () async {
        // Navigator.pop(context); // ✅ أغلق الـ Dialog أولاً

        await widget.cubit.deleteAudio();

        // ✅ تحديث الـ State بعد الحذف
        if (mounted) {
          setState(() {
            // Force rebuild to show the upload button
          });
        }
      },
    );
  }

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
          Text('المعلومات العائلية', style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow(
            'الحالة الاجتماعية',
            profile.aboutMe?.socialStatus ?? 'اختر',
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
            'لديك أطفال',
            profile.family?.hasChildren ?? 'اختر',
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
            'عدد الأطفال',
            profile.family?.childrenNumber ?? 'اختر',
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
            'يعيش الأطفال معك',
            profile.family?.childrenLivingStatus ?? 'اختر',
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
          Text('أهدافي', style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow('الخطوبة', profile.yourGoals?.engagement ?? 'اختر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'engagement',
              profile.yourGoals?.engagement,
            );
          }),
          _buildInfoRow('الزواج', profile.yourGoals?.marry ?? 'اختر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'marry',
              profile.yourGoals?.marry,
            );
          }),
          _buildInfoRow('الاسرة', profile.yourGoals?.children ?? 'اختر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'children',
              profile.yourGoals?.children,
            );
          }),
          _buildInfoRow('السفر', profile.yourGoals?.travel ?? 'اختر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'travel',
              profile.yourGoals?.travel,
            );
          }),
        ],
      ),
    );
  }

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
          Text('تعرف عليّ أكثر', style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow('السيرة الذاتية', profile.myDescription ?? 'اختر', () {
            _navigateToBioEdit(context, cubit, profile.myDescription);
          }),
          _buildInfoRow(
            'الاهتمامات',
            profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : 'اختر',
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
            'الهوايات',
            profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : 'اختر',
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

  Widget _buildSaveButton(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageProfileState state,
  ) {
    return CustomBotton(
      title: state.isUpdating ? 'جاري الحفظ...' : 'حفظ التغييرات',
      onPressed: state.isUpdating
          ? null
          : () async {
              await cubit.saveProfile();

              if (mounted && state.state == CubitStates.success) {
                // ✅ استخدام الـ callback لتحديث الـ parent
                widget.onTabChanged?.call(1);
              }
            },
      width: double.infinity,
      height: 54.h,
      useGradient: !state.isUpdating,
    );
  }

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
          Text('معلومات عني', style: Styles.textStyle18Meduim),
          Gap(12.h),
          _buildInfoRow('البلد', profile.aboutMe?.country ?? 'اختر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'country',
              profile.aboutMe?.country,
            );
          }),
          _buildInfoRow('الجنسية', profile.aboutMe?.nationality ?? 'اختر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'nationality',
              profile.aboutMe?.nationality,
            );
          }),
          _buildInfoRow('الطول', profile.aboutMe?.height ?? 'اختر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'height',
              profile.aboutMe?.height,
            );
          }),
          _buildInfoRow('الوزن', profile.aboutMe?.weight ?? 'اختر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'weight',
              profile.aboutMe?.weight,
            );
          }),
          _buildInfoRow('لون البشرة', profile.aboutMe?.skinColor ?? 'اختر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'skinColor',
              profile.aboutMe?.skinColor,
            );
          }),
          _buildInfoRow(
            'الحالة الصحية',
            profile.aboutMe?.healthStatus ?? 'اختر',
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
            'الالتزام الديني',
            profile.aboutMe?.religiousCommitment ?? 'اختر',
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'religiousCommitment',
                profile.aboutMe?.religiousCommitment,
              );
            },
          ),
          _buildInfoRow('التدخين', profile.aboutMe?.smoker ?? 'اختر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'smoker',
              profile.aboutMe?.smoker,
            );
          }),
        ],
      ),
    );
  }

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
      title: 'تعديل السيرة الذاتية',
      contantWidget: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'اكتب نبذة عنك...',
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
