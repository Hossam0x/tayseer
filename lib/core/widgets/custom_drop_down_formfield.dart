import 'package:tayseer/my_import.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final String hint;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;

  const CustomDropdownFormField({
    super.key,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.value,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      isExpanded: true,

      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.kWhiteColor,
        isDense: true,

        /// نفس الـ padding بتاع الـ CustomTextFormField
        contentPadding: EdgeInsets.symmetric(
          vertical: context.height * .022,
          horizontal: 12,
        ),

        /// نفس borders بالظبط
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: Styles.textStyle10.copyWith(color: Colors.red),
      ),

      hint: Text(
        hint,
        style: Styles.textStyle12.copyWith(
          color: AppColors.kprimaryColor.withOpacity(0.5),
        ),
      ),

      items: items,
      onChanged: onChanged,
    );
  }
}
