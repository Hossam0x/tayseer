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
        final updatedProfile = widget.initialProfile.copyWith(name: newName);

        // إرجاع البيانات المحدثة إلى الصفحة السابقة
        Navigator.pop(context, updatedProfile);
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
      body: SafeArea(
        child: Column(
          children: [
            SimpleAppBar(title: 'تعديل الاسم', isLargeTitle: true),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان والوصف
                    Text(
                      'الاسم',
                      style: Styles.textStyle16Meduim.copyWith(
                        color: AppColors.secondary800,
                      ),
                    ),
                    Gap(8.h),
                    Text(
                      'يمكنك تحديث اسمك لمره واحدة كل 6 اشهر',
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.secondary400,
                      ),
                    ),
                    Gap(32.h),

                    // حقل إدخال الاسم
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.secondary200),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.secondary800,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          border: InputBorder.none,
                          hintText: 'أدخل اسمك',
                          hintStyle: Styles.textStyle16.copyWith(
                            color: AppColors.secondary400,
                          ),
                        ),
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _updateName(),
                      ),
                    ),
                    Gap(8.h),

                    // عداد الأحرف
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${_nameController.text.length}/50',
                          style: Styles.textStyle12.copyWith(
                            color: AppColors.secondary400,
                          ),
                        ),
                      ],
                    ),

                    Spacer(),

                    // زر التأكيد
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: CustomBotton(
                        width: double.infinity,
                        title: 'تأكيد',
                        onPressed: _isLoading ? null : _updateName,
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
