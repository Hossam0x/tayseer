import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tayseer/core/notifications/message_config.dart';
import 'package:tayseer/firebase_options.dart';
import 'package:tayseer/tayser_app.dart';
import 'package:tayseer/core/database/cache_cleanup_manager.dart';
import 'package:tayseer/core/database/message_queue_manager.dart';
import 'package:tayseer/core/dependancy_injection/get_it.dart';
import 'package:tayseer/core/shared/network/local_network.dart';
import 'package:tayseer/core/utils/simple_bloc_observer.dart';
import 'package:tayseer/my_import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  LocalNotification().initialize();
  await CachNetwork.cacheInitializaion();
  await setupGetIt();

  // Initialize Chat System (SQLite + Offline Queue + Cache Cleanup)
  await _initializeChatSystem();

  Bloc.observer = SimpleBlocObserver();
  runApp(const TayseerApp());
}

/// Initialize the local-first chat system
Future<void> _initializeChatSystem() async {
  try {
    // Initialize cache cleanup (runs cleanup on startup)
    final cacheCleanup = getIt<CacheCleanupManager>();
    await cacheCleanup.initialize();

    // Start message queue manager for offline support
    final messageQueue = getIt<MessageQueueManager>();
    messageQueue.startRetryTimer();

    debugPrint('✅ Chat system initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Error initializing chat system: $e');
  }
}
