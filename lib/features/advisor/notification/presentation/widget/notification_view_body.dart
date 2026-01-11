import 'package:flutter/material.dart';
import 'package:tayseer/core/utils/assets.dart';
import 'package:tayseer/features/advisor/chat/presentation/widget/request/custome_request_appbar.dart';
import 'package:tayseer/features/advisor/notification/data/enum/notification_type_enum.dart';
import 'package:tayseer/features/advisor/notification/data/models/notification_model.dart';
import 'package:tayseer/features/advisor/notification/presentation/widget/empty_notification.dart';
import 'package:tayseer/features/advisor/notification/presentation/widget/notification_item.dart';
// import 'package:tayseer/features/advisor/notification/presentation/widget/notification_item.dart'; // استدعي الملف الذي أنشأناه بالأعلى
import 'package:tayseer/my_import.dart';

class NotificationViewBody extends StatefulWidget {
  const NotificationViewBody({super.key});

  @override
  State<NotificationViewBody> createState() => _NotificationViewBodyState();
}

class _NotificationViewBodyState extends State<NotificationViewBody> {
  // --- Mock Data List ---
  final List<NotificationModel> notifications = [
    NotificationModel(
      id: 1,
      type: NotificationType.comment,
      title: "علق احمد منصور علي منشورك",
      body: "علق احمد منصور علي منشور خاص بك واضاف تعليق يشكرك فيه.",
      time: "10:00 am",
      userImage: AssetsData.kUserImage,
      icon: AssetsData.commentIcon,
    ),
    NotificationModel(
      id: 2,
      type: NotificationType.react,
      title: "تفاعل احمد منصور مع منشورك",
      body: "تفاعل احمد منصور علي منشور خاص بك.",
      time: "10:00 am",
      userImage: AssetsData.kUserImage,
      icon: AssetsData.careIcon,
    ),
    NotificationModel(
      id: 3,
      type: NotificationType.repost,
      title: "قام احمد باعادة نشر منشورك",
      body: "قام احمد باعادة نشر المنشور الخاص بك.",
      time: "10:00 am",
      userImage: AssetsData.kUserImage,
      icon: AssetsData.shareIcon,
      isRead: true,
    ),
    NotificationModel(
      id: 4,
      type: NotificationType.follow,
      title: "قام احمد بمتابعتك",
      body: "بدأ احمد بمتابعة حسابك الشخصي.",
      time: "10:00 am",
      userImage: AssetsData.kUserImage,
      icon: AssetsData.followNotify,
      isRead: true,
    ),
    NotificationModel(
      id: 5,
      type: NotificationType.inquiry,
      title: "ارسل احمد استفسار",
      body: "لديك استفسار جديد بخصوص الاستشارة.",
      time: "10:00 am",
      userImage: AssetsData.kUserImage,
      icon: AssetsData.messageNotify,
      isRead: true,
    ),
    NotificationModel(
      id: 6,
      type: NotificationType.messageRequest,
      title: "ارسل احمد طلب مراسلة",
      body: "يريد احمد بدء محادثة معك.",
      time: "10:00 am",
      userImage: AssetsData.kUserImage,
      icon: AssetsData.messageNotify,
      isRead: true,
    ),
    NotificationModel(
      id: 7,
      type: NotificationType.sessionRequest,
      title: "طلب احمد حجز جلسة",
      body: "قام احمد بطلب حجز جلسة استشارية جديدة.",
      time: "10:00 am",
      userImage: AssetsData.kUserImage,
      icon: AssetsData.messageNotify,
      isRead: true,
    ),
    NotificationModel(
      id: 8,
      type: NotificationType.ticket,
      title: "قام احمد بحجز تذكرة للحدث",
      body: "تم تأكيد حجز تذكرة للحدث القادم.",
      time: "10:00 am",
      userImage: AssetsData.kUserImage,
      icon: AssetsData.ticketEventNotify,
      isRead: true,
    ),
    NotificationModel(
      id: 9,
      type: NotificationType.system,
      title: "اشعار من النظام",
      body: "للتعزيز , تم حجز التذاكر , تجديد الاشتراك ,اقتراب جلسة.",
      time: "10:00 am",
      userImage: AssetsData.kUserImage,
      icon: AssetsData.careIcon,
      isRead: true,
    ),
    NotificationModel(
      id: 10,
      type: NotificationType.consultation,
      title: "ارسل اليك احمد منصور استشارة",
      body: "اشترك لتري الرساله وبيانات المرسل اليك بتفاصيل وتكون ظاهر اولا",
      time: "10:00 am",
      userImage: AssetsData.kUserImage,
      icon: AssetsData.careIcon,
      isRead: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AssetsData.homeBackgroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          CustomAppBar(title: "الإشعارات"),
          Expanded(
            child: notifications.isEmpty
                ? const EmptyNotification()
                : ListView.separated(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return NotificationItem(
                        notification: item,
                        onTap: () {
                          // منطق الضغط العام (Navigation)
                          print("Tapped on ${item.title}");
                        },
                        onAccept: () {
                          // منطق زر القبول
                          print("Accepted ${item.id}");
                        },
                        onReject: () {
                          // منطق زر الرفض
                          print("Rejected ${item.id}");
                        },
                        onSubscribe: () {
                          // منطق زر الاشتراك
                          print("Subscribe clicked for ${item.id}");
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
