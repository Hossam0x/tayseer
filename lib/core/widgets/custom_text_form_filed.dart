import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../../my_import.dart';

/// حقل نص عام للتطبيق.
///
/// لإدخال رقم الهاتف مع اختيار الدولة استخدم [PhoneInputField] بدلاً من هذا.
class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.isName = false,
    this.isMail = false,
    this.isPhone = false,
    this.isCity = false,
    this.isAccountName = false,
    this.isPasswordFiled = false,
    this.isConfirmPasswordFiled = false,
    this.isNumber = false,
    this.controller,
    this.maxLines = 1,
    this.enable = true,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.inputFormatters,
    this.autovalidateMode,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLength,
    this.autofillHints,
  });

  final bool isName;
  final bool isMail;
  final bool isPasswordFiled;
  final bool isConfirmPasswordFiled;
  final bool isPhone;
  final bool isCity;
  final bool isAccountName;
  final bool isNumber;

  final TextEditingController? controller;

  final int maxLines;
  final bool enable;
  final String? hintText;

  final dynamic prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLength;
  final Iterable<String>? autofillHints;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _showPassword = true;

  void _toggleVisibility() {
    setState(() => _showPassword = !_showPassword);
  }

  TextInputType _resolveKeyboardType() {
    if (widget.keyboardType != null) return widget.keyboardType!;
    if (widget.isNumber) return TextInputType.number;
    if (widget.isMail) return TextInputType.emailAddress;
    if (widget.isPhone) return TextInputType.phone;
    if (widget.isName || widget.isAccountName) return TextInputType.name;
    return TextInputType.text;
  }

  Iterable<String> _resolveAutofillHints() {
    if (widget.autofillHints != null) return widget.autofillHints!;
    if (widget.isMail) return [AutofillHints.email];
    if (widget.isName) return [AutofillHints.name];
    if (widget.isAccountName) return [AutofillHints.username];
    if (widget.isPhone) return [AutofillHints.telephoneNumber];
    if (widget.isPasswordFiled) return [AutofillHints.password];
    if (widget.isConfirmPasswordFiled) return [AutofillHints.newPassword];
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.disabled,
      autofillHints: _resolveAutofillHints(),
      inputFormatters: widget.maxLength != null
          ? [
              ...?widget.inputFormatters,
              LengthLimitingTextInputFormatter(widget.maxLength),
            ]
          : widget.inputFormatters,
      onTapOutside: (_) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          FocusScope.of(context).unfocus();
        });
      },
      autocorrect: false,
      controller: widget.controller,
      keyboardType: _resolveKeyboardType(),
      textInputAction: widget.textInputAction ?? TextInputAction.next,
      enabled: widget.enable,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      style: Styles.textStyle12,
      obscureText: widget.isPasswordFiled || widget.isConfirmPasswordFiled
          ? _showPassword
          : false,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.kWhiteColor,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: widget.maxLines > 1 ? 12 : context.height * .022,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.kprimaryColor.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.kprimaryColor.withOpacity(0.5),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.kprimaryColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: Styles.textStyle10.copyWith(color: Colors.red),
        prefixIcon: widget.prefixIcon == null
            ? null
            : widget.prefixIcon is IconData
            ? Icon(widget.prefixIcon as IconData)
            : widget.prefixIcon as Widget,
        suffixIcon:
            widget.suffixIcon ??
            ((widget.isPasswordFiled || widget.isConfirmPasswordFiled)
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.kprimaryColor,
                    ),
                    onPressed: _toggleVisibility,
                  )
                : null),
        hintText:
            widget.hintText ??
            (widget.isMail
                ? context.tr('enter_email')
                : widget.isName
                ? context.tr('enter_name')
                : widget.isAccountName
                ? context.tr('enter_account_name')
                : widget.isPasswordFiled
                ? context.tr('password')
                : widget.isConfirmPasswordFiled
                ? context.tr('confirm_password')
                : widget.isPhone
                ? context.tr('enter_phone')
                : widget.isCity
                ? context.tr('enter_city')
                : context.tr('enter_text')),
        hintStyle: Styles.textStyle14.copyWith(
          color: AppColors.kprimaryColor.withOpacity(0.5),
        ),
      ),
      validator: widget.validator ?? _defaultValidator,
    );
  }

  String? _defaultValidator(String? value) {
    final text = value?.trim() ?? '';

    if (widget.isMail) {
      if (text.isEmpty) return context.tr('email_required');
      if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(text)) {
        return context.tr('invalid_email');
      }
      if (widget.maxLength != null && text.length > widget.maxLength!) {
        return '${context.tr("max_length_exceeded")} ${widget.maxLength}';
      }
      return null;
    }

    if (widget.isPasswordFiled || widget.isConfirmPasswordFiled) {
      if (text.length < 8) return context.tr('password_min_length');
      if (widget.maxLength != null && text.length > widget.maxLength!) {
        return '${context.tr("max_length_exceeded")} ${widget.maxLength}';
      }
      return null;
    }

    if (widget.isPhone) {
      if (text.length < 7) return context.tr('invalid_phone');
      if (widget.maxLength != null && text.length > widget.maxLength!) {
        return '${context.tr("max_length_exceeded")} ${widget.maxLength}';
      }
      return null;
    }

    if (text.isEmpty) return context.tr('field_required');
    if (widget.maxLength != null && text.length > widget.maxLength!) {
      return '${context.tr("max_length_exceeded")} ${widget.maxLength}';
    }
    return null;
  }
}
