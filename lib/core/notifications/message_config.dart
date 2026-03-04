// import 'dart:math';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import '../../my_import.dart';

// // Class to manage local notifications
// class LocalNotification {
//   // Static instance for background handler usage
//   static final FlutterLocalNotificationsPlugin
//   _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   // Notification channel constants
//   static const String _channelId = 'high_importance_channel';
//   static const String _channelName = 'High Importance Notifications';
//   static const String _channelDescription =
//       'This channel is used for important notifications.';

//   // Initialize notifications
//   Future<void> initialize() async {
//     await Firebase.initializeApp();

//     SharedPreferences prefs = await SharedPreferences.getInstance();

//     // 1️⃣ طلب إذن الإشعارات أولًا
//     await _requestNotificationPermission();

//     // 2️⃣ الآن نحصل على FCM token
//     String? fcmToken = await FirebaseMessaging.instance.getToken();
//     if (fcmToken != null && fcmToken.isNotEmpty) {
//       await prefs.setString('fcm_token', fcmToken);
//       debugPrint('::::::::::::::::::: FCM Token: $fcmToken');
//     } else {
//       debugPrint('FCM token is null or empty, retrying in 2 seconds...');
//       // Retry بعد ثانيتين (مفيد على iOS)
//       await Future.delayed(const Duration(seconds: 2));
//       fcmToken = await FirebaseMessaging.instance.getToken();
//       if (fcmToken != null && fcmToken.isNotEmpty) {
//         await prefs.setString('fcm_token', fcmToken);
//         debugPrint('::::::::::::::::::: FCM Token (retry): $fcmToken');
//       } else {
//         debugPrint('Failed to get FCM token after retry');
//       }
//     }

//     // 3️⃣ إنشاء قناة الإشعارات للأندرويد
//     await _createNotificationChannel();

//     // 4️⃣ إعدادات flutter_local_notifications
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@drawable/app_logo_icon');

//     final DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//           requestSoundPermission: true,
//           requestBadgePermission: true,
//           requestAlertPermission: true,
//         );

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//           android: initializationSettingsAndroid,
//           iOS: initializationSettingsIOS,
//         );

//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         print(
//           'Notification clicked: ID=${response.id}, Payload=${response.payload}',
//         );
//         _handleNotificationClick(response);
//       },
//     );

//     // 5️⃣ Handlers للإشعارات
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       print("Foreground notification received!");
//       if (message.notification?.title != null &&
//           message.notification?.body != null) {
//         await _displayNotification(
//           message.notification?.title ?? 'Notification',
//           message.notification?.body ?? 'Notification content',
//           message.data,
//         );
//       }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('App opened from notification: ${message.notification?.title}');
//       _handleNotificationClick(null, message.data);
//     });
//   }

//   // Create notification channel for Android
//   Future<void> _createNotificationChannel() async {
//     if (Platform.isAndroid) {
//       const AndroidNotificationChannel channel = AndroidNotificationChannel(
//         _channelId,
//         _channelName,
//         description: _channelDescription,
//         importance: Importance.max,
//         playSound: true,
//         enableVibration: true,
//       );

//       await _flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin
//           >()
//           ?.createNotificationChannel(channel);
//     }
//   }

//   // Background handler for notifications
//   static Future<void> _firebaseMessagingBackgroundHandler(
//     RemoteMessage message,
//   ) async {
//     await Firebase.initializeApp();
//     print("Background notification received: ${message.messageId}");
//     print("Title: ${message.notification?.title}");
//     print("Body: ${message.notification?.body}");

//     if (message.notification?.title != null &&
//         message.notification?.body != null) {
//       await _displayNotificationStatic(
//         message.notification?.title ?? 'Notification',
//         message.notification?.body ?? 'Notification content',
//         message.data,
//       );
//     }
//   }

//   // Static method for displaying notification (used in background handler)
//   static Future<void> _displayNotificationStatic(
//     String title,
//     String body,
//     Map<String, dynamic> data,
//   ) async {
//     int notificationId = Random().nextInt(1000000);

//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//           _channelId,
//           _channelName,
//           channelDescription: _channelDescription,
//           importance: Importance.max,
//           priority: Priority.high,
//           showWhen: true,
//           enableVibration: true,
//           playSound: true,
//           icon: '@drawable/app_logo_icon',
//         );

//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     const NotificationDetails platformDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _flutterLocalNotificationsPlugin.show(
//       notificationId,
//       title,
//       body,
//       platformDetails,
//       payload: data.toString(),
//     );
//   }

//   // Request permission for notifications
//   Future<void> _requestNotificationPermission() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       announcement: true,
//       badge: true,
//       carPlay: true,
//       criticalAlert: true,
//       provisional: false,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission: ${settings.authorizationStatus}');
//     } else if (settings.authorizationStatus ==
//         AuthorizationStatus.provisional) {
//       print(
//         'User granted provisional permission: ${settings.authorizationStatus}',
//       );
//     } else {
//       print('User denied permission: ${settings.authorizationStatus}');
//     }

