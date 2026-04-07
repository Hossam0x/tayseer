// lib/features/booking/view/widget/offering_radio_button.dart

import 'package:tayseer/my_import.dart';

class OfferingRadioButton extends StatelessWidget {
  final bool isSelected;

  const OfferingRadioButton({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.kprimaryColor : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kprimaryColor,
                ),
              ),
            )
          : null,
    );
  }
}
