import 'package:flutter/material.dart';
import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/my_import.dart';

class EditDescriptionView extends StatefulWidget {
  final UserProfileModel initialProfile;
  final Function(UserProfileModel) onProfileUpdated;

  const EditDescriptionView({
    super.key,
    required this.initialProfile,
    required this.onProfileUpdated,
  });

  @override
  State<EditDescriptionView> createState() => _EditDescriptionViewState();
}

class _EditDescriptionViewState extends State<EditDescriptionView> {
  late TextEditingController _descriptionController;
  late bool _isLoading;
  bool _isAiGenerated = false;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialProfile.description ?? '',
    );
    _isLoading = false;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateDescription() async {
    final newDescription = _descriptionController.text.trim();
    if (newDescription == (widget.initialProfile.description ?? '')) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.patch(
        endPoint: '/user/update-profile',
        isFromData: true,
        data: {'mydescription': newDescription},
      );

      if (response['success'] == true) {
        final updatedProfile = widget.initialProfile.copyWith(
          description: newDescription,
        );
        widget.onProfileUpdated(updatedProfile);

        AppToast.success(context, 'تم تحديث النبذة التعريفية بنجاح');
        Navigator.pop(context);
      } else {
        AppToast.error(
          context,
          response['message'] ?? 'فشل تحديث النبذة التعريفية',
        );
      }
    } catch (e) {
      AppToast.error(context, 'حدث خطأ: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateWithAI() async {
    // هنا يمكنك إضافة منطق توليد النص بالذكاء الاصطناعي
    setState(() {
      _descriptionController.text = 'نبذة تعريفية مولد بالذكاء الاصطناعي';
      _isAiGenerated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SimpleAppBar(title: 'تعديل النبذة التعريفية', isLargeTitle: true),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان والوصف
                    Text(
                      'النبذة التعريفية',
                      style: Styles.textStyle16Meduim.copyWith(
                        color: AppColors.secondary800,
                      ),
                    ),
                    Gap(8.h),
                    Text(
                      'اخبرنا عن نفسك اكثر',
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.secondary400,
                      ),
                    ),
                    Gap(32.h),

                    // حقل النص
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary50,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.secondary200),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          style: Styles.textStyle16.copyWith(
                            color: AppColors.secondary800,
                          ),
                          maxLines: null,
                          maxLength: 200,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(16.w),
                            border: InputBorder.none,
                            hintText: 'أخبرنا عن نفسك...',
                            hintStyle: Styles.textStyle16.copyWith(
                              color: AppColors.secondary400,
                            ),
                            counterText: '',
                          ),
                        ),
                      ),
                    ),
                    Gap(8.h),

                    // صف الأزرار
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر التوليد بالذكاء الاصطناعي
                        if (!_isAiGenerated)
                          InkWell(
                            onTap: _generateWithAI,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 16.w,
                                  color: AppColors.primary500,
                                ),
                                Gap(4.w),
                                Text(
                                  'كتابة بواسطة الذكاء الاصطناعي',
                                  style: Styles.textStyle12.copyWith(
                                    color: AppColors.primary500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // عداد الأحرف
                        Text(
                          '${_descriptionController.text.length}/200',
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.secondary400,
                          ),
                        ),
                      ],
                    ),

                    Gap(32.h),

                    // زر التأكيد
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: CustomBotton(
                        width: double.infinity,
                        title: 'تأكيد',
                        onPressed: _isLoading ? null : _updateDescription,
                        isLoading: _isLoading,
                        backGroundcolor: AppColors.kprimaryColor,
                        titleColor: AppColors.kWhiteColor,
                        radius: 10.r,
                        useGradient: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
