import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tayseer/core/notifications/message_config.dart';
import 'package:tayseer/firebase_options.dart';
import 'package:tayseer/tayser_app.dart';
import 'package:tayseer/core/database/cache_cleanup_manager.dart';
import 'package:tayseer/core/database/message_queue_manager.dart';
import 'package:tayseer/core/utils/simple_bloc_observer.dart';
import 'package:tayseer/core/video/video_controller_manager.dart';
import 'package:tayseer/my_import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  LocalNotification().initialize();
  await CachNetwork.cacheInitializaion();
  await setupGetIt();

  await _initializeChatSystem();
  await _initializeVideoSystem();

  Bloc.observer = SimpleBlocObserver();
  runApp(const TayseerApp());
}

Future<void> _initializeVideoSystem() async {
  try {
    await VideoControllerManager().initialize();
    debugPrint('✅ Video system initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Error initializing video system: $e');
  }
}

Future<void> _initializeChatSystem() async {
  try {
    final cacheCleanup = getIt<CacheCleanupManager>();
    await cacheCleanup.initialize();

    final messageQueue = getIt<MessageQueueManager>();
    messageQueue.startRetryTimer();

    debugPrint('✅ Chat system initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Error initializing chat system: $e');
  }
}
