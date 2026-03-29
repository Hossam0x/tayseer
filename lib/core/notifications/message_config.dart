import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tayseer/core/notifications/notificationHelper.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("========== 🌙 BACKGROUND MESSAGE ==========");
  print("Message ID: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Data: ${message.data}");

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

        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final data = jsonDecode(response.payload!);
            final fakeMessage = RemoteMessage(
              data: Map<String, String>.from(data),
            );
            NotificationHelper.handleNotificationClick(message: fakeMessage);
          } catch (e) {
            print("⚠️ Failed to parse payload: $e");
            NotificationHelper.handleNotificationClick();
          }
        } else {
          NotificationHelper.handleNotificationClick();
        }
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
        payload: jsonEncode(message.data),
      );
    });

    /// 🚀 Background click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("========== 🚀 OPENED FROM BACKGROUND ==========");
      _printFullMessage(message);
      NotificationHelper.handleNotificationClick(message: message);
    });

    String? token = await FirebaseMessaging.instance.getToken();
    print("📱 FCM TOKEN: $token");
  }

  void _printFullMessage(RemoteMessage message) {
    final logData = {
      'message_id': message.messageId,
      'from': message.from,
      'sent_time': message.sentTime?.toIso8601String(),
      'notification': {
        'title': message.notification?.title,
        'body': message.notification?.body,
      },
      'data': message.data,
    };

    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(logData);

    debugPrint('========== RemoteMessage ==========');
    debugPrint(prettyJson);
    debugPrint('====================================');
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

  Future<void> _displayNotification(
    String title,
    String body, {
    String? payload,
  }) async {
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
      payload: payload,
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
