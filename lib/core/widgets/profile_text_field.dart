import 'package:tayseer/my_import.dart';

class ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hint;
  final int? maxLines;
  final int? maxLength;
  final int? minLength;
  final TextInputType? keyboardType;
  final bool enabled;
  final bool showCharacterCount;
  final String? validationErrorKey;

  const ProfileTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.minLength,
    this.keyboardType,
    this.enabled = true,
    this.showCharacterCount = false,
    this.validationErrorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          textAlign: isArabic ? TextAlign.right : TextAlign.left,
          maxLines: maxLines,
          maxLength: showCharacterCount ? null : maxLength,
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
              borderSide: BorderSide(
                color: _getBorderColor(controller.text.length),
                width: _hasError(controller.text.length) ? 1.5 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: _hasError(controller.text.length)
                    ? AppColors.kRedColor
                    : AppColors.primary500,
                width: _hasError(controller.text.length) ? 1.5 : 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary100),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            counterText: '',
          ),
        ),
        if (showCharacterCount && maxLength != null) ...[
          Gap(6.h),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              final charCount = value.text.length;
              final hasError = _hasError(charCount);

              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (minLength != null && charCount < minLength!)
                    Expanded(
                      child: Text(
                        context.tr(validationErrorKey ?? 'bio_min_3_chars'),
                        style: Styles.textStyle12.copyWith(
                          color: AppColors.kRedColor,
                        ),
                        textAlign: isArabic ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                  Text(
                    '$charCount/$maxLength',
                    style: Styles.textStyle14.copyWith(
                      color: hasError
                          ? AppColors.kRedColor
                          : AppColors.secondary400,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  bool _hasError(int charCount) {
    if (minLength != null && charCount < minLength!) {
      return true;
    }
    if (maxLength != null && charCount > maxLength!) {
      return true;
    }
    return false;
  }

  Color _getBorderColor(int charCount) {
    if (_hasError(charCount)) {
      return AppColors.kRedColor;
    }
    return AppColors.primary100;
  }
}
