import 'package:tayseer/my_import.dart';

class EditPersonalDataDropdown extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hint;

  const EditPersonalDataDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;

    final effectiveItems = (value != null && !items.contains(value))
        ? [value!, ...items]
        : List<String>.from(items);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: isTablet ? 12.h : 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary100),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          borderRadius: BorderRadius.circular(12.r),
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.inactiveColor,
            size: 24.w,
          ),
          elevation: 16,
          style: Styles.textStyle14.copyWith(color: AppColors.secondary800),
          hint: Text(
            context.tr(hint),
            style: Styles.textStyle14.copyWith(color: AppColors.secondary400),
            textAlign: TextAlign.right,
          ),
          onChanged: onChanged,
          dropdownColor: AppColors.kWhiteColor,
          items: effectiveItems.map((item) {
            final isValid = items.contains(item);
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                context.tr(item),
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
                style: Styles.textStyle14.copyWith(
                  color: isValid
                      ? AppColors.secondary800
                      : AppColors.secondary400,
                  fontStyle: isValid ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
