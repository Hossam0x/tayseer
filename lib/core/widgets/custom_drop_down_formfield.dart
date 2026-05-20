import 'package:dropdown_button2/dropdown_button2.dart';
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
    return DropdownButtonFormField2<T>(
      value: value,
      validator: validator,
      isExpanded: true,

      // ✅ شكل الـ icon
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.kprimaryColor.withOpacity(0.5),
        ),
      ),

      // ✅ التحكم في الـ Dropdown Menu
      dropdownStyleData: DropdownStyleData(
        // ✅ العرض على قد الـ Field
        useRootNavigator: true,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        maxHeight: 300,
        offset: const Offset(0, -5), // ✅ يظهر فوق الـ field شوية
      ),

      // ✅ التحكم في شكل كل Item
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),

      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.kWhiteColor,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: context.height * .02,
          // horizontal: 12,
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
