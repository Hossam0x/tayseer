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
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late bool _isLoading;
  String? _firstNameError;
  String? _lastNameError;

  @override
  void initState() {
    super.initState();
    // تقسيم الاسم الحالي إلى جزئين (إذا كان فيه مسافة)
    final currentNameParts = widget.initialProfile.name.split(' ');
    _firstNameController = TextEditingController(text: currentNameParts.first);
    _lastNameController = TextEditingController(
      text: currentNameParts.length > 1
          ? currentNameParts.sublist(1).join(' ')
          : '',
    );
    _isLoading = false;
    _firstNameError = null;
    _lastNameError = null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  String get _fullName =>
      '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
          .trim();

  bool get _isNameChanged => _fullName != (widget.initialProfile.name.trim());

  void _validateFields() {
    setState(() {
      _firstNameError = null;
      _lastNameError = null;

      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();

      // تحقق من الاسم الأول
      if (firstName.isEmpty) {
        _firstNameError = 'الاسم الأول مطلوب';
      } else if (firstName.length > 12) {
        _firstNameError = 'الاسم الأول لا يمكن أن يزيد عن 12 حرف';
      } else if (!RegExp(r'^[a-zA-Zء-ي\s]+$').hasMatch(firstName)) {
        _firstNameError = 'الاسم الأول يمكن أن يحتوي على حروف فقط';
      }

      // تحقق من الاسم الثاني
      if (lastName.isNotEmpty) {
        if (lastName.length > 12) {
          _lastNameError = 'الاسم الثاني لا يمكن أن يزيد عن 12 حرف';
        } else if (!RegExp(r'^[a-zA-Zء-ي\s]+$').hasMatch(lastName)) {
          _lastNameError = 'الاسم الثاني يمكن أن يحتوي على حروف فقط';
        }
      }
    });
  }

  bool get _isFormValid {
    return _firstNameError == null &&
        _lastNameError == null &&
        _firstNameController.text.trim().isNotEmpty &&
        _isNameChanged;
  }

  Future<void> _updateName() async {
    if (!_isFormValid) return;

    final newFullName = _fullName;
    if (newFullName.isEmpty || !_isNameChanged) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = getIt<ApiService>();
      final response = await apiService.patch(
        endPoint: '/user/update-profile',
        isFromData: true,
        data: {'name': newFullName},
      );

      if (response['success'] == true) {
        final imageUrl = response['data']['image'] as String?;
        final updatedProfile = widget.initialProfile.copyWith(
          name: newFullName,
          image: imageUrl,
        );

        widget.onProfileUpdated(updatedProfile);
        AppToast.success(context, 'تم تحديث الاسم بنجاح');
        Navigator.pop(context);
      } else {
        AppToast.error(context, response['message'] ?? 'فشل تحديث الاسم');
      }
    } catch (e) {
      AppToast.error(context, 'حدث خطأ: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildNameField({
    required TextEditingController controller,
    required String hintText,
    required String? errorText,
    required void Function(String) onChanged,
    bool isLastName = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.whiteCard2Back,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: errorText != null
                  ? AppColors.kprimaryColor
                  : AppColors.secondary200,
            ),
          ),
          child: TextField(
            controller: controller,
            style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Styles.textStyle14.copyWith(
                color: AppColors.primary200,
              ),
              filled: true,
              fillColor: AppColors.whiteCard2Back,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: errorText != null
                      ? AppColors.kprimaryColor
                      : AppColors.primary100,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: errorText != null
                      ? AppColors.kprimaryColor
                      : AppColors.primary100,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20.r,
                        color: AppColors.primary300,
                      ),
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                        _validateFields();
                      },
                    )
                  : null,
            ),
            autofocus: !isLastName,
            textInputAction: isLastName
                ? TextInputAction.done
                : TextInputAction.next,
            onChanged: (value) {
              onChanged(value);
              _validateFields();
            },
            onSubmitted: isLastName ? (_) => _updateName() : null,
            maxLength: 12,
            buildCounter:
                (
                  BuildContext context, {
                  required int currentLength,
                  required int? maxLength,
                  required bool isFocused,
                }) => null,
          ),
        ),
        if (errorText != null) ...[
          Gap(4.h),
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Text(
              errorText,
              style: Styles.textStyle12.copyWith(
                color: AppColors.kprimaryColor,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ],
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
                child: SimpleAppBar(title: 'الاسم', isLargeTitle: true),
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

                      // حقل الاسم الأول
                      Text(
                        'الاسم الأول',
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.secondary700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Gap(8.h),
                      _buildNameField(
                        controller: _firstNameController,
                        hintText: 'أدخل الاسم الأول',
                        errorText: _firstNameError,
                        onChanged: (_) {},
                      ),
                      Gap(24.h),

                      // حقل الاسم الثاني
                      Text(
                        'الاسم الثاني (اختياري)',
                        style: Styles.textStyle14.copyWith(
                          color: AppColors.secondary700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Gap(8.h),
                      _buildNameField(
                        controller: _lastNameController,
                        hintText: 'أدخل الاسم الثاني',
                        errorText: _lastNameError,
                        onChanged: (_) {},
                        isLastName: true,
                      ),
                      Spacer(),

                      // زر التأكيد
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: CustomBotton(
                          height: 52.h,
                          width: double.infinity,
                          title: 'تأكيد',
                          onPressed: _isFormValid && !_isLoading
                              ? _updateName
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
