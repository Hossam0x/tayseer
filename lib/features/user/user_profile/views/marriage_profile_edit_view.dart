// features/user/user_profile/views/marriage_profile_edit_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/widgets/custom_content_switcher.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_marriage_model.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/features/user/user_profile/data/repositories/marriage_profile_repository.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_cubit.dart';
import 'package:tayseer/features/user/user_profile/views/cubit/MarriageProfilecubit/marriage_profile_state.dart';
import 'package:tayseer/features/user/user_profile/views/widgets/marriage_field_selection_view.dart';
import 'package:tayseer/my_import.dart';

class MarriageProfileEditView extends StatefulWidget {
  final UserProfileModel? userProfile; // ⭐ نستقبل UserProfileModel

  const MarriageProfileEditView({super.key, this.userProfile});

  @override
  State<MarriageProfileEditView> createState() =>
      _MarriageProfileEditViewState();
}

class _MarriageProfileEditViewState extends State<MarriageProfileEditView> {
  final ImagePicker _picker = ImagePicker();
  List<String> _marriageImages = [];
  final int _maxImages = 3;
  String _selectedTab = 'تعديل';
  // ⭐ تحويل UserProfileModel إلى MarriageUserProfileModel
  MarriageUserProfileModel _convertToMarriageModel(UserProfileModel? user) {
    if (user == null) {
      return MarriageUserProfileModel(
        id: '',
        name: '',
        username: '',
        isMe: true,
        isAvailableForMarriage: false,
      );
    }

    return MarriageUserProfileModel(
      id: user.id,
      name: user.name,
      username: user.username,
      description: user.description,
      image: user.image,
      following: user.following,
      followers: user.followers,
      isMe: user.isMe,
      isVerified: user.isVerified,
      location: user.location,
      isAvailableForMarriage: user.avaliableForMarry ?? false,
      // createdAt: user.createdAt,
      // updatedAt: user.updatedAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MarriageProfileCubit(getIt<MarriageProfileRepository>())
            ..loadProfile(),
      child: Scaffold(
        // backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // الخلفية الكاملة في الخلف
              Positioned.fill(
                child: Image.asset(
                  AssetsData.userBGImage,
                  fit: BoxFit.cover,
                ),
              ),

              BlocConsumer<MarriageProfileCubit, MarriageProfileState>(
                listener: (context, state) {
                  if (state.state == CubitStates.success &&
                      state.successMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(
                        context,
                        text: state.successMessage!,
                        isSuccess: true,
                      ),
                    );
                  }
                  if (state.state == CubitStates.failure &&
                      state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      CustomSnackBar(
                        context,
                        text: state.errorMessage!,
                        isError: true,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final cubit = context.read<MarriageProfileCubit>();

                  // ⭐ استخدام البروفايل من الـ state أو التحويل من UserProfileModel
                  final marriageProfile =
                      state.profile ??
                      _convertToMarriageModel(widget.userProfile);

                  if (_marriageImages.isEmpty &&
                      marriageProfile.marriageImages.isNotEmpty) {
                    _marriageImages = List.from(marriageProfile.marriageImages);
                  }

                  return CustomScrollView(
                    slivers: [
                      // App Bar
                      SliverToBoxAdapter(
                        child: SimpleAppBar(
                          title: 'تعديل ملف الزواج',
                          isLargeTitle: true,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 16.h,
                            left: 20.w,
                            right: 20.w,
                          ),
                          child: ContentSwitcher(
                            selectedOption: _selectedTab,
                            options: const [ 'عرض', 'تعديل'],
                            onOptionSelected: (String selectedOption) {
                              setState(() {
                                _selectedTab = selectedOption.trim();
                              });
                            },
                          ),
                        ),
                      ),
                      // Content
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Gap(24.h),
                              // ⭐ قسم المعلومات الشخصية
                              _buildPersonalInfoSection(
                                context,
                                cubit,
                                marriageProfile,
                              ),
                              Gap(20.h),

                              // ⭐ قسم الصور
                              _buildImagesSection(
                                context,
                                cubit,
                                marriageProfile,
                              ),
                              Gap(24.h),

                              // ⭐ قسم المعلومات المهنية
                              _buildProfessionalInfoSection(
                                context,
                                cubit,
                                marriageProfile,
                              ),
                              Gap(24.h),

                              // ⭐ قسم الأهداف
                              _buildGoalsSection(
                                context,
                                cubit,
                                marriageProfile,
                              ),
                              Gap(24.h),

                              // ⭐ قسم الفيديو والصوت
                              _buildMediaSection(context),
                              Gap(24.h),
                              // ⭐ قسم المعلومات العائلية والتفضيلات
                              _buildFamilyAndPreferencesSection(
                                context,
                                cubit,
                                marriageProfile,
                              ),
                              Gap(32.h),

                              Gap(32.h),

                              // ⭐ زر الحفظ
                              _buildSaveButton(context, cubit, state),
                              Gap(100.h),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
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
          // ===== المعلومات العائلية =====
          Text(
            'المعلومات العائلية',
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap(12.h),

          _buildInfoRow(
            'الحالة الاجتماعية',
            profile.maritalStatus ?? 'لا يوجد تفضيل',
            () {},
          ),
          _buildInfoRow('متزوج سابقًا', profile.maritalStatus ?? 'لا', () {}),
          _buildInfoRow('لديك أطفال', profile.maritalStatus ?? 'لا', () {}),
          _buildInfoRow(
            'عدد الأطفال',
            profile.maritalStatus ?? 'لا يوجد تفضيل',
            () {},
          ),
          _buildInfoRow(
            'يعيش الأطفال معك',
            profile.maritalStatus ?? 'لا',
            () {},
          ),

          Gap(20.h),

          // ===== الأهداف =====
          Text(
            'الأهداف',
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap(12.h),

          _buildInfoRow('تواصل', 'خلال 3 شهور', () {}),
          _buildInfoRow('الخطوبة', 'خلال 3 شهور', () {}),
          _buildInfoRow('الزواج', 'خلال 3 شهور', () {}),
          _buildInfoRow('الأسرة', 'لا يرغب أطفال', () {}),
          _buildInfoRow('السفر', 'ينوي السفر للخارج', () {}),

          Gap(20.h),

          // ===== تعرف عليّ أكثر =====
          Text(
            'تعرف عليّ أكثر',
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap(12.h),

          _buildInfoRow(
            'السيرة الذاتية',
            profile.maritalStatus ?? 'أهلاً بك في تايسر…',
            () {},
          ),
          _buildInfoRow('الاهتمامات', profile.maritalStatus ?? 'الصيد', () {}),
          _buildInfoRow('الهوايات', profile.maritalStatus ?? 'الرماية', () {}),
        ],
      ),
    );
  }

  // ⭐ قسم الصور
  Widget _buildImagesSection(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageUserProfileModel profile,
  ) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,

        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color.fromRGBO(251, 251, 251, 0.64)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الصور',
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap(12.h),

          // Grid للصور
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1,
            ),
            itemCount: _maxImages,
            itemBuilder: (context, index) {
              if (index < _marriageImages.length) {
                return _buildImageItem(
                  context,
                  cubit,
                  _marriageImages[index],
                  index,
                );
              } else {
                return _buildAddImageButton(context, cubit);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(
    BuildContext context,
    MarriageProfileCubit cubit,
    String imageUrl,
    int index,
  ) {
    final isLocalFile =
        imageUrl.startsWith('/') || imageUrl.startsWith('file://');

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary100, width: 2),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: isLocalFile
                ? Image.file(
                    File(imageUrl),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.secondary100,
                        child: Icon(
                          Icons.broken_image,
                          color: AppColors.secondary400,
                          size: 32.w,
                        ),
                      );
                    },
                  ),
          ),
          Positioned(
            top: 4.h,
            left: 4.w,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _marriageImages.removeAt(index);
                });
                cubit.deleteImage(imageUrl);
              },
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.kRedColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 16.w),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(
    BuildContext context,
    MarriageProfileCubit cubit,
  ) {
    return GestureDetector(
      onTap: () => _pickImage(context, cubit),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.primary100.withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
          ),
          color: AppColors.primary100.withOpacity(0.1),
        ),
        child: Center(
          child: Icon(
            Icons.add_rounded,
            color: AppColors.primary100,
            size: 32.w,
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    MarriageProfileCubit cubit,
  ) async {
    if (_marriageImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          context,
          text: 'الحد الأقصى للصور هو $_maxImages',
          isError: true,
        ),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _marriageImages.add(image.path);
      });
      cubit.uploadImage(File(image.path));
    }
  }

  // ⭐ قسم المعلومات الشخصية
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
        border: Border.all(color: Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات عني',
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap(12.h),

          _buildInfoRow('البلد', profile.country ?? 'مصر', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'country',
              profile.country,
            );
          }),
          Gap(12.h),

          _buildInfoRow('الجنسية', profile.nationality ?? 'مصري', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'nationality',
              profile.nationality,
            );
          }),
          Gap(12.h),

          _buildInfoRow('الدين', profile.religion ?? 'مسلم', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'religion',
              profile.religion,
            );
          }),
          Gap(12.h),

          _buildInfoRow('السن', profile.age?.toString() ?? 'غير محدد', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'age',
              profile.age?.toString(),
            );
          }),
          Gap(12.h),

          _buildInfoRow('الطول', profile.height ?? '160 سم', () {
            _navigateToFieldSelection(context, cubit, 'height', profile.height);
          }),
          Gap(12.h),

          _buildInfoRow('لون البشرة', profile.ethnicity ?? 'قمحاوي', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'ethnicity',
              profile.ethnicity,
            );
          }),
          Gap(12.h),

          _buildInfoRow('الحالة الصحية', profile.maritalStatus ?? 'سليم', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'maritalStatus',
              profile.maritalStatus,
            );
          }),
          Gap(12.h),

          _buildInfoRow('الالتزام الديني', profile.religiosity ?? 'ملتزم', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'religiosity',
              profile.religiosity,
            );
          }),
          Gap(12.h),

          _buildInfoRow('التدخين', profile.smoking ?? 'لا', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'smoking',
              profile.smoking,
            );
          }),
        ],
      ),
    );
  }

  // ⭐ قسم المعلومات المهنية
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
        border: Border.all(color: Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلومات المهنية',
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap(12.h),

          _buildInfoRow('الوظيفة', profile.occupation ?? 'لا يوجد تفضيل', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'occupation',
              profile.occupation,
            );
          }),
          Gap(12.h),

          _buildInfoRow('الوصف الوظيفي', profile.jobTitle ?? 'لا يوجد', () {
            _navigateToFieldSelection(
              context,
              cubit,
              'jobTitle',
              profile.jobTitle,
            );
          }),
          Gap(12.h),

          _buildInfoRow(
            'الدرجة الوظيفية',
            profile.professionalLevel ?? 'موظف',
            () {
              _navigateToFieldSelection(
                context,
                cubit,
                'professionalLevel',
                profile.professionalLevel,
              );
            },
          ),
        ],
      ),
    );
  }

  // ⭐ قسم الأهداف
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
        border: Border.all(color: Color.fromRGBO(251, 251, 251, 0.64)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأهداف',
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap(12.h),

          _buildInfoRow('تواصل', profile.financialStatus ?? 'خلال 3 شهور', () {
            // TODO: Add communication timeline picker
          }),
          Gap(12.h),

          _buildInfoRow(
            'الخطوبة',
            profile.financialStatus ?? 'خلال 3 شهور',
            () {
              // TODO: Add engagement timeline picker
            },
          ),
          Gap(12.h),

          _buildInfoRow('الزواج', profile.financialStatus ?? 'خلال 3 شهور', () {
            // TODO: Add marriage timeline picker
          }),
          Gap(12.h),

          _buildInfoRow(
            'المهر',
            profile.financialStatus ?? 'لا يوجد تفضيل',
            () {
              // TODO: Add dowry editor
            },
          ),
          Gap(12.h),

          _buildInfoRow('السفر', profile.location ?? 'يوافق السفر للخارج', () {
            // TODO: Add travel preference picker
          }),
        ],
      ),
    );
  }

  // ⭐ قسم الميديا
  Widget _buildMediaSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,

        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color.fromRGBO(251, 251, 251, 0.64)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الفيديو',
            style: Styles.textStyle18Meduim.copyWith(
              color: AppColors.secondary800,
              fontWeight: FontWeight.w500,
            ),
          ),
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
                Text(
                  'ارفاق فيديو تعريفي',
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.primary200,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(
                  Icons.play_circle_outline,
                  color: AppColors.primary200,
                  size: 30.w,
                ),
              ],
            ),
          ),
          Gap(16.h),

          Text(
            'مقطع صوتي',
            style: Styles.textStyle18Bold.copyWith(
              color: AppColors.secondary800,
            ),
          ),
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
                Text(
                  'ارفاق تسجيل صوتي',
                  style: Styles.textStyle16.copyWith(
                    color: AppColors.primary200,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(Icons.mic_none, color: AppColors.primary200, size: 30.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ زر الحفظ
  Widget _buildSaveButton(
    BuildContext context,
    MarriageProfileCubit cubit,
    MarriageProfileState state,
  ) {
    return CustomBotton(
      title: state.isUpdating ? 'جاري الحفظ...' : 'حفظ التغييرات',
      onPressed: state.isUpdating
          ? () {}
          : () async {
              await cubit.saveProfile();
              if (mounted && state.state == CubitStates.success) {
                Navigator.pop(context);
              }
            },
      width: double.infinity,
      height: 54.h,
      useGradient: true,
    );
  }

  // ⭐ صف المعلومات
  Widget _buildInfoRow(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
        decoration: BoxDecoration(
          // color: AppColors.secondary50,
          borderRadius: BorderRadius.circular(12.r),
          // border: Border.all(color: AppColors.secondary200),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Styles.textStyle18.copyWith(
                    color: AppColors.secondary800,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      value,
                      style: Styles.textStyle16.copyWith(
                        color: Color.fromRGBO(60, 60, 67, 0.6),
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
              ],
            ),
            Divider(color: AppColors.secondary100),
          ],
        ),
      ),
    );
  }

  // ⭐ الانتقال لاختيار حقل
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
}
