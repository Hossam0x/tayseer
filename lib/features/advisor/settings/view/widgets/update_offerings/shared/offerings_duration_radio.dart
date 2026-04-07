import 'package:tayseer/my_import.dart';

class OfferingsDurationRadio extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const OfferingsDurationRadio({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.pink.shade50.withOpacity(0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.kprimaryColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: isArabic
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: Styles.textStyle14.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? AppColors.kprimaryColor
                        : Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: Styles.textStyle10.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 22,
              height: 22,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.kprimaryColor
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                        color: AppColors.kprimaryColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
