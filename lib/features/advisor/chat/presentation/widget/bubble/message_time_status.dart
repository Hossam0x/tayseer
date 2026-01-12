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
    final timeColor = isOverlay ? Colors.white : ChatColors.timeReceiver;
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
    // Pending state: show clock icon
    if (status == MessageStatusEnum.pending) {
      final pendingIconSize = isMobile ? 12.0 : 16.0;
      return Icon(
        Icons.access_time,
        size: pendingIconSize,
        color: ChatColors.sentIconColor,
      );
    }

    final iconSize = status != MessageStatusEnum.sent
        ? (isMobile ? 10.0 : 14.0)
        : (isMobile ? 24.0 : 30.0);

    return SvgPicture.asset(
      status == MessageStatusEnum.sent
          ? AssetsData.sentMessageIcon
          : AssetsData.readMessageIcon,
      width: iconSize,
      height: iconSize,
      colorFilter: status == MessageStatusEnum.read
          ? null
          : const ColorFilter.mode(ChatColors.sentIconColor, BlendMode.srcIn),
    );
  }
}
