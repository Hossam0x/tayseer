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

  // متغير لعرض عدد الأحرف الحالي
  int get _currentCharacterCount => _descriptionController.text.length;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(
      text: widget.initialProfile.description ?? '',
    );
    _isLoading = false;

    // إضافة مستمع للتغيرات في النص
    _descriptionController.addListener(() {
      // تحديث الواجهة عند كل تغيير في النص
      if (mounted) {
        setState(() {});
      }
    });
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

        // ⭐ UserModel لا يحتوي على description، لكن نحدث الـ profile
        debugPrint('✅ تم تحديث النبذة التعريفية: $newDescription');

        widget.onProfileUpdated(updatedProfile);

        AppToast.success(context, context.tr('bio_updated_success'));
        Navigator.pop(context);
      } else {
        AppToast.error(
          context,
          response['message'] ?? context.tr('bio_update_failed'),
        );
      }
    } catch (e) {
      AppToast.error(context, '${context.tr('error_occurred')}: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateWithAI() async {
    // هنا يمكنك إضافة منطق توليد النص بالذكاء الاصطناعي
    setState(() {
      _descriptionController.text = context.tr('ai_generated_bio');
      _isAiGenerated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdvisorBackground(
        child: SafeArea(
          child: Column(
            children: [
              Gap(16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SimpleAppBar(
                  title: context.tr('edit_bio'),
                  isLargeTitle: true,
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(32.h),

                      // حقل النص
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.whiteCard2Back,
                            borderRadius: BorderRadius.circular(12.r),
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
                              hintText: context.tr('tell_us_about_yourself'),
                              hintStyle: Styles.textStyle14.copyWith(
                                color: AppColors.primary200,
                              ),
                              counterText: '',
                            ),
                          ),
                        ),
                      ),
                      Gap(8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '$_currentCharacterCount/200',
                            style: Styles.textStyle12.copyWith(
                              color: _currentCharacterCount > 200
                                  ? AppColors.errorColor
                                  : AppColors.secondary400,
                            ),
                          ),
                        ],
                      ),
                      Gap(32.h),

                      if (!_isAiGenerated)
                        InkWell(
                          onTap: _generateWithAI,
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.kWhiteColor),
                            ),
                            width: double.infinity,
                            child: Text(
                              context.tr('write_with_ai'),
                              textAlign: TextAlign.center,
                              style: Styles.textStyle16.copyWith(
                                color: AppColors.primary600,
                              ),
                            ),
                          ),
                        ),

                      Spacer(),

                      // زر التأكيد
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: CustomBotton(
                          height: 52.h,
                          width: double.infinity,
                          title: context.tr('confirm'),
                          onPressed: _isLoading ? null : _updateDescription,
                          isLoading: _isLoading,
                          backGroundcolor: AppColors.kprimaryColor,
                          titleColor: AppColors.kWhiteColor,
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
      ),
    );
  }
}
