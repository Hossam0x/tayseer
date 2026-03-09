import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tayseer/core/notifications/message_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/firebase_options.dart';
import 'package:tayseer/tayser_app.dart';
import 'package:tayseer/core/utils/simple_bloc_observer.dart';
import 'package:tayseer/core/video/video_controller_manager.dart';
import 'package:tayseer/my_import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  LocalNotification().initialize();
  await CachNetwork.cacheInitializaion();
  await setupGetIt();
  await _initializeVideoSystem();
  await GlobalMuteManager.instance.init();

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
