import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tayseer/core/notifications/message_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tayseer/core/services/connectivity_service.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/firebase_options.dart';
import 'package:tayseer/tayser_app.dart';
import 'package:tayseer/core/utils/simple_bloc_observer.dart';
import 'package:tayseer/core/video/video_controller_manager.dart';
import 'package:tayseer/my_import.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ✅ متغير global - HomeScreen هتاخده وتعمل Navigate
RemoteMessage? pendingNotificationMessage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CachNetwork.cacheInitializaion();
  await setupGetIt();
  await getIt<ConnectivityService>().initialize();
  await _initializeVideoSystem();
  await GlobalMuteManager.instance.init();
  final RemoteMessage? initialMessage = await FirebaseMessaging.instance
      .getInitialMessage();
  if (initialMessage != null) {
    pendingNotificationMessage = initialMessage;
  }
  Bloc.observer = SimpleBlocObserver();

  // ✅ أولاً runApp عشان الـ Navigator يكون جاهز
  runApp(const TayseerApp());

  // ✅ بعدين initialize الإشعارات بعد ما التطبيق يشتغل
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final LocalNotification localNotification = LocalNotification(
      navigatorKey: navigatorKey,
    );
    await localNotification.initialize();
  });
}

Future<void> _initializeVideoSystem() async {
  try {
    await VideoControllerManager().initialize();
    debugPrint('✅ Video system initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Error initializing video system: $e');
  }
}


