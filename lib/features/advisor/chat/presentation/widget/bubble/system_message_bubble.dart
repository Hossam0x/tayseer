import 'package:flutter/material.dart';
import 'package:tayseer/core/constant/constans.dart';
import 'package:tayseer/core/utils/colors.dart';

/// Widget لعرض رسائل النظام في الشات
/// - عربي: الـ bubble على اليمين
/// - إنجليزي: الـ bubble على اليسار
class SystemMessageBubble extends StatelessWidget {
  final String content;

  const SystemMessageBubble({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final bool arabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 8 : 12,
        horizontal: isMobile ? 16 : 24,
      ),
      child: Row(
        mainAxisAlignment:
            arabic ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenSize.width * 0.78),
            child: Container(
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
                textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  content,
                  textAlign: arabic ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: AppColors.kRedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
