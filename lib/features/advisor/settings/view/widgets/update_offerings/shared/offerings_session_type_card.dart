import 'package:tayseer/my_import.dart';

class OfferingsSessionTypeCard extends StatelessWidget {
  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const OfferingsSessionTypeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: context.height * .15,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.pink.shade50.withOpacity(0.3)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.kprimaryColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected
                    ? AppColors.kprimaryColor
                    : Colors.grey.shade400,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppImage(
                    icon,
                    width: context.width * 0.1,
                    height: context.height * 0.05,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Styles.textStyle14.copyWith(
                      color: isSelected
                          ? AppColors.kprimaryColor
                          : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
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
