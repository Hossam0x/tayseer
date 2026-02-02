import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/user/questions/view/widget/custtom_image_grid.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_field_selection_view.dart';
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
  });
  final int maxImages;
  final MarriageProfileCubit cubit;
  final MarriageUserProfileModel profile;
  final MarriageProfileState state;
  late int selectedTabIndex;
  @override
  State<MarriageProfileEditView> createState() =>
      _MarriageProfileEditViewState();
}

class _MarriageProfileEditViewState extends State<MarriageProfileEditView> {
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
            'الصور (آخر ${displayImages.length} صور)',
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
                    text: 'الحد الأقصى للصور هو $widget.maxImages',
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
                  // Navigator.pop(context);
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
          text: 'الحد الأقصى للصور هو $widget.maxImages',
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
    final hasVideo = widget.profile.userMedia?.video != null;
    final hasAudio = widget.profile.userMedia?.audio != null;

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

          if (hasVideo)
            _buildVideoPreview(context)
          else
            _buildVideoUploadButton(context),

          Gap(16.h),

          // ════════════════════════════════════════════════════════════
          // AUDIO SECTION
          // ════════════════════════════════════════════════════════════
          Text('مقطع صوتي', style: Styles.textStyle18Bold),
          Gap(12.h),

          if (hasAudio)
            _buildAudioPreview(context)
          else
            _buildAudioUploadButton(context),
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
    return Column(
      children: [
        // Record Audio
        GestureDetector(
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
        ),
      ],
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
        maxDuration: const Duration(minutes: 2), // Max 2 minutes
      );

      if (video != null) {
        final file = File(video.path);

        // Check file size (max 50MB)
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

        // Show loading
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(CustomSnackBar(context, text: 'جاري رفع الفيديو...'));
        }

        // Upload
        await widget.cubit.uploadVideo(file);
      }
    } catch (e) {
      debugPrint('❌ Error picking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(context, text: 'خطأ في اختيار الفيديو', isError: true),
        );
      }
    }
  }

  // ════════════════════════════════════════════════════════════════
  // SHOW AUDIO OPTIONS (Record or Upload)
  // ════════════════════════════════════════════════════════════════
  void _showAudioOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Record Audio Option
            ListTile(
              leading: Icon(Icons.mic, color: AppColors.primary200),
              title: Text('تسجيل صوتي', style: Styles.textStyle16),
              subtitle: Text(
                'تسجيل مباشر',
                style: Styles.textStyle12.copyWith(color: Colors.grey),
              ),
              onTap: () {
                Navigator.pop(context);
                _recordAudio(context);
              },
            ),
            Divider(),
            // Upload Audio File
            ListTile(
              leading: Icon(Icons.upload_file, color: AppColors.primary200),
              title: Text('رفع ملف صوتي', style: Styles.textStyle16),
              subtitle: Text(
                'من المعرض',
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

  // ════════════════════════════════════════════════════════════════
  // PICK AUDIO FILE
  // ════════════════════════════════════════════════════════════════
  // ════════════════════════════════════════════════════════════════
  // FIX للـ _pickAudio - حل مشكلة الـ UI state
  // ════════════════════════════════════════════════════════════════
  Future<void> _pickAudio(BuildContext context) async {
    // ✅ Capture ScaffoldMessenger BEFORE any async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowCompression: true,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Check file size (max 10MB)
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

        // Show loading
        scaffoldMessenger.showSnackBar(
          CustomSnackBar(context, text: 'جاري رفع الملف الصوتي...'),
        );

        // Upload
        await widget.cubit.uploadAudio(file);
      }
    } catch (e) {
      debugPrint('❌ Error picking audio: $e');
      scaffoldMessenger.showSnackBar(
        CustomSnackBar(
          context,
          text: 'خطأ في اختيار الملف الصوتي',
          isError: true,
        ),
      );
    }
  } // ════════════════════════════════════════════════════════════════

  // RECORD AUDIO (Placeholder - requires record package)
  // ════════════════════════════════════════════════════════════════
  Future<void> _recordAudio(BuildContext context) async {
    // TODO: Implement audio recording using record package
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(context, text: 'سيتم إضافة ميزة التسجيل قريباً'),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // DELETE VIDEO
  // ════════════════════════════════════════════════════════════════
  void _deleteVideo(BuildContext context) {
    CustomshowDialogWithImage(
      context,
      title: 'حذف الفيديو',
      supTitle: 'هل أنت متأكد من حذف الفيديو التعريفي؟',
      icon: Icons.delete_outline,
      iconColor: Colors.red,
      iconBackgroundColor: Colors.red.withOpacity(0.1),
      bottonText: 'حذف',
      showCancelButton: true,
      cancelText: 'إلغاء',
      onPressed: () async {
        Navigator.pop(context);
        await widget.cubit.deleteVideo();
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // DELETE AUDIO
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
        Navigator.pop(context);
        await widget.cubit.deleteAudio();
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
                // ✅ Switch to view tab after saving
                setState(() {
                  widget.selectedTabIndex = 0;
                });
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
