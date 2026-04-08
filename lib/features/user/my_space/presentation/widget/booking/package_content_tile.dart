// lib/features/booking/view/widget/package_content_tile.dart

import 'package:tayseer/my_import.dart';

class PackageContentTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const PackageContentTile({
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.kprimaryColor.withOpacity(0.03)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.kprimaryColor.withOpacity(0.3)
                : Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ★ أيقونة
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isSelected
                    ? Icon(
                        Icons.check_circle,
                        key: const ValueKey('checked'),
                        color: AppColors.kprimaryColor,
                        size: 20,
                      )
                    : Icon(
                        Icons.add_circle_outline,
                        key: const ValueKey('unchecked'),
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
              ),
            ),

            const SizedBox(width: 10),

            // ★ النص
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Styles.textStyle12.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.kprimaryColor
                          : Colors.black87,
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Styles.textStyle10.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: isArabic ? TextAlign.right : TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}