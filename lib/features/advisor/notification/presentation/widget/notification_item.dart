import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/core/widgets/custom_button.dart';
import 'package:tayseer/core/widgets/custom_outline_button.dart';
import 'package:tayseer/features/advisor/notification/data/enum/notification_type_enum.dart';
import 'package:tayseer/features/advisor/notification/data/models/notification_model.dart';

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
    // التعديل هنا: الاعتماد على حالة القراءة بدلاً من نوع الإشعار
    // إذا كانت isRead تساوي false، فهذا يعني أنها غير مقروءة ويجب تمييزها
    bool isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // إذا كانت غير مقروءة تأخذ لون أبيض، وإلا تكون شفافة
          color: isUnread ? Colors.white : Colors.transparent,
          // الحواف والظل يظهرون فقط للرسائل غير المقروءة
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
                          notification.title,
                          style: TextStyle(
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight
                                      .w600, // يمكن جعل الخط أعرض لغير المقروء
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
                            notification.time,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                          // النقطة الحمراء تظهر إذا كانت غير مقروءة
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
                    notification.body,
                    style: TextStyle(
                      color: isUnread
                          ? Colors.black87
                          : Colors
                                .grey[600], // يمكن تغميق النص قليلاً للرسائل غير المقروءة
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
    );
  }

  Widget _buildAvatarArea() {
    bool isSystemOrConsultation =
        notification.type == NotificationType.system ||
        notification.type == NotificationType.consultation;

    if (isSystemOrConsultation) {
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
    }

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
              backgroundImage: AssetImage(notification.userImage),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset(notification.icon, width: 24, height: 24),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasActionButtons() {
    return notification.type == NotificationType.messageRequest ||
        notification.type == NotificationType.sessionRequest ||
        notification.type == NotificationType.consultation;
  }

  Widget _buildActionButtons(BuildContext context) {
    if (notification.type == NotificationType.consultation) {
      return Align(
        alignment: Alignment.centerRight,
        child: CustomBotton(
          width: 90.w,
          height: 40.h,
          useGradient: true,
          title: 'اشترك الان',
          onPressed: onSubscribe,
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: CustomBotton(
            height: 40,
            useGradient: true,
            title: 'قبول',
            onPressed: onAccept,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomOutlineButton(
            height: 40,
            width: double.infinity,
            text: 'رفض',
            onTap: onReject,
          ),
        ),
      ],
    );
  }
}
