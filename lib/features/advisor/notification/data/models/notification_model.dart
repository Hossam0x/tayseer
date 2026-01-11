import 'package:tayseer/features/advisor/notification/data/enum/notification_type_enum.dart';

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String time;
  final String userImage; // صورة المستخدم
  final String icon; // الأيقونة الصغيرة (Badge)
  final NotificationType type;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.userImage,
    required this.icon,
    required this.type,
    this.isRead = false,
  });
}
