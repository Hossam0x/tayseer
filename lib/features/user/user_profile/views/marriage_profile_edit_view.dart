import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/custom_show_dialog.dart';
import 'package:tayseer/features/user/questions/refact_question/widget/custtom_image_grid.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_field_selection_view.dart';
import 'package:tayseer/my_import.dart';

class MarriageProfileEditView extends StatefulWidget {
  MarriageProfileEditView({
    super.key,
    required this.cubit,
    required this.profile,
    required this.state,
    required this.selectedTabIndex,
    required this.maxImages
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
              if (displayImages.length <widget.maxImages) {
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
                  Navigator.pop(context);
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
          Text('الفيديو', style: Styles.textStyle18Meduim),
          Gap(12.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.secondary50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary200, width: 1.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ارفاق فيديو تعريفي', style: Styles.textStyle16),
                Icon(
                  Icons.play_circle_outline,
                  color: AppColors.primary200,
                  size: 30.w,
                ),
              ],
            ),
          ),
          Gap(16.h),
          Text('مقطع صوتي', style: Styles.textStyle18Bold),
          Gap(12.h),
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            decoration: BoxDecoration(
              color: AppColors.secondary50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primary200, width: 1.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ارفاق تسجيل صوتي', style: Styles.textStyle16),
                Icon(Icons.mic_none, color: AppColors.primary200, size: 30.w),
              ],
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








// // marriage_profile_edit_view.dart - FIXED EDIT PAGE (PART 1/2)
// // ════════════════════════════════════════════════════════════════
// // ✅ صفحة التعديل - تستخدم loadProfileForEdit()
// // ════════════════════════════════════════════════════════════════

// import 'package:tayseer/core/widgets/custom_show_dialog.dart';
// import 'package:tayseer/core/widgets/custom_toggle_tab_bar.dart';
// import 'package:tayseer/core/widgets/simple_app_bar.dart';
// import 'package:tayseer/features/user/questions/refact_question/widget/custtom_image_grid.dart';
// import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
// import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
// import 'package:tayseer/features/user/user_profile/data/repositories/marriage_profile_repository.dart';
// import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
// import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
// import 'package:tayseer/features/user/user_profile/views/widgets/marriage_fetch_body.dart';
// import 'package:tayseer/features/user/user_profile/views/widgets/marriage_field_selection_view.dart';
// import 'package:tayseer/my_import.dart';

// class MarriageProfileEditView extends StatefulWidget {
//   final UserProfileModel? userProfile;

//   const MarriageProfileEditView({super.key, this.userProfile});

//   @override
//   State<MarriageProfileEditView> createState() =>
//       _MarriageProfileEditViewState();
// }

// class _MarriageProfileEditViewState extends State<MarriageProfileEditView> {
//   final ImagePicker _picker = ImagePicker();
//   final int _maxImages = 5;
//   int _selectedTabIndex = 1; // ⭐ Start with "تعديل" tab selected

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => MarriageProfileCubit(
//         getIt<MarriageProfileRepository>(),
//         initialUserProfile: widget.userProfile,
//       )..loadProfile(),  // ⭐⭐⭐ استخدام method الصحيح للتعديل
//       child: Scaffold(
//         body: SafeArea(
//           child: BlocConsumer<MarriageProfileCubit, MarriageProfileState>(
//             listener: (context, state) {
//               if (state.state == CubitStates.success &&
//                   state.successMessage != null) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   CustomSnackBar(
//                     context,
//                     text: state.successMessage!,
//                     isSuccess: true,
//                   ),
//                 );
//               }
//               if (state.state == CubitStates.failure &&
//                   state.errorMessage != null) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   CustomSnackBar(
//                     context,
//                     text: state.errorMessage!,
//                     isError: true,
//                   ),
//                 );
//               }
//             },
//             builder: (context, state) {
//               final cubit = context.read<MarriageProfileCubit>();

//               if (state.isLoading && state.profile == null) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (state.state == CubitStates.failure && state.profile == null) {
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.error_outline,
//                         size: 64.w,
//                         color: AppColors.errorColor,
//                       ),
//                       Gap(16.h),
//                       Text(
//                         state.errorMessage ?? 'حدث خطأ في تحميل البيانات',
//                         textAlign: TextAlign.center,
//                         style: Styles.textStyle16.copyWith(
//                           color: AppColors.secondary600,
//                         ),
//                       ),
//                       Gap(24.h),
//                       CustomBotton(
//                         title: 'رجوع',
//                         onPressed: () => Navigator.pop(context),
//                         width: 120.w,
//                         height: 48.h,
//                       ),
//                     ],
//                   ),
//                 );
//               }

//               final profile = state.profile;

//               if (profile == null) {
//                 return Center(child: Text('لا توجد بيانات'));
//               }

//               return CustomScrollView(
//                 slivers: [
//                   SliverToBoxAdapter(
//                     child: SimpleAppBar(
//                       title: 'تعديل ملف الزواج',
//                       isLargeTitle: true,
//                     ),
//                   ),
//                   SliverToBoxAdapter(
//                     child: Container(
//                       padding: EdgeInsets.only(
//                         top: MediaQuery.of(context).padding.top + 16.h,
//                         left: 20.w,
//                         right: 20.w,
//                       ),
//                       child: CustomToggleTabBar(
//                         firstTabText: "عرض",
//                         secondTabText: "تعديل",
//                         initialIndex: _selectedTabIndex,
//                         onTabChanged: (index) {
//                           setState(() {
//                             _selectedTabIndex = index;
//                           });
                          
//                           // ⭐⭐⭐ عند الانتقال للعرض
//                           if (index == 0) {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => MarriageFetchBody(),
//                               ),
//                             );
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20.w),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Gap(24.h),
//                           _buildPersonalInfoSection(context, cubit, profile),
//                           Gap(20.h),
//                           _buildImagesSection(context, cubit, profile),
//                           Gap(24.h),
//                           _buildProfessionalInfoSection(
//                             context,
//                             cubit,
//                             profile,
//                           ),
//                           Gap(24.h),
//                           _buildMediaSection(context),
//                           Gap(24.h),
//                           _buildFamilyAndPreferencesSection(
//                             context,
//                             cubit,
//                             profile,
//                           ),
//                           Gap(24.h),
//                           _buildGoalsSection(context, cubit, profile),
//                           Gap(24.h),
//                           _buildkownmeMoreSection(context, cubit, profile),
//                           Gap(32.h),
//                           _buildSaveButton(context, cubit, state),
//                           Gap(100.h),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPersonalInfoSection(
//     BuildContext context,
//     MarriageProfileCubit cubit,
//     MarriageUserProfileModel profile,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(10.w),
//       decoration: BoxDecoration(
//         color: AppColors.kWhiteColor,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'معلومات عني',
//             style: Styles.textStyle18Meduim.copyWith(
//               color: const Color.fromRGBO(0, 0, 0, 1),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Gap(12.h),
//           _buildInfoRow('البلد', profile.aboutMe?.country ?? 'اختر', () {
//             _navigateToFieldSelection(
//               context,
//               cubit,
//               'country',
//               profile.aboutMe?.country,
//             );
//           }),
//           _buildInfoRow('الجنسية', profile.aboutMe?.nationality ?? 'اختر', () {
//             _navigateToFieldSelection(
//               context,
//               cubit,
//               'nationality',
//               profile.aboutMe?.nationality,
//             );
//           }),
//           _buildInfoRow('الطول', profile.aboutMe?.height ?? 'اختر', () {
//             _navigateToFieldSelection(
//               context,
//               cubit,
//               'height',
//               profile.aboutMe?.height,
//             );
//           }),
//           _buildInfoRow('الوزن', profile.aboutMe?.weight ?? 'اختر', () {
//             _navigateToFieldSelection(
//               context,
//               cubit,
//               'weight',
//               profile.aboutMe?.weight,
//             );
//           }),
//           _buildInfoRow('لون البشرة', profile.aboutMe?.skinColor ?? 'اختر', () {
//             _navigateToFieldSelection(
//               context,
//               cubit,
//               'skinColor',
//               profile.aboutMe?.skinColor,
//             );
//           }),
//           _buildInfoRow(
//             'الحالة الصحية',
//             profile.aboutMe?.healthStatus ?? 'اختر',
//             () {
//               _navigateToFieldSelection(
//                 context,
//                 cubit,
//                 'healthStatus',
//                 profile.aboutMe?.healthStatus,
//               );
//             },
//           ),
//           _buildInfoRow(
//             'الالتزام الديني',
//             profile.aboutMe?.religiousCommitment ?? 'اختر',
//             () {
//               _navigateToFieldSelection(
//                 context,
//                 cubit,
//                 'religiousCommitment',
//                 profile.aboutMe?.religiousCommitment,
//               );
//             },
//           ),
//           _buildInfoRow('التدخين', profile.aboutMe?.smoker ?? 'اختر', () {
//             _navigateToFieldSelection(
//               context,
//               cubit,
//               'smoker',
//               profile.aboutMe?.smoker,
//             );
//           }),
//         ],
//       ),
//     );
//   }// marriage_profile_edit_view.dart - FIXED EDIT PAGE (PART 2/2)
// // ════════════════════════════════════════════════════════════════
// // ✅ تكملة methods صفحة التعديل
// // ════════════════════════════════════════════════════════════════

//   Widget _buildImagesSection(
//     BuildContext context,
//     MarriageProfileCubit cubit,
//     MarriageUserProfileModel profile,
//   ) {
//     final allImages = profile.userMedia?.images ?? [];
//     final displayImages = allImages.length > 5
//         ? allImages.sublist(allImages.length - 5)
//         : allImages;

//     return Container(
//       padding: EdgeInsets.all(10.w),
//       decoration: BoxDecoration(
//         color: AppColors.kWhiteColor,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'الصور (آخر ${displayImages.length} صور)',
//             style: Styles.textStyle18Meduim.copyWith(
//               color: const Color.fromRGBO(0, 0, 0, 1),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Gap(12.h),
//           CusttomImageGrid(
//             imageUrls: displayImages,
//             onAdd: () {
//               if (displayImages.length < _maxImages) {
//                 _pickImage(context, cubit, profile);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   CustomSnackBar(
//                     context,
//                     text: 'الحد الأقصى للصور هو $_maxImages',
//                     isError: true,
//                   ),
//                 );
//               }
//             },
//             onRemove: (index) {
//               final realIndex = allImages.length - displayImages.length + index;
//               final imagePath = allImages[realIndex];

//               CustomshowDialogWithImage(
//                 context,
//                 title: 'حذف الصورة',
//                 supTitle: 'هل أنت متأكد من حذف هذه الصورة؟',
//                 icon: Icons.delete_outline,
//                 iconColor: Colors.red,
//                 iconBackgroundColor: Colors.red.withOpacity(0.1),
//                 bottonText: 'حذف',
//                 showCancelButton: true,
//                 cancelText: 'إلغاء',
//                 onPressed: () {
//                   cubit.deleteImage(imagePath);
//                   Navigator.pop(context); // Close dialog
//                 },
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _pickImage(
//     BuildContext context,
//     MarriageProfileCubit cubit,
//     MarriageUserProfileModel profile,
//   ) async {
//     final currentImageCount = profile.userMedia?.images.length ?? 0;

//     if (currentImageCount >= _maxImages) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         CustomSnackBar(
//           context,
//           text: 'الحد الأقصى للصور هو $_maxImages',
//           isError: true,
//         ),
//       );
//       return;
//     }

//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       cubit.uploadImage(File(image.path));
//     }
//   }

//   Widget _buildProfessionalInfoSection(
//     BuildContext context,
//     MarriageProfileCubit cubit,
//     MarriageUserProfileModel profile,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(10.w),
//       decoration: BoxDecoration(
//         color: AppColors.kWhiteColor,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'المعلومات المهنية',
//             style: Styles.textStyle18Meduim.copyWith(
//               color: AppColors.secondary800,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Gap(12.h),
//           _buildInfoRow(
//             'المؤهل',
//             profile.professionalLife?.educationLevel ?? 'اختر',
//             () {
//               _navigateToFieldSelection(
//                 context,
//                 cubit,
//                 'education_level',
//                 profile.professionalLife?.educationLevel,
//               );
//             },
//           ),
//           Gap(12.h),
//           _buildInfoRow('الوظيفة', profile.professionalLife?.job ?? 'اختر', () {
//             _navigateToFieldSelection(
//               context,
//               cubit,
//               'choose_job',
//               profile.professionalLife?.job,
//             );
//           }),
//           Gap(12.h),
//           _buildInfoRow(
//             'الجهة الموظفة',
//             profile.professionalLife?.chooseEmployer ?? 'اختر',
//             () {
//               _navigateToFieldSelection(
//                 context,
//                 cubit,
//                 'choose_employer',
//                 profile.professionalLife?.chooseEmployer,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGoalsSection(
//     BuildContext context,
//     MarriageProfileCubit cubit,
//     MarriageUserProfileModel profile,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(10.w),
//       decoration: BoxDecoration(
//         color: AppColors.kWhiteColor,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'أهدافي  ',
//             style: Styles.textStyle18Meduim.copyWith(
//               color: AppColors.secondary800,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Gap(12.h),
//           _buildInfoRow(
//             'الخطوبة',
//             profile.yourGoals?.engagement ?? 'اختر',
//             () {
//               _navigateToFieldSelection(
//                 context,
//                 cubit,
//                 'engagement',
//                 profile.yourGoals?.engagement,
//               );
//             },
//           ),
//           _buildInfoRow("الزواج", profile.yourGoals?.marry ?? 'اختر', () {
//             _navigateToFieldSelection(
//               context,
//               cubit,
//               'marry',
//               profile.yourGoals?.marry,
//             );
//           }),
//           _buildInfoRow("الاسرة", profile.yourGoals?.children ?? 'اختر', () {
//             _navigateToFieldSelection(
//               context,
//               cubit,
//               'children',
//               profile.yourGoals?.children,
//             );
//           }),
//           _buildInfoRow("السفر", profile.yourGoals?.travel ?? 'اختر', () {
//             _navigateToFieldSelection(
//               context,
//               cubit,
//               'travel',
//               profile.yourGoals?.travel,
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildkownmeMoreSection(
//     BuildContext context,
//     MarriageProfileCubit cubit,
//     MarriageUserProfileModel profile,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(10.w),
//       decoration: BoxDecoration(
//         color: AppColors.kWhiteColor,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "تعرف عليّ أكثر",
//             style: Styles.textStyle18Meduim.copyWith(
//               color: AppColors.secondary800,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Gap(12.h),
//           _buildInfoRow('السيرة الذاتية', profile.myDescription ?? 'اختر', () {
//             _navigateToBioEdit(context, cubit, profile.myDescription);
//           }),
//           _buildInfoRow(
//             'الاهتمامات',
//             profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : 'اختر',
//             () {
//               _navigateToFieldSelection(
//                 context,
//                 cubit,
//                 'interests',
//                 profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : null,
//               );
//             },
//           ),
//           _buildInfoRow(
//             'الهوايات',
//             profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : 'اختر',
//             () {
//               _navigateToFieldSelection(
//                 context,
//                 cubit,
//                 'hobbies',
//                 profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : null,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFamilyAndPreferencesSection(
//     BuildContext context,
//     MarriageProfileCubit cubit,
//     MarriageUserProfileModel profile,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(10.w),
//       decoration: BoxDecoration(
//         color: AppColors.kWhiteColor,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'المعلومات العائلية',
//             style: Styles.textStyle18Meduim.copyWith(
//               color: AppColors.secondary800,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Gap(12.h),
//           _buildInfoRow(
//             'الحالة الاجتماعية',
//             profile.aboutMe?.socialStatus ?? 'اختر',
//             () {
//               _navigateToFieldSelection(
//                 context,
//                 cubit,
//                 'maritalStatus',
//                 profile.aboutMe?.socialStatus,
//               );
//             },
//           ),
//           _buildInfoRow(
//             'لديك أطفال',
//             profile.family?.hasChildren ?? 'اختر',
//             () {
//               _navigateToFieldSelection(
//                 context,
//                 cubit,
//                 'hasChildren',
//                 profile.family?.hasChildren,
//               );
//             },
//           ),
//           _buildInfoRow(
//             'عدد الأطفال',
//             profile.family?.childrenNumber ?? 'اختر',
//             () {
//               _navigateToFieldSelection(
//                 context,
//                 cubit,
//                 'childrenNumber',
//                 profile.family?.childrenNumber,
//               );
//             },
//           ),
//           _buildInfoRow(
//             'يعيش الأطفال معك',
//             profile.family?.childrenLivingStatus ?? 'اختر',
//             () {
//               _navigateToFieldSelection(
//                 context,
//                 cubit,
//                 'childrenLiveWithYou',
//                 profile.family?.childrenLivingStatus,
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMediaSection(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: AppColors.kWhiteColor,
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: const Color.fromRGBO(252, 255, 255, 0.22)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'الفيديو',
//             style: Styles.textStyle18Meduim.copyWith(
//               color: AppColors.secondary800,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Gap(12.h),
//           Container(
//             padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
//             decoration: BoxDecoration(
//               color: AppColors.secondary50,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: AppColors.primary200, width: 1.w),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'ارفاق فيديو تعريفي',
//                   style: Styles.textStyle16.copyWith(
//                     color: AppColors.primary200,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 Icon(
//                   Icons.play_circle_outline,
//                   color: AppColors.primary200,
//                   size: 30.w,
//                 ),
//               ],
//             ),
//           ),
//           Gap(16.h),
//           Text(
//             'مقطع صوتي',
//             style: Styles.textStyle18Bold.copyWith(
//               color: AppColors.secondary800,
//             ),
//           ),
//           Gap(12.h),
//           Container(
//             padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
//             decoration: BoxDecoration(
//               color: AppColors.secondary50,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: AppColors.primary200, width: 1.w),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'ارفاق تسجيل صوتي',
//                   style: Styles.textStyle16.copyWith(
//                     color: AppColors.primary200,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 ),
//                 Icon(Icons.mic_none, color: AppColors.primary200, size: 30.w),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ⭐⭐⭐ زر الحفظ - FIXED
//   Widget _buildSaveButton(
//     BuildContext context,
//     MarriageProfileCubit cubit,
//     MarriageProfileState state,
//   ) {
//     return CustomBotton(
//       title: state.isUpdating ? 'جاري الحفظ...' : 'حفظ التغييرات',
//       onPressed: state.isUpdating
//           ? null
//           : () async {
//               // ✅ احفظ التعديلات
//               await cubit.saveProfile();
              
//               // ✅ انتظر حتى تنتهي عملية الحفظ
//               if (mounted && state.state == CubitStates.success) {
//                 // ✅ انتقل لصفحة العرض التي ستجلب البيانات الجديدة
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => MarriageFetchBody(),
//                   ),
//                 );
//               }
//             },
//       width: double.infinity,
//       height: 54.h,
//       useGradient: !state.isUpdating,
//     );
//   }

//   Widget _buildInfoRow(String label, String value, VoidCallback onTap) {
//     final isLongText = value.length > 30;

//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         color: AppColors.kWhiteColor,
//         padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (isLongText) ...[
//               Text(
//                 label,
//                 style: Styles.textStyle18.copyWith(
//                   color: AppColors.secondary800,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Gap(8.h),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: Text(
//                       value,
//                       textAlign: TextAlign.right,
//                       maxLines: 4,
//                       overflow: TextOverflow.ellipsis,
//                       style: Styles.textStyle16.copyWith(
//                         color: const Color.fromRGBO(60, 60, 67, 0.6),
//                       ),
//                     ),
//                   ),
//                   Gap(8.w),
//                   Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     size: 14.w,
//                     color: AppColors.secondary400,
//                   ),
//                 ],
//               ),
//             ] else ...[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     label,
//                     style: Styles.textStyle18.copyWith(
//                       color: AppColors.secondary800,
//                     ),
//                   ),
//                   Expanded(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         Flexible(
//                           child: Text(
//                             value,
//                             textAlign: TextAlign.right,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: Styles.textStyle16.copyWith(
//                               color: const Color.fromRGBO(60, 60, 67, 0.6),
//                             ),
//                           ),
//                         ),
//                         Gap(8.w),
//                         Icon(
//                           Icons.arrow_forward_ios_rounded,
//                           size: 14.w,
//                           color: AppColors.secondary400,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//             Gap(8.h),
//             Divider(color: AppColors.secondary100, height: 1),
//           ],
//         ),
//       ),
//     );
//   }

//   void _navigateToFieldSelection(
//     BuildContext context,
//     MarriageProfileCubit cubit,
//     String fieldKey,
//     String? currentValue,
//   ) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MarriageFieldSelectionView(
//           fieldName: fieldKey,
//           currentValue: currentValue,
//           onValueSelected: (value) {
//             cubit.updateField(fieldKey, value);
//           },
//         ),
//       ),
//     );
//   }

//   void _navigateToBioEdit(
//     BuildContext context,
//     MarriageProfileCubit cubit,
//     String? currentBio,
//   ) {
//     final TextEditingController controller = TextEditingController(
//       text: currentBio,
//     );

//     CustomSHowDetailsDialog(
//       context,
//       title: 'تعديل السيرة الذاتية',
//       contantWidget: TextField(
//         controller: controller,
//         maxLines: 5,
//         decoration: InputDecoration(
//           hintText: 'اكتب نبذة عنك...',
//           hintStyle: Styles.textStyle12.copyWith(color: Colors.grey),
//           border: InputBorder.none,
//         ),
//       ),
//       onSendPressed: () {
//         final newBio = controller.text.trim();
//         if (newBio.isNotEmpty) {
//           cubit.updateField('bio', newBio);
//           Navigator.pop(context);
//         }
//       },
//     );
//   }
// }
// // // features/user/user_profile/views/marriage_profile_edit_view.dart
// // // ✅ FIXED VERSION - All issues resolved

// // import 'package:tayseer/core/widgets/custom_show_dialog.dart';
// // import 'package:tayseer/core/widgets/custom_toggle_tab_bar.dart';
// // import 'package:tayseer/core/widgets/simple_app_bar.dart';
// // import 'package:tayseer/features/user/questions/refact_question/widget/custtom_image_grid.dart';

// // // import 'package:tayseer/features/user/marriage/view/widget/message_input_sectione_grid.dart';
// // import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
// // import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
// // import 'package:tayseer/features/user/user_profile/data/repositories/marriage_profile_repository.dart';
// // import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
// // import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
// // import 'package:tayseer/features/user/user_profile/views/widgets/marriage_fetch_body.dart';
// // import 'package:tayseer/features/user/user_profile/views/widgets/marriage_field_selection_view.dart';
// // import 'package:tayseer/my_import.dart';

// // class MarriageProfileEditView extends StatefulWidget {
// //   final UserProfileModel? userProfile;

// //   const MarriageProfileEditView({super.key, this.userProfile});

// //   @override
// //   State<MarriageProfileEditView> createState() =>
// //       _MarriageProfileEditViewState();
// // }

// // class _MarriageProfileEditViewState extends State<MarriageProfileEditView> {
// //   final ImagePicker _picker = ImagePicker();
// //   final int _maxImages = 5; // ✅ Maximum 5 images
// //   int _selectedTabIndex = 0;

// //   @override
// //   Widget build(BuildContext context) {
// //     return BlocProvider(
// //       create: (context) => MarriageProfileCubit(
// //         getIt<MarriageProfileRepository>(),
// //         initialUserProfile: widget.userProfile,
// //       )..loadProfile(),
// //       child: Scaffold(
// //         body: SafeArea(
// //           child: BlocConsumer<MarriageProfileCubit, MarriageProfileState>(
// //             listener: (context, state) {
// //               if (state.state == CubitStates.success &&
// //                   state.successMessage != null) {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   CustomSnackBar(
// //                     context,
// //                     text: state.successMessage!,
// //                     isSuccess: true,
// //                   ),
// //                 );
// //               }
// //               if (state.state == CubitStates.failure &&
// //                   state.errorMessage != null) {
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   CustomSnackBar(
// //                     context,
// //                     text: state.errorMessage!,
// //                     isError: true,
// //                   ),
// //                 );
// //               }
// //             },
// //             builder: (context, state) {
// //               final cubit = context.read<MarriageProfileCubit>();

// //               if (state.isLoading && state.profile == null) {
// //                 return const Center(child: CircularProgressIndicator());
// //               }

// //               if (state.state == CubitStates.failure && state.profile == null) {
// //                 return Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(
// //                         Icons.error_outline,
// //                         size: 64.w,
// //                         color: AppColors.errorColor,
// //                       ),
// //                       Gap(16.h),
// //                       Text(
// //                         state.errorMessage ?? 'حدث خطأ في تحميل البيانات',
// //                         textAlign: TextAlign.center,
// //                         style: Styles.textStyle16.copyWith(
// //                           color: AppColors.secondary600,
// //                         ),
// //                       ),
// //                       Gap(24.h),
// //                       CustomBotton(
// //                         title: 'رجوع',
// //                         onPressed: () => Navigator.pop(context),
// //                         width: 120.w,
// //                         height: 48.h,
// //                       ),
// //                     ],
// //                   ),
// //                 );
// //               }

// //               final profile = state.profile;

// //               if (profile == null) {
// //                 return Center(child: Text('لا توجد بيانات'));
// //               }

// //               return CustomScrollView(
// //                 slivers: [
// //                   SliverToBoxAdapter(
// //                     child: SimpleAppBar(
// //                       title: 'تعديل ملف الزواج',
// //                       isLargeTitle: true,
// //                     ),
// //                   ),
// //                   SliverToBoxAdapter(
// //                     child: Container(
// //                       padding: EdgeInsets.only(
// //                         top: MediaQuery.of(context).padding.top + 16.h,
// //                         left: 20.w,
// //                         right: 20.w,
// //                       ),
// //                       child: CustomToggleTabBar(
// //                         firstTabText: "عرض",
// //                         secondTabText: "تعديل",
// //                         initialIndex: _selectedTabIndex,
// //                         onTabChanged: (index) {
// //                           setState(() {
// //                             _selectedTabIndex = index;
// //                           });
// //                         },
// //                       ),
// //                     ),
// //                   ),
// //                   SliverToBoxAdapter(
// //                     child: Padding(
// //                       padding: EdgeInsets.symmetric(horizontal: 20.w),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Gap(24.h),
// //                           _buildPersonalInfoSection(context, cubit, profile),
// //                           Gap(20.h),
// //                           _buildImagesSection(context, cubit, profile),
// //                           Gap(24.h),
// //                           _buildProfessionalInfoSection(
// //                             context,
// //                             cubit,
// //                             profile,
// //                           ),

// //                           Gap(24.h),
// //                           _buildMediaSection(context),
// //                           Gap(24.h),
// //                           _buildFamilyAndPreferencesSection(
// //                             context,
// //                             cubit,
// //                             profile,
// //                           ),
// //                           Gap(24.h),
// //                           _buildGoalsSection(context, cubit, profile),
// //                           Gap(24.h),
// //                           _buildkownmeMoreSection(context, cubit, profile),
// //                           Gap(32.h),
// //                           _buildSaveButton(context, cubit, state),
// //                           Gap(100.h),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               );
// //             },
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildPersonalInfoSection(
// //     BuildContext context,
// //     MarriageProfileCubit cubit,
// //     MarriageUserProfileModel profile,
// //   ) {
// //     return Container(
// //       padding: EdgeInsets.all(10.w),
// //       decoration: BoxDecoration(
// //         color: AppColors.kWhiteColor,
// //         borderRadius: BorderRadius.circular(12.r),
// //         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'معلومات عني',
// //             style: Styles.textStyle18Meduim.copyWith(
// //               color: const Color.fromRGBO(0, 0, 0, 1),
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //           Gap(12.h),
// //           _buildInfoRow('البلد', profile.aboutMe!.country ?? 'اختر', () {
// //             _navigateToFieldSelection(
// //               context,
// //               cubit,
// //               'country',
// //               profile.aboutMe!.country,
// //             );
// //           }),
// //           _buildInfoRow('الجنسية', profile.aboutMe!.nationality ?? 'اختر', () {
// //             _navigateToFieldSelection(
// //               context,
// //               cubit,
// //               'nationality',
// //               profile.aboutMe!.nationality,
// //             );
// //           }),
// //           _buildInfoRow('الطول', profile.aboutMe!.height ?? 'اختر', () {
// //             _navigateToFieldSelection(
// //               context,
// //               cubit,
// //               'height',
// //               profile.aboutMe!.height,
// //             );
// //           }),
// //           _buildInfoRow('الوزن', profile.aboutMe!.weight ?? 'اختر', () {
// //             _navigateToFieldSelection(
// //               context,
// //               cubit,
// //               'weight',
// //               profile.aboutMe!.weight,
// //             );
// //           }),
// //           _buildInfoRow('لون البشرة', profile.aboutMe!.skinColor ?? 'اختر', () {
// //             _navigateToFieldSelection(
// //               context,
// //               cubit,
// //               'skinColor',
// //               profile.aboutMe!.skinColor,
// //             );
// //           }),
// //           _buildInfoRow(
// //             'الحالة الصحية',
// //             profile.aboutMe!.healthStatus ?? 'اختر',
// //             () {
// //               _navigateToFieldSelection(
// //                 context,
// //                 cubit,
// //                 'healthStatus',
// //                 profile.aboutMe!.healthStatus,
// //               );
// //             },
// //           ),
// //           _buildInfoRow(
// //             'الالتزام الديني',
// //             profile.aboutMe!.religiousCommitment ?? 'اختر',
// //             () {
// //               _navigateToFieldSelection(
// //                 context,
// //                 cubit,
// //                 'religiousCommitment',
// //                 profile.aboutMe!.religiousCommitment,
// //               );
// //             },
// //           ),
// //           _buildInfoRow('التدخين', profile.aboutMe!.smoker ?? 'اختر', () {
// //             _navigateToFieldSelection(
// //               context,
// //               cubit,
// //               'smoker',
// //               profile.aboutMe!.smoker,
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }

// //   // ✅ FIXED: _buildImagesSection method only

// //   Widget _buildImagesSection(
// //     BuildContext context,
// //     MarriageProfileCubit cubit,
// //     MarriageUserProfileModel profile,
// //   ) {
// //     // Get last 5 images
// //     final allImages = profile.userMedia?.images ?? [];
// //     final displayImages = allImages.length > 5
// //         ? allImages.sublist(allImages.length - 5)
// //         : allImages;

// //     return Container(
// //       padding: EdgeInsets.all(10.w),
// //       decoration: BoxDecoration(
// //         color: AppColors.kWhiteColor,
// //         borderRadius: BorderRadius.circular(12.r),
// //         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'الصور (آخر ${displayImages.length} صور)',
// //             style: Styles.textStyle18Meduim.copyWith(
// //               color: const Color.fromRGBO(0, 0, 0, 1),
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //           Gap(12.h),
// //           CusttomImageGrid(
// //             imageUrls: displayImages,
// //             // ✅ FIX: Always provide a function, not null
// //             onAdd: () {
// //               if (displayImages.length < _maxImages) {
// //                 _pickImage(context, cubit, profile);
// //               } else {
// //                 // Show message that max images reached
// //                 ScaffoldMessenger.of(context).showSnackBar(
// //                   CustomSnackBar(
// //                     context,
// //                     text: 'الحد الأقصى للصور هو $_maxImages',
// //                     isError: true,
// //                   ),
// //                 );
// //               }
// //             },
// //             onRemove: (index) {
// //               // Calculate the real index in the full list
// //               final realIndex = allImages.length - displayImages.length + index;
// //               final imagePath = allImages[realIndex];

// //               // ✅ Show confirmation dialog before deleting
// //               CustomshowDialogWithImage(
// //                 context,
// //                 title: 'حذف الصورة',
// //                 supTitle: 'هل أنت متأكد من حذف هذه الصورة؟',
// //                 icon: Icons.delete_outline,
// //                 iconColor: Colors.red,
// //                 iconBackgroundColor: Colors.red.withOpacity(0.1),
// //                 bottonText: 'حذف',
// //                 showCancelButton: true,
// //                 cancelText: 'إلغاء',
// //                 onPressed: () {
// //                   cubit.deleteImage(imagePath);
// //                 },
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Future<void> _pickImage(
// //     BuildContext context,
// //     MarriageProfileCubit cubit,
// //     MarriageUserProfileModel profile,
// //   ) async {
// //     final currentImageCount = profile.userMedia?.images.length ?? 0;

// //     if (currentImageCount >= _maxImages) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         CustomSnackBar(
// //           context,
// //           text: 'الحد الأقصى للصور هو $_maxImages',
// //           isError: true,
// //         ),
// //       );
// //       return;
// //     }

// //     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
// //     if (image != null) {
// //       cubit.uploadImage(File(image.path));
// //     }
// //   }

// //   Widget _buildProfessionalInfoSection(
// //     BuildContext context,
// //     MarriageProfileCubit cubit,
// //     MarriageUserProfileModel profile,
// //   ) {
// //     return Container(
// //       padding: EdgeInsets.all(10.w),
// //       decoration: BoxDecoration(
// //         color: AppColors.kWhiteColor,
// //         borderRadius: BorderRadius.circular(12.r),
// //         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'المعلومات المهنية',
// //             style: Styles.textStyle18Meduim.copyWith(
// //               color: AppColors.secondary800,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //           Gap(12.h),
// //           _buildInfoRow(
// //             'المؤهل',
// //             profile.professionalLife!.educationLevel ?? 'اختر',
// //             () {
// //               _navigateToFieldSelection(
// //                 context,
// //                 cubit,
// //                 'education_level',
// //                 profile.professionalLife!.educationLevel,
// //               );
// //             },
// //           ),
// //           Gap(12.h),
// //           _buildInfoRow('الوظيفة', profile.professionalLife!.job ?? 'اختر', () {
// //             _navigateToFieldSelection(
// //               context,
// //               cubit,
// //               'choose_job',
// //               profile.professionalLife!.job,
// //             );
// //           }),
// //           Gap(12.h),
// //           _buildInfoRow(
// //             'الجهة الموظفة',
// //             profile.professionalLife!.chooseEmployer ?? 'اختر',
// //             () {
// //               _navigateToFieldSelection(
// //                 context,
// //                 cubit,
// //                 'choose_employer',
// //                 profile.professionalLife!.chooseEmployer,
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildGoalsSection(
// //     BuildContext context,
// //     MarriageProfileCubit cubit,
// //     MarriageUserProfileModel profile,
// //   ) {
// //     return Container(
// //       padding: EdgeInsets.all(10.w),
// //       decoration: BoxDecoration(
// //         color: AppColors.kWhiteColor,
// //         borderRadius: BorderRadius.circular(12.r),
// //         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'أهدافي  ',
// //             style: Styles.textStyle18Meduim.copyWith(
// //               color: AppColors.secondary800,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //           Gap(12.h),
// //           _buildInfoRow(
// //             ' الخطوبة',
// //             profile.yourGoals!.engagement ?? 'اختر',
// //             () {
// //               _navigateToFieldSelection(
// //                 context,
// //                 cubit,
// //                 'engagement',
// //                 profile.yourGoals!.engagement,
// //               );
// //             },
// //           ),
// //           _buildInfoRow("الزواج", profile.yourGoals!.marry ?? 'اختر', () {
// //             _navigateToFieldSelection(
// //               context,
// //               cubit,
// //               'marry',
// //               profile.yourGoals!.marry,
// //             );
// //           }),
// //           _buildInfoRow("الاسرة", profile.yourGoals!.children ?? 'اختر', () {
// //             _navigateToFieldSelection(
// //               context,
// //               cubit,
// //               'children',
// //               profile.yourGoals!.children,
// //             );
// //           }),
// //           _buildInfoRow("السفر", profile.yourGoals!.travel ?? 'اختر', () {
// //             _navigateToFieldSelection(
// //               context,
// //               cubit,
// //               'travel',
// //               profile.yourGoals!.travel,
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// //   Widget _buildkownmeMoreSection(
// //     BuildContext context,
// //     MarriageProfileCubit cubit,
// //     MarriageUserProfileModel profile,
// //   ) {
// //     return Container(
// //       padding: EdgeInsets.all(10.w),
// //       decoration: BoxDecoration(
// //         color: AppColors.kWhiteColor,
// //         borderRadius: BorderRadius.circular(12.r),
// //         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             "تعرف عليّ أكثر",
// //             style: Styles.textStyle18Meduim.copyWith(
// //               color: AppColors.secondary800,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //           Gap(12.h),
// //           // ✅ FIXED: Bio editing
// //           _buildInfoRow('السيرة الذاتية', profile.myDescription ?? 'اختر', () {
// //             _navigateToBioEdit(context, cubit, profile.myDescription);
// //           }),
// //           _buildInfoRow(
// //             'الاهتمامات',
// //             profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : 'اختر',
// //             () {
// //               _navigateToFieldSelection(
// //                 context,
// //                 cubit,
// //                 'interests',
// //                 profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : null,
// //               );
// //             },
// //           ),
// //           _buildInfoRow(
// //             'الهوايات',
// //             profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : 'اختر',
// //             () {
// //               _navigateToFieldSelection(
// //                 context,
// //                 cubit,
// //                 'hobbies',
// //                 profile.hobbies.isNotEmpty ? profile.hobbies.join(', ') : null,
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildFamilyAndPreferencesSection(
// //     BuildContext context,
// //     MarriageProfileCubit cubit,
// //     MarriageUserProfileModel profile,
// //   ) {
// //     return Container(
// //       padding: EdgeInsets.all(10.w),
// //       decoration: BoxDecoration(
// //         color: AppColors.kWhiteColor,
// //         borderRadius: BorderRadius.circular(12.r),
// //         border: Border.all(color: const Color.fromRGBO(251, 251, 251, 0.64)),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'المعلومات العائلية',
// //             style: Styles.textStyle18Meduim.copyWith(
// //               color: AppColors.secondary800,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //           Gap(12.h),
// //           _buildInfoRow(
// //             'الحالة الاجتماعية',
// //             profile.aboutMe!.socialStatus ?? 'اختر',
// //             () {
// //               _navigateToFieldSelection(
// //                 context,
// //                 cubit,
// //                 'maritalStatus',
// //                 profile.aboutMe!.socialStatus,
// //               );
// //             },
// //           ),
// //           _buildInfoRow(
// //             'لديك أطفال',
// //             profile.family!.hasChildren ?? 'اختر',
// //             () {
// //               _navigateToFieldSelection(
// //                 context,
// //                 cubit,
// //                 'hasChildren',
// //                 profile.family!.hasChildren,
// //               );
// //             },
// //           ),
// //           _buildInfoRow(
// //             'عدد الأطفال',
// //             profile.family!.childrenNumber ?? 'اختر',
// //             () {
// //               _navigateToFieldSelection(
// //                 context,
// //                 cubit,
// //                 'childrenNumber',
// //                 profile.family!.childrenNumber,
// //               );
// //             },
// //           ),
// //           _buildInfoRow(
// //             'يعيش الأطفال معك',
// //             profile.family!.childrenLivingStatus ?? 'اختر',
// //             () {
// //               _navigateToFieldSelection(
// //                 context,
// //                 cubit,
// //                 'childrenLiveWithYou',
// //                 profile.family!.childrenLivingStatus,
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildMediaSection(BuildContext context) {
// //     return Container(
// //       padding: EdgeInsets.all(12.w),
// //       decoration: BoxDecoration(
// //         color: AppColors.kWhiteColor,
// //         borderRadius: BorderRadius.circular(12.r),
// //         border: Border.all(color: const Color.fromRGBO(252, 255, 255, 0.22)),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'الفيديو',
// //             style: Styles.textStyle18Meduim.copyWith(
// //               color: AppColors.secondary800,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //           Gap(12.h),
// //           Container(
// //             padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
// //             decoration: BoxDecoration(
// //               color: AppColors.secondary50,
// //               borderRadius: BorderRadius.circular(12.r),
// //               border: Border.all(color: AppColors.primary200, width: 1.w),
// //             ),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   'ارفاق فيديو تعريفي',
// //                   style: Styles.textStyle16.copyWith(
// //                     color: AppColors.primary200,
// //                     fontWeight: FontWeight.w400,
// //                   ),
// //                 ),
// //                 Icon(
// //                   Icons.play_circle_outline,
// //                   color: AppColors.primary200,
// //                   size: 30.w,
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Gap(16.h),
// //           Text(
// //             'مقطع صوتي',
// //             style: Styles.textStyle18Bold.copyWith(
// //               color: AppColors.secondary800,
// //             ),
// //           ),
// //           Gap(12.h),
// //           Container(
// //             padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
// //             decoration: BoxDecoration(
// //               color: AppColors.secondary50,
// //               borderRadius: BorderRadius.circular(12.r),
// //               border: Border.all(color: AppColors.primary200, width: 1.w),
// //             ),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   'ارفاق تسجيل صوتي',
// //                   style: Styles.textStyle16.copyWith(
// //                     color: AppColors.primary200,
// //                     fontWeight: FontWeight.w400,
// //                   ),
// //                 ),
// //                 Icon(Icons.mic_none, color: AppColors.primary200, size: 30.w),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSaveButton(
// //     BuildContext context,
// //     MarriageProfileCubit cubit,
// //     MarriageProfileState state,
// //   ) {
// //     return CustomBotton(
// //       title: state.isUpdating ? 'جاري الحفظ...' : 'حفظ التغييرات',
// //       onPressed: state.isUpdating
// //           ? null
// //           : () async {
// //               // ✅ FIXED: Actually save then navigate
// //               await cubit.saveProfile();
// //               if (mounted && state.state == CubitStates.success) {
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(builder: (context) => MarriageFetchBody()),
// //                 );
// //               }
// //             },
// //       width: double.infinity,
// //       height: 54.h,
// //       useGradient: !state.isUpdating,
// //     );
// //   }

// //   Widget _buildInfoRow(String label, String value, VoidCallback onTap) {
// //     final isLongText = value.length > 30;

// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         color: AppColors.kWhiteColor,
// //         padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             if (isLongText) ...[
// //               Text(
// //                 label,
// //                 style: Styles.textStyle18.copyWith(
// //                   color: AppColors.secondary800,
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //               Gap(8.h),
// //               Row(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Expanded(
// //                     child: Text(
// //                       value,
// //                       textAlign: TextAlign.right,
// //                       maxLines: 4,
// //                       overflow: TextOverflow.ellipsis,
// //                       style: Styles.textStyle16.copyWith(
// //                         color: const Color.fromRGBO(60, 60, 67, 0.6),
// //                       ),
// //                     ),
// //                   ),
// //                   Gap(8.w),
// //                   Icon(
// //                     Icons.arrow_forward_ios_rounded,
// //                     size: 14.w,
// //                     color: AppColors.secondary400,
// //                   ),
// //                 ],
// //               ),
// //             ] else ...[
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 crossAxisAlignment: CrossAxisAlignment.center,
// //                 children: [
// //                   Text(
// //                     label,
// //                     style: Styles.textStyle18.copyWith(
// //                       color: AppColors.secondary800,
// //                     ),
// //                   ),
// //                   Expanded(
// //                     child: Row(
// //                       mainAxisAlignment: MainAxisAlignment.end,
// //                       children: [
// //                         Flexible(
// //                           child: Text(
// //                             value,
// //                             textAlign: TextAlign.right,
// //                             maxLines: 2,
// //                             overflow: TextOverflow.ellipsis,
// //                             style: Styles.textStyle16.copyWith(
// //                               color: const Color.fromRGBO(60, 60, 67, 0.6),
// //                             ),
// //                           ),
// //                         ),
// //                         Gap(8.w),
// //                         Icon(
// //                           Icons.arrow_forward_ios_rounded,
// //                           size: 14.w,
// //                           color: AppColors.secondary400,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //             Gap(8.h),
// //             Divider(color: AppColors.secondary100, height: 1),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   void _navigateToFieldSelection(
// //     BuildContext context,
// //     MarriageProfileCubit cubit,
// //     String fieldKey,
// //     String? currentValue,
// //   ) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => MarriageFieldSelectionView(
// //           fieldName: fieldKey,
// //           currentValue: currentValue,
// //           onValueSelected: (value) {
// //             cubit.updateField(fieldKey, value);
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   // ✅ NEW: Dedicated bio editing dialog
// //   void _navigateToBioEdit(
// //     BuildContext context,
// //     MarriageProfileCubit cubit,
// //     String? currentBio,
// //   ) {
// //     final TextEditingController controller = TextEditingController(
// //       text: currentBio,
// //     );

// //     CustomSHowDetailsDialog(
// //       context,
// //       title: 'تعديل السيرة الذاتية',
// //       contantWidget: TextField(
// //         controller: controller,
// //         maxLines: 5,
// //         decoration: InputDecoration(
// //           hintText: 'اكتب نبذة عنك...',
// //           hintStyle: Styles.textStyle12.copyWith(color: Colors.grey),
// //           border: InputBorder.none,
// //         ),
// //       ),
// //       onSendPressed: () {
// //         final newBio = controller.text.trim();
// //         if (newBio.isNotEmpty) {
// //           cubit.updateField('bio', newBio);
// //           Navigator.pop(context);
// //         }
// //       },
// //     );
// //   }
// // }
