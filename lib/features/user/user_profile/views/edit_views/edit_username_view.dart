import 'dart:convert';
import 'package:tayseer/core/constant/constans_keys.dart';
import 'package:tayseer/features/shared/auth/model/login_data.dart';
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
  String? _errorMessage;

  // إزالة الـ @ من البداية إذا كانت موجودة في البيانات الأولية
  String get _initialUsernameWithoutAt {
    final username = widget.initialProfile.username;
    return username.startsWith('@') ? username.substring(1) : username;
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(
      text: _initialUsernameWithoutAt,
    );
    _isLoading = false;
    _errorMessage = null;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  // دالة لتنظيف وإضافة الـ @
  String _formatUsername(String input) {
    String cleaned = input.trim();
    // إزالة أي @ في البداية أو النهاية
    cleaned = cleaned.replaceAll(RegExp(r'^@+|@+$'), '');
    // إزالة المسافات
    cleaned = cleaned.replaceAll(' ', '');
    // إضافة @ في البداية
    return '@$cleaned';
  }

  // التحقق من صحة اسم المستخدم
  void _validateUsername(String value) {
    final cleaned = value.trim().replaceAll('@', '');

    setState(() {
      if (cleaned.isEmpty) {
        _errorMessage = 'اسم المستخدم مطلوب';
      } else if (cleaned.length < 5) {
        _errorMessage = 'يجب أن يكون اسم المستخدم 5 أحرف على الأقل';
      } else if (cleaned.length > 19) {
        _errorMessage = 'لا يمكن أن يزيد اسم المستخدم عن 19 حرف';
      } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(cleaned)) {
        _errorMessage =
            'يمكن استخدام الحروف الإنجليزية والأرقام والشرطة السفلية (_) فقط';
      } else if (RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
        _errorMessage = 'لا يمكن أن يكون اسم المستخدم أرقاماً فقط';
      } else if (cleaned.toLowerCase() ==
          _initialUsernameWithoutAt.toLowerCase()) {
        _errorMessage = 'اسم المستخدم نفسه الحالي';
      } else {
        _errorMessage = null;
      }
    });
  }

  bool get _isFormValid {
    final cleaned = _usernameController.text.trim().replaceAll('@', '');
    return _errorMessage == null &&
        cleaned.isNotEmpty &&
        cleaned != _initialUsernameWithoutAt;
  }

  Future<void> _updateUsername() async {
    if (!_isFormValid) return;

    final formattedUsername = _formatUsername(_usernameController.text);
    final currentUsername = widget.initialProfile.username;

    if (formattedUsername.toLowerCase() == currentUsername.toLowerCase()) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.patch(
        endPoint: '/user/update-profile',
        isFromData: true,
        // إرسال الاسم مع @ لأن الخادم يتطلبه
        data: {'username': formattedUsername}, // إرسال مع @
      );

      if (response['success'] == true) {
        final updatedProfile = widget.initialProfile.copyWith(
          username: formattedUsername,
        );

        // ⭐ تحديث kCurrentUserData والـ cache
        if (kCurrentUserData != null) {
          final Map<String, dynamic> currentUserJson = kCurrentUserData!
              .toJson();
          currentUserJson['username'] = formattedUsername;
          kCurrentUserData = UserModel.fromJson(currentUserJson);

          CachNetwork.setData(
            key: kuserData,
            value: jsonEncode(kCurrentUserData!.toJson()),
          );
          debugPrint(
            '✅ تم تحديث kCurrentUserData.username: ${kCurrentUserData!.username}',
          );
        }

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

  Widget _buildUsernameField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.whiteCard2Back,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: _errorMessage != null
              ? AppColors.errorColor
              : AppColors.primary100,
        ),
      ),
      child: Row(
        children: [
          // أيقونة الـ @ الثابتة
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Text(
              '@',
              style: Styles.textStyle20.copyWith(
                color: AppColors.primary200,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          Expanded(
            child: TextField(
              controller: _usernameController,
              style: Styles.textStyle16.copyWith(color: AppColors.secondary800),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'اسم المستخدم',
                hintStyle: Styles.textStyle14.copyWith(
                  color: AppColors.primary200,
                ),
                filled: true,
                fillColor: AppColors.whiteCard2Back,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(
                  top: 14.h,
                  bottom: 14.h,
                  right: 8.w,
                ),
                counterText: '',
              ),
              autofocus: true,
              textInputAction: TextInputAction.done,
              maxLength: 19, // 19 حرف بدون الـ @
              onChanged: (value) {
                // منع كتابة @ في الحقل
                if (value.contains('@')) {
                  final cleanedValue = value.replaceAll('@', '');
                  _usernameController.value = _usernameController.value
                      .copyWith(
                        text: cleanedValue,
                        selection: TextSelection.collapsed(
                          offset: cleanedValue.length,
                        ),
                      );
                }
                _validateUsername(value);
              },
              onSubmitted: (_) => _updateUsername(),
              buildCounter:
                  (
                    BuildContext context, {
                    required int currentLength,
                    required int? maxLength,
                    required bool isFocused,
                  }) {
                    return Padding(
                      padding: EdgeInsets.only(right: 16.w, bottom: 8.h),
                      child: Text(
                        '$currentLength/$maxLength',
                        style: Styles.textStyle12.copyWith(
                          color: currentLength > maxLength!
                              ? AppColors.errorColor
                              : AppColors.primary400,
                        ),
                      ),
                    );
                  },
            ),
          ),
        ],
      ),
    );
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
                  title: 'تعديل اسم المستخدم',
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
                      Gap(40.h),

                      // عنوان الحقل
                      Text(
                        'اسم المستخدم',
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.secondary700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Gap(8.h),

                      // حقل إدخال اسم المستخدم
                      _buildUsernameField(),

                      // رسالة الخطأ
                      if (_errorMessage != null) ...[
                        Gap(8.h),
                        Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Text(
                            _errorMessage!,
                            style: Styles.textStyle12.copyWith(
                              color: AppColors.errorColor,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],

                      Gap(12.h),

                      // قواعد اسم المستخدم
                      // Container(
                      //   width: double.infinity,
                      //   padding: EdgeInsets.all(12.w),
                      //   decoration: BoxDecoration(
                      //     color: AppColors.primary50,
                      //     borderRadius: BorderRadius.circular(8.r),
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         'قواعد اسم المستخدم:',
                      //         style: Styles.textStyle12.copyWith(
                      //           color: AppColors.secondary700,
                      //           fontWeight: FontWeight.w600,
                      //         ),
                      //       ),
                      //       Gap(4.h),
                      //       Text(
                      //         '• يجب أن يكون بين 5 إلى 19 حرفاً\n'
                      //         '• يمكن استخدام الحروف الإنجليزية فقط (a-z)\n'
                      //         '• يمكن استخدام الأرقام (0-9)\n'
                      //         '• يمكن استخدام الشرطة السفلية (_)\n'
                      //         '• لا يمكن أن يكون أرقاماً فقط\n'
                      //         '• الـ @ ستُضاف تلقائياً',
                      //         style: Styles.textStyle12.copyWith(
                      //           color: AppColors.primary600,
                      //           height: 1.5,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      // // عرض المعاينة
                      // if (_usernameController.text.isNotEmpty &&
                      //     _errorMessage == null) ...[
                      //   Gap(16.h),
                      //   Container(
                      //     width: double.infinity,
                      //     padding: EdgeInsets.all(12.w),
                      //     decoration: BoxDecoration(
                      //       color: AppColors.success50,
                      //       borderRadius: BorderRadius.circular(8.r),
                      //       border: Border.all(color: AppColors.success100),
                      //     ),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text(
                      //           'معاينة اسم المستخدم:',
                      //           style: Styles.textStyle12.copyWith(
                      //             color: AppColors.success700,
                      //             fontWeight: FontWeight.w600,
                      //           ),
                      //         ),
                      //         Gap(4.h),
                      //         Row(
                      //           children: [
                      //             Text(
                      //               '@',
                      //               style: Styles.textStyle14.copyWith(
                      //                 color: AppColors.success600,
                      //               ),
                      //             ),
                      //             Text(
                      //               _usernameController.text.trim().replaceAll(
                      //                 '@',
                      //                 '',
                      //               ),
                      //               style: Styles.textStyle14.copyWith(
                      //                 color: AppColors.success800,
                      //                 fontWeight: FontWeight.w500,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ],
                      Spacer(),

                      // زر التأكيد
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: CustomBotton(
                          height: 52.h,
                          width: double.infinity,
                          title: 'تأكيد',
                          onPressed: _isFormValid && !_isLoading
                              ? _updateUsername
                              : null,
                          isLoading: _isLoading,
                          backGroundcolor: _isFormValid
                              ? AppColors.kprimaryColor
                              : AppColors.primary200,
                          titleColor: AppColors.kWhiteColor,
                          useGradient: _isFormValid,
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