//     if (Platform.isIOS) {
//       await messaging.setForegroundNotificationPresentationOptions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//     }

//     await messaging.subscribeToTopic("all");
//     print("Subscribed to 'all' topic");
//   }

//   // Display notification (instance method)
//   Future<void> _displayNotification(
//     String title,
//     String body,
//     Map<String, dynamic> data,
//   ) async {
//     await _displayNotificationStatic(title, body, data);
//   }

//   // Handle notification click
//   void _handleNotificationClick(
//     NotificationResponse? response, [
//     Map<String, dynamic>? data,
//   ]) {
//     print('Notification clicked!');
//     if (response != null) {
//       print('Response ID: ${response.id}');
//       print('Response Payload: ${response.payload}');
//     }
//     if (data != null) {
//       print('Data: $data');
//     }
//   }

//   Future<String?> getFCMToken() async {
//     return await FirebaseMessaging.instance.getToken();
//   }

//   Future<void> subscribeToTopic(String topic) async {
//     await FirebaseMessaging.instance.subscribeToTopic(topic);
//     print("Subscribed to topic: $topic");
//   }

//   Future<void> unsubscribeFromTopic(String topic) async {
//     await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
//     print("Unsubscribed from topic: $topic");
//   }

//   Future<void> clearAllNotifications() async {
//     await _flutterLocalNotificationsPlugin.cancelAll();
//   }

//   Future<void> clearNotification(int id) async {
//     await _flutterLocalNotificationsPlugin.cancel(id);
//   }
// }

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tayseer/core/utils/router/app_router.dart';
import 'package:tayseer/main.dart';

// ============================================================
// ✅ Top-Level Background Handler
// ============================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("========== 🌙 BACKGROUND MESSAGE ==========");
  print("Message ID: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Data: ${message.data}");

  // لو فيه notification النظام هيعرضه تلقائياً
  if (message.notification != null) {
    print("System will show notification automatically");
    return;
  }

  final plugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  await plugin.initialize(const InitializationSettings(android: initSettings));

  const details = NotificationDetails(
    android: AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  await plugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    message.notification?.title ?? 'Notification',
    message.notification?.body ?? '',
    details,
  );
}

// ============================================================
// ✅ LocalNotification Class
// ============================================================

class LocalNotification {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final GlobalKey<NavigatorState> navigatorKey;

  LocalNotification({required this.navigatorKey});

  Future<void> initialize() async {
    await Firebase.initializeApp();
    await _requestNotificationPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("🔔 Clicked Notification:");
        print("ID: ${response.id}");
        print("Payload: ${response.payload}");
        // ✅ بدل ما نعمل navigate مباشرة، نحفظ الإشعار ونسيب SplashScreen تتعامل معاه
        _handleNotificationClick();
      },
    );

    await _createHighImportanceChannel();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    /// 📩 Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("========== 📩 FOREGROUND MESSAGE ==========");
      _printFullMessage(message);

      await _displayNotification(
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? '',
      );
    });

    /// 🚀 Background click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("========== 🚀 OPENED FROM BACKGROUND ==========");
      _printFullMessage(message);
      // ✅ بدل ما نعمل navigate مباشرة، نحفظ الإشعار
      _handleNotificationClick(message: message);
    });

    /// 🧨 Terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();

    if (initialMessage != null) {
      print("========== 🧨 OPENED FROM TERMINATED ==========");
      _printFullMessage(initialMessage);
      pendingNotificationMessage = initialMessage;
    }

    String? token = await FirebaseMessaging.instance.getToken();
    print("📱 FCM TOKEN: $token");
  }

  /// ✅ معالجة النقر على الإشعار بشكل آمن
  void _handleNotificationClick({RemoteMessage? message}) {
    // لو الـ Navigator جاهز، نروح مباشرة
    if (navigatorKey.currentState != null && navigatorKey.currentState!.mounted) {
      try {
        navigatorKey.currentState!.pushNamed(AppRouter.notification);
        print('✅ Navigated to notifications');
      } catch (e) {
        print('⚠️ Navigation failed, saving for later: $e');
        pendingNotificationMessage = message;
      }
    } else {
      // لو الـ Navigator مش جاهز، نحفظ الإشعار عشان SplashScreen تتعامل معاه
      print('⚠️ Navigator not ready, saving notification for later');
      pendingNotificationMessage = message;
    }
  }

  void _printFullMessage(RemoteMessage message) {
    print("Message ID: ${message.messageId}");
    print("From: ${message.from}");
    print("SentTime: ${message.sentTime}");
    print("------ Notification ------");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("------ Data ------");
    print(message.data);
    print("==============================================");
  }

  Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
    );

    print("🔐 Permission Status: ${settings.authorizationStatus}");

    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission();
    }

    await messaging.subscribeToTopic("all");

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _createHighImportanceChannel() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await androidPlugin.createNotificationChannel(channel);
    }
  }

  Future<void> _displayNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformDetails,
    );
  }

  Future<String?> getFCMToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    print("Subscribed to topic: $topic");
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    print("Unsubscribed from topic: $topic");
  }

  Future<void> clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> clearNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
