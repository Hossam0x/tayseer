import 'package:tayseer/features/shared/auth/model/localc_country_model.dart';
import 'package:tayseer/my_import.dart';

class SelectCountryCard extends StatelessWidget {
  const SelectCountryCard({
    super.key,
    required this.country,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final LocalCountryModel country;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDisabled
              ? Colors.grey.shade100
              : isSelected
              ? AppColors.kprimaryColor.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDisabled
                ? Colors.grey.shade200
                : isSelected
                ? AppColors.kprimaryColor
                : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDisabled ? Colors.grey.shade300 : Colors.transparent,
                border: Border.all(
                  color: isDisabled
                      ? Colors.grey.shade300
                      : isSelected
                      ? AppColors.kprimaryColor
                      : Colors.grey.shade300,
                  width: isDisabled
                      ? 0
                      : isSelected
                      ? 6
                      : 1.5,
                ),
              ),
              child: isDisabled
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(country.translationKey),
                    style: Styles.textStyle14.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isDisabled ? Colors.grey.shade400 : Colors.black87,
                    ),
                  ),
                  if (isDisabled)
                    Text(
                      context.tr('already_added'),
                      style: Styles.textStyle10.copyWith(
                        color: Colors.green.shade500,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Opacity(
              opacity: isDisabled ? 0.4 : 1.0,
              child: Text(
                country.flagEmoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
