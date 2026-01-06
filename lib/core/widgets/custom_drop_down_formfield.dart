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
      hint: Text(
        hint,
        style: Styles.textStyle12.copyWith(
          color: AppColors.kprimaryColor.withOpacity(0.5),
        ),
      ),

      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        filled: true,
        fillColor: AppColors.kWhiteColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.kprimaryColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: AppColors.kprimaryColor.withOpacity(0.3),
          ),
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
      items: items,
      onChanged: onChanged,
    );
  }
}
