import 'package:tayseer/my_import.dart';

class LanguageSelectableRow extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageSelectableRow({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: context.height * 0.007),
        padding: EdgeInsets.symmetric(
          vertical: context.height * 0.02,
          horizontal: context.width * 0.04,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.kprimaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.kprimaryColor : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Styles.textStyle16.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.kprimaryColor),
          ],
        ),
      ),
    );
  }
}
