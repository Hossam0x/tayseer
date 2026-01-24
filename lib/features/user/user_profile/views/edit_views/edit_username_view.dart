import 'package:tayseer/core/widgets/simple_app_bar.dart';
import 'package:tayseer/features/user/user_profile/data/models/user_profile_model.dart';
import 'package:tayseer/my_import.dart';

class EditUsernameView extends StatefulWidget {
  final UserProfileModel initialProfile;
  final Function(UserProfileModel) onProfileUpdated;

  const EditUsernameView({
    super.key,
    required this.initialProfile,
    required this.onProfileUpdated,
  });

  @override
  State<EditUsernameView> createState() => _EditUsernameViewState();
}

class _EditUsernameViewState extends State<EditUsernameView> {
  late TextEditingController _usernameController;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: widget.initialProfile.username,
    );
    _isLoading = false;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _updateUsername() async {
    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty || newUsername == widget.initialProfile.username) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.patch(
        endPoint: '/user/update-profile',
        isFromData: true,
        data: {'username': newUsername},
      );

      if (response['success'] == true) {
        final updatedProfile = widget.initialProfile.copyWith(
          username: newUsername,
        );
        widget.onProfileUpdated(updatedProfile);

        AppToast.success(context, 'تم تحديث اسم المستخدم بنجاح');
        Navigator.pop(context);
      } else {
        AppToast.error(
          context,
          response['message'] ?? 'فشل تحديث اسم المستخدم',
        );
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
            SimpleAppBar(title: 'تعديل اسم المستخدم', isLargeTitle: true),

            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان والوصف
                    Text(
                      'اسم المستخدم',
                      style: Styles.textStyle16Meduim.copyWith(
                        color: AppColors.secondary800,
                      ),
                    ),
                    Gap(8.h),
                    Text(
                      'يمكنك تحديث اسم المستخدم لمره واحده كل 6 اشهر',
                      style: Styles.textStyle12.copyWith(
                        color: AppColors.secondary400,
                      ),
                    ),
                    Gap(32.h),

                    // حقل إدخال اسم المستخدم
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.secondary200),
                      ),
                      child: TextField(
                        controller: _usernameController,
                        style: Styles.textStyle16.copyWith(
                          color: AppColors.secondary800,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          border: InputBorder.none,
                          hintText: 'أدخل اسم المستخدم',
                          hintStyle: Styles.textStyle16.copyWith(
                            color: AppColors.secondary400,
                          ),
                        ),
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _updateUsername(),
                      ),
                    ),
                    Gap(8.h),

                    // عداد الأحرف
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${_usernameController.text.length}/30',
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
                        onPressed: _isLoading ? null : _updateUsername,
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
