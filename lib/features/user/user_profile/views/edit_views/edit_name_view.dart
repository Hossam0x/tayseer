import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/my_import.dart';

class EditNameView extends StatefulWidget {
  final UserProfileModel initialProfile;
  final Function(UserProfileModel) onProfileUpdated;

  const EditNameView({
    super.key,
    required this.initialProfile,
    required this.onProfileUpdated,
  });

  @override
  State<EditNameView> createState() => _EditNameViewState();
}

class _EditNameViewState extends State<EditNameView> {
  late TextEditingController _nameController;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.name);
    _isLoading = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // مثال في EditNameView
  // في EditNameView.dart
  Future<void> _updateName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == widget.initialProfile.name) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.patch(
        endPoint: '/user/update-profile',
        isFromData: true,
        data: {'name': newName},
      );

      if (response['success'] == true) {
        final imageUrl = response['data']['image'] as String?;
        final updatedProfile = widget.initialProfile.copyWith(
          name: newName,
          image: imageUrl,
        );

        widget.onProfileUpdated(updatedProfile);
        AppToast.success(context, 'تم تحديث الاسم بنجاح');
      } else {
        AppToast.error(context, response['message'] ?? 'فشل تحديث الاسم');
      }
    } catch (e) {
      AppToast.error(context, 'حدث خطأ: $e');
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
                child: SimpleAppBar(title: 'الاسم', isLargeTitle: true),
              ),
              Text(
                'يمكنك تحديث اسمك لمره واحدة كل 6 اشهر',
                style: Styles.textStyle14.copyWith(color: AppColors.primary800),
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
                      Gap(80.h),

                      // حقل إدخال الاسم
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteCard2Back,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.secondary200),
                        ),
                        child: TextField(
                          controller: _nameController,
                          style: Styles.textStyle14.copyWith(
                            color: AppColors.secondary800,
                          ),
                          decoration: InputDecoration(
                            hintText: 'أدخل اسمك',
                            hintStyle: Styles.textStyle14.copyWith(
                              color: AppColors.primary200,
                            ),
                            filled: true,
                            fillColor: AppColors.whiteCard2Back,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AppColors.primary100,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AppColors.primary100,
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                color: AppColors.primary100,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                          ),
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _updateName(),
                        ),
                      ),
                      Gap(8.h),
                      Spacer(),

                      // زر التأكيد
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: CustomBotton(
                          height: 52.h,
                          width: double.infinity,
                          title: 'تأكيد',
                          onPressed: _isLoading ? null : _updateName,
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
