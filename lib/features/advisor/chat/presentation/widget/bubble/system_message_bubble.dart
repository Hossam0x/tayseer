import 'package:flutter/material.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/utils/colors.dart';

/// Widget لعرض رسائل النظام في منتصف الشاشة
/// مثل "تم حظر المستخدم" أو "تم إلغاء الحظر"
class SystemMessageBubble extends StatelessWidget {
  final String content;

  const SystemMessageBubble({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    // final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: isMobile ? 8 : 12,
          horizontal: isMobile ? 16 : 24,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: Text(
            content,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: AppColors.kRedColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
