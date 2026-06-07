import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tayseer/core/notifications/notificationHelper.dart';
import 'package:tayseer/core/utils/notification_event_bus.dart';

// ─── Shared blur helper (works in both isolates) ─────────────────────────────

/// Downloads [url] and returns the raw bytes.
Future<Uint8List> _fetchImageBytes(String url) async {
  final dio = Dio();
  final response = await dio.get<List<int>>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );
  return Uint8List.fromList(response.data ?? []);
}

// ─── Background handler ───────────────────────────────────────────────────────

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("========== 🌙 BACKGROUND MESSAGE ==========");
  print("Message ID: ${message.messageId}");
  print("Title: ${message.notification?.title}");
  print("Data: ${message.data}");

  final String? matchImage = message.data['matchImage'] as String?;
  final bool hasSuggestedMatch =
      message.data['subType'] == 'suggested_match' &&
      matchImage != null &&
      matchImage.isNotEmpty;
  final String matchImageUrl = matchImage ?? '';

  // Parse matchBlur — backend sends bool or the string "true"
  final dynamic rawBlur = message.data['matchBlur'];
  final bool matchBlur =
      rawBlur == true || rawBlur?.toString().toLowerCase() == 'true';

  // If there's a notification payload AND no special image to show,
  // let the system handle it automatically to avoid duplicates.
  if (message.notification != null && !hasSuggestedMatch) {
    print("System will show notification automatically — skipping local");
    return;
  }

  // Get title/body from notification payload or data fields
  final title = (message.notification?.title ?? message.data['title'] ?? '')
      .toString()
      .trim();
  final body = (message.notification?.body ?? message.data['body'] ?? '')
      .toString()
      .trim();

  if (title.isEmpty && body.isEmpty) {
    print("⚠️ Empty title+body — skipping");
    return;
  }

  final plugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  await plugin.initialize(const InitializationSettings(android: initSettings));

  AndroidNotificationDetails androidDetails;

  if (hasSuggestedMatch && !matchBlur) {
    // matchBlur == true → show plain notification without image
    try {
      final Uint8List imageBytes = await _fetchImageBytes(matchImageUrl);
      final bitmap = ByteArrayAndroidBitmap(imageBytes);
      androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: bitmap,
        styleInformation: BigPictureStyleInformation(
          bitmap,
          largeIcon: bitmap,
          contentTitle: title,
          summaryText: body,
          hideExpandedLargeIcon: false,
        ),
      );
      // Cancel any system notification Firebase may have already shown
      // before we show our local one with the image
      await plugin.cancelAll();
      print("✅ Background notification with image");
    } catch (e) {
      print("⚠️ Failed to load image, falling back: $e");
      androidDetails = const AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );
    }
  } else {
    androidDetails = const AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
  }

  final details = NotificationDetails(
    android: androidDetails,
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    ),
  );

  await plugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title.isNotEmpty ? title : 'Notification',
    body,
    details,
    payload: jsonEncode(message.data),
  );
}

// ─── LocalNotification class ─────────────────────────────────────────────────

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

      // 🔔 Notify HomeCubit (and any other listener) to refresh notification count
      NotificationEventBus.instance.fire();

      // On iOS in foreground: setForegroundNotificationPresentationOptions
      // already shows the system notification banner — skip local notification
      // to avoid duplicates. iOS handles the display natively.
      if (Platform.isIOS) return;

      // On Android, Firebase does NOT show notifications automatically when the
      // app is in the foreground — we must show a local notification ourselves.
      final notifTitle = message.notification?.title?.trim() ?? '';
      final notifBody = message.notification?.body?.trim() ?? '';

      // Prefer notification payload title/body; fall back to data fields.
      final title = notifTitle.isNotEmpty
          ? notifTitle
          : (message.data['title'] ?? '').toString().trim();
      final body = notifBody.isNotEmpty
          ? notifBody
          : (message.data['body'] ?? '').toString().trim();

      if (title.isEmpty && body.isEmpty) return;

      // For suggested_match, show the match's image (optionally blurred) in the banner
      final String? imageUrl = message.data['matchImage'] as String?;
      final dynamic rawBlur = message.data['matchBlur'];
      final bool matchBlur =
          rawBlur == true || rawBlur?.toString().toLowerCase() == 'true';

      await _displayNotification(
        title.isNotEmpty ? title : 'Notification',
        body,
        payload: jsonEncode(message.data),
        imageUrl: imageUrl,
        blurImage: matchBlur,
      );
    });

    /// 🚀 Background click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("========== 🚀 OPENED FROM BACKGROUND ==========");
      _printFullMessage(message);
      NotificationHelper.handleNotificationClick(message: message);
    });

    // Wrap getToken in try/catch — silently ignore offline/unknown errors
    // (FirebaseException code 'unknown' when device has no internet at launch)
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print("📱 FCM TOKEN: $token");
    } on FirebaseException catch (e) {
      if (e.code == 'unknown' &&
          (e.message?.contains('offline') == true ||
              e.message?.contains('Internet') == true ||
              e.message?.contains('network') == true)) {
        debugPrint('⚠️ FCM getToken skipped — device is offline: ${e.message}');
      } else {
        debugPrint('⚠️ FCM getToken error (${e.code}): ${e.message}');
      }
    } catch (e) {
      // Catches PlatformException and any other errors silently
      debugPrint('⚠️ FCM getToken failed (silent): $e');
    }
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
    String? imageUrl,
    bool blurImage = false,
  }) async {
    AndroidNotificationDetails androidDetails;

    // blurImage == true → don't show the image in the notification
    if (imageUrl != null && imageUrl.isNotEmpty && !blurImage) {
      try {
        final Uint8List imageBytes = await _fetchImageBytes(imageUrl);
        final bitmap = ByteArrayAndroidBitmap(imageBytes);
        androidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          largeIcon: bitmap,
          styleInformation: BigPictureStyleInformation(
            bitmap,
            largeIcon: bitmap,
            contentTitle: title,
            summaryText: body,
            hideExpandedLargeIcon: false,
          ),
        );
      } catch (_) {
        androidDetails = const AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        );
      }
    } else {
      androidDetails = const AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );
    }

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
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
