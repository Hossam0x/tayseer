import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../my_import.dart';

// Class to manage local notifications
class LocalNotification {
  // Static instance for background handler usage
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Notification channel constants
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription =
      'This channel is used for important notifications.';

  // Initialize notifications
  Future<void> initialize() async {
    await Firebase.initializeApp();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null && fcmToken.isNotEmpty) {
      await prefs.setString('fcm_token', fcmToken);
      debugPrint(':::::::::::::::::::fcm_token: $fcmToken');
    } else {
      debugPrint('FCM token is null or empty');
    }
    //test notification display
    // _displayNotification(
    //   "اهلا بك😉",
    //   "نتاكد ان الاشعارات شغاله مع تحياتي المهندس خالد❤",
    //   {"key": "value"},
    // );
    // Create Android notification channel

    await _createNotificationChannel();

    // Request user permission for notifications
    await _requestNotificationPermission();

    // Initialize notification settings for Android and iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/app_logo_icon');

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

    // Initialize flutterLocalNotificationsPlugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print(
          'Notification clicked: ID=${response.id}, Payload=${response.payload}',
        );
        _handleNotificationClick(response);
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("Foreground notification received!");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      print("Data: ${message.data}");

      if (message.notification?.title != null &&
          message.notification?.body != null) {
        await _displayNotification(
          message.notification?.title ?? 'Notification',
          message.notification?.body ?? 'Notification content',
          message.data,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from notification: ${message.notification?.title}');
      _handleNotificationClick(null, message.data);
    });

    String? token = await FirebaseMessaging.instance.getToken();
    print("FCM Token: $token");
  }

  // Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  // Background handler for notifications
  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    await Firebase.initializeApp();
    print("Background notification received: ${message.messageId}");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");

    if (message.notification?.title != null &&
        message.notification?.body != null) {
      await _displayNotificationStatic(
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? 'Notification content',
        message.data,
      );
    }
  }

  // Static method for displaying notification (used in background handler)
  static Future<void> _displayNotificationStatic(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    int notificationId = Random().nextInt(1000000);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@drawable/app_logo_icon',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      platformDetails,
      payload: data.toString(),
    );
  }

  // Request permission for notifications
  Future<void> _requestNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission: ${settings.authorizationStatus}');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print(
        'User granted provisional permission: ${settings.authorizationStatus}',
      );
    } else {
      print('User denied permission: ${settings.authorizationStatus}');
    }

    if (Platform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    await messaging.subscribeToTopic("all");
    print("Subscribed to 'all' topic");
  }

  // Display notification (instance method)
  Future<void> _displayNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    await _displayNotificationStatic(title, body, data);
  }

  // Handle notification click
  void _handleNotificationClick(
    NotificationResponse? response, [
    Map<String, dynamic>? data,
  ]) {
    print('Notification clicked!');
    if (response != null) {
      print('Response ID: ${response.id}');
      print('Response Payload: ${response.payload}');
    }
    if (data != null) {
      print('Data: $data');
    }
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
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> clearNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
