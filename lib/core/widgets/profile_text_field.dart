import 'package:tayseer/my_import.dart';

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;
  final int? maxLines;
  final TextInputType? keyboardType;
  final bool enabled;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      textAlign: TextAlign.right,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Styles.textStyle14.copyWith(color: AppColors.primary200),
        filled: true,
        fillColor: AppColors.kWhiteColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primary100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primary500),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primary100),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }
}
