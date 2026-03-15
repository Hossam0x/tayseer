import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
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

/// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// لو وصل deep link والمستخدم مش مسجل — نحفظه هنا ونفتحه بعد اللوجن
String? pendingDeepLinkPersonId;

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
  await getIt<ConnectivityService>().initialize();
  await _initializeVideoSystem();
  await GlobalMuteManager.instance.init();

  Bloc.observer = SimpleBlocObserver();
  runApp(const TayseerApp());

  // ✅ Deep Links — بعد runApp
  _initDeepLinks();
}

// ─────────────────────────────────────────────
// Deep Links
// ─────────────────────────────────────────────

void _initDeepLinks() async {
  final appLinks = AppLinks();

  // Cold start — التطبيق كان مقفولاً
  final uri = await appLinks.getInitialLink();
  if (uri != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleDeepLink(uri);
    });
  }

  // Warm start — التطبيق في الخلفية
  appLinks.uriLinkStream.listen(
    _handleDeepLink,
    onError: (e) => debugPrint('DeepLink stream error: $e'),
  );
}

void _handleDeepLink(Uri uri) {
  debugPrint('🔗 DeepLink received: $uri');

  final segments = uri.pathSegments;

  // https://tayseer.app/marriage/profile/{personId}
  if (segments.length >= 3 &&
      segments[0] == 'marriage' &&
      segments[1] == 'profile') {
    _navigateToProfile(segments[2]);
    return;
  }

  // tayseer://marriage?profileId={personId}
  if (uri.scheme == 'tayseer' && uri.host == 'marriage') {
    final personId = uri.queryParameters['profileId'];
    if (personId != null) _navigateToProfile(personId);
    return;
  }
}

void _navigateToProfile(String personId) {
  final token = CachNetwork.getStringData(key: ktoken);
  final hasToken = token != null && token.isNotEmpty;

  if (!hasToken || isGuest || isUserAnonymous) {
    // ✅ احفظ الـ personId عشان نفتحه بعد اللوجن
    pendingDeepLinkPersonId = personId;
    debugPrint('🔗 Deep link saved for after login: $personId');
    return; // لا تعمل navigate — الـ splash سيتولى الأمر
  }

  // المستخدم مسجل → روح البروفايل مباشرة
  navigatorKey.currentState?.pushNamed(
    AppRouter.kMarriageView,
    arguments: {'personId': personId},
  );
}

/// استدعيها بعد نجاح اللوجن (في RegisrationView أو SplashScreen)
void consumePendingDeepLink() {
  final personId = pendingDeepLinkPersonId;
  if (personId == null) return;

  pendingDeepLinkPersonId = null; // امسح بعد الاستخدام

  debugPrint('🔗 Consuming pending deep link: $personId');
  navigatorKey.currentState?.pushNamed(
    AppRouter.kMarriageView,
    arguments: {'personId': personId},
  );
}

Future<void> _initializeVideoSystem() async {
  try {
    await VideoControllerManager().initialize();
    debugPrint('✅ Video system initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Error initializing video system: $e');
  }
}