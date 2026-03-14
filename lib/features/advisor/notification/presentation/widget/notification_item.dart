// notification_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/custom_button.dart';
import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/features/advisor/notification/data/enum/notification_type_enum.dart';
import 'package:tayseer/features/advisor/notification/data/models/notification_model.dart';
import 'package:tayseer/core/utils/app_strings.dart';
import 'package:tayseer/core/utils/extensions/extensions.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onSubscribe;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
    this.onAccept,
    this.onReject,
    this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !(notification.isRead ?? false);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUnread ? Colors.white : Colors.transparent,
            borderRadius: isUnread ? BorderRadius.circular(12) : null,
            boxShadow: isUnread
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarArea(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title ?? "",
                            style: TextStyle(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Text(
                              _formatTime(context, notification.dateTime),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            if (isUnread) ...[
                              const SizedBox(width: 5),
                              const CircleAvatar(
                                radius: 4,
                                backgroundColor: Colors.red,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.description ?? "",
                      style: TextStyle(
                        color: isUnread ? Colors.black87 : Colors.grey[600],
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_hasActionButtons()) ...[
                      const SizedBox(height: 12),
                      _buildActionButtons(context),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarArea() {
    /* if (isSystemOrConsultation) {
      return Container(
        width: 55,
        height: 55,
        decoration: const BoxDecoration(
          color: Color(0xFFF2F2F2),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(14),
        child: SvgPicture.asset(AssetsData.consultationIcon),
      );
    }*/

    return SizedBox(
      width: 55,
      height: 55,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[200],
              backgroundImage: notification.senderImage != null
                  ? NetworkImage(notification.senderImage!)
                  : const AssetImage(AssetsData.kUserImage) as ImageProvider,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(_getIconByType(), width: 24, height: 24),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Map NotificationType → Icon ──────────────────────────
  String _getIconByType() {
    switch (notification.type) {
      case NotificationType.commentLike:
      case NotificationType.commentReply:
        return AssetsData.commentIcon;

      case NotificationType.storyLike:

      case
      NotificationType.postLike:
      case NotificationType.replyLike:
          if(notification.likeType=="dislike")
            {
              return AssetsData.disLikeIcon;
            }else if(notification.likeType=="love")
              {
                return AssetsData.loveIcon;

              }else if(notification.likeType==null)
                {
                  return AssetsData.loveIcon;

                }else {return AssetsData.careIcon;}

      case NotificationType.postShare:
      case NotificationType.eventShare:
        return AssetsData.shareIcon;
      case NotificationType.newFollower:
        return AssetsData.followNotify;
      case NotificationType.newMessage:
      case NotificationType.newChat:
        return AssetsData.messageNotify;
      case NotificationType.sessionPaid:
        return AssetsData.messageNotify;
      case NotificationType.eventReservation:
        return AssetsData.ticketEventNotify;
      default:
        return AssetsData.careIcon;
    }
  }

  // ─── Format DateTime ───────────────────────────────────────
  String _formatTime(BuildContext context, DateTime? dateTime) {
    if (dateTime == null) return "";
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return context.tr(AppStrings.now);
    final prefix = context.tr(AppStrings.agoPrefix);
    if (diff.inMinutes < 60) {
      return prefix.isEmpty
          ? "${diff.inMinutes} ${context.tr(AppStrings.agoMinutes)}"
          : "$prefix ${diff.inMinutes} ${context.tr(AppStrings.agoMinutes)}";
    }
    if (diff.inHours < 24) {
      return prefix.isEmpty
          ? "${diff.inHours} ${context.tr(AppStrings.agoHours)}"
          : "$prefix ${diff.inHours} ${context.tr(AppStrings.agoHours)}";
    }
    if (diff.inDays < 7) {
      return prefix.isEmpty
          ? "${diff.inDays} ${context.tr(AppStrings.agoDays)}"
          : "$prefix ${diff.inDays} ${context.tr(AppStrings.agoDays)}";
    }
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }

  bool _hasActionButtons() {
    return notification.type != NotificationType.newFollower;
  }

  Widget _buildActionButtons(BuildContext context) {
    // if (notification.type == NotificationType.sessionPaid) {
    //   return Align(
    //     alignment: Alignment.centerRight,
    //     child: CustomBotton(
    //       width: 90.w,
    //       height: 40.h,
    //       useGradient: true,
    //       title: 'اشترك الان',
    //       onPressed: onSubscribe,
    //     ),
    //   );
    // }
    if (notification.type == NotificationType.newChat) {
      return Row(
        children: [
          Expanded(
            child: CustomBotton(
              height: 40,
              useGradient: true,
              title: context.tr(AppStrings.accept),
              onPressed: onAccept,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomOutlineButton(
              height: 40,
              width: double.infinity,
              text: context.tr(AppStrings.reject),
              onTap: onReject,
            ),
          ),
        ],
      );
    }
    return SizedBox.shrink();
  }
}
