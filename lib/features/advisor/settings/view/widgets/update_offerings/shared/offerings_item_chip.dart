import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/colors.dart';

class OfferingsItemChip extends StatelessWidget {
  final String text;
  final bool isPink;
  final bool isGreen;

  const OfferingsItemChip({
    super.key,
    required this.text,
    this.isPink = false,
    this.isGreen = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade700;
    if (isPink) {
      bg = Colors.pink.shade50;
      fg = AppColors.kprimaryColor;
    } else if (isGreen) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.bold),
      ),
    );
  }
}
