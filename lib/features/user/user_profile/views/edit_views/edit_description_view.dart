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

    // Validate minimum length (required field)
    if (newDescription.length < 3) {
      AppToast.error(context, context.tr('bio_min_length_error'));
      return;
    }

    // Validate maximum length
    if (newDescription.length > 250) {
      AppToast.error(context, context.tr('bio_max_length_error'));
      return;
    }

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

                      // Text field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.whiteCard2Back,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color:
                                  _currentCharacterCount < 3 ||
                                      _currentCharacterCount > 250
                                  ? AppColors.errorColor
                                  : AppColors.primary100,
                              width:
                                  _currentCharacterCount < 3 ||
                                      _currentCharacterCount > 250
                                  ? 1.5
                                  : 1,
                            ),
                          ),
                          child: TextField(
                            controller: _descriptionController,
                            style: Styles.textStyle16.copyWith(
                              color: AppColors.secondary800,
                            ),
                            maxLines: null,
                            maxLength: 250,
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_currentCharacterCount < 3)
                            Expanded(
                              child: Text(
                                context.tr('bio_min_3_chars'),
                                style: Styles.textStyle12.copyWith(
                                  color: AppColors.errorColor,
                                ),
                                textAlign: isArabic
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                          Text(
                            '$_currentCharacterCount/250',
                            style: Styles.textStyle12.copyWith(
                              color:
                                  _currentCharacterCount < 3 ||
                                      _currentCharacterCount > 250
                                  ? AppColors.errorColor
                                  : AppColors.secondary400,
                            ),
                          ),
                        ],
                      ),
                      Gap(32.h),

                      Spacer(),

                      // Confirm button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: CustomBotton(
                          height: 52.h,
                          width: double.infinity,
                          title: context.tr('confirm'),
                          onPressed:
                              _isLoading ||
                                  _currentCharacterCount < 3 ||
                                  _currentCharacterCount > 250
                              ? null
                              : _updateDescription,
                          isLoading: _isLoading,
                          backGroundcolor:
                              _currentCharacterCount < 3 ||
                                  _currentCharacterCount > 250
                              ? Colors.grey
                              : AppColors.kprimaryColor,
                          titleColor: AppColors.kWhiteColor,
                          useGradient:
                              _currentCharacterCount >= 3 &&
                              _currentCharacterCount <= 250,
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
