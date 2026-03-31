import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tayseer/core/enum/message_status_enum.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/advisor/chat/presentation/theme/chat_theme.dart';

class MessageTimeStatus extends StatelessWidget {
  final String formattedTime;
  final bool isMe;
  final MessageStatusEnum status;
  final bool isOverlay;
  final bool isMobile;

  const MessageTimeStatus({
    super.key,
    required this.formattedTime,
    required this.isMe,
    required this.status,
    this.isOverlay = false,
    this.isMobile = true,
  });

  @override
  Widget build(BuildContext context) {
    final timeColor = !isMe ? Colors.black : Colors.white;
    final timeFontSize = isMobile
        ? ChatDimensions.timeFontSizeMobile
        : ChatDimensions.timeFontSizeTablet;
    final spacingH = isMobile ? 4.0 : 6.0;
    final spacingV = isMobile ? 6.0 : 8.0;

    return Padding(
      padding: EdgeInsets.only(top: spacingV),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isMe) ...[_buildStatusIcon(), SizedBox(width: spacingH)],
          Text(
            formattedTime,
            style: TextStyle(
              color: timeColor,
              fontSize: timeFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    // ✅ Pending state: أيقونة الساعة
    if (status == MessageStatusEnum.pending) {
      final pendingIconSize = isMobile ? 12.0 : 16.0;
      return Icon(
        Icons.access_time,
        size: pendingIconSize,
        color: isMe ? Colors.white : Colors.black,
      );
    }

    // ✅ Failed state: أيقونة خطأ
    if (status == MessageStatusEnum.failed) {
      final failedIconSize = isMobile ? 12.0 : 16.0;
      return Icon(
        Icons.error_outline,
        size: failedIconSize,
        color: Colors.red,
      );
    }

    // تحديد حجم الأيقونة بناءً على الحالة
    double iconSize;
    if (status == MessageStatusEnum.sent) {
      // SENT: صح واحد - أكبر بكتير
      iconSize = isMobile ? 20.0 : 24.0;
    } else {
      // READ/DELIVERED: صحين
      iconSize = isMobile ? 14.0 : 18.0;
    }
    
    // تحديد اللون بناءً على الحالة
    Color iconColor;
    if (status == MessageStatusEnum.read) {
      // READ: صحين أحمر
      iconColor = const Color(0xFFE96E88); // اللون الأحمر بتاع التطبيق
    } else {
      // SENT/DELIVERED: صحين أبيض
      iconColor = Colors.white;
    }

    // تحديد الأيقونة بناءً على الحالة
    String iconAsset;
    if (status == MessageStatusEnum.sent) {
      iconAsset = AssetsData.sentMessageIcon; // صح واحد
    } else {
      iconAsset = AssetsData.readMessageIcon; // صحين
    }

    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: SvgPicture.asset(
        iconAsset,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    );
  }
}
