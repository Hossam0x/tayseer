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

// ─────────────────────────────────────────────
// Globals
// ─────────────────────────────────────────────

/// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// الـ URI الخام — يُحفظ هنا فقط، الـ SplashScreen هو اللي يتعامل معه
Uri? pendingDeepLinkUri;

/// personId بعد ما يسجل دخول
String? pendingDeepLinkPersonId;

/// ✅ متغير global - HomeScreen هتاخده وتعمل Navigate
RemoteMessage? pendingNotificationMessage;

// ─────────────────────────────────────────────
// Main
// ─────────────────────────────────────────────

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

  // ✅ نحفظ الـ cold start URI قبل runApp — بدون أي navigation هنا
  await _captureColdStartLink();

  // ✅ نحفظ الـ cold start notification قبل runApp
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    pendingNotificationMessage = initialMessage;
  }

  Bloc.observer = SimpleBlocObserver();

  // ✅ أولاً runApp عشان الـ Navigator يكون جاهز
  runApp(const TayseerApp());

  // ✅ بعد runApp — initialize الإشعارات بعد ما التطبيق يشتغل
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final localNotification = LocalNotification(navigatorKey: navigatorKey);
    await localNotification.initialize();
  });

  // ✅ Warm start فقط — التطبيق في الخلفية
  _listenToWarmStartLinks();
}

// ─────────────────────────────────────────────
// Deep Links
// ─────────────────────────────────────────────

Future<void> _captureColdStartLink() async {
  try {
    final appLinks = AppLinks();
    final uri = await appLinks.getInitialLink();
    if (uri != null) {
      pendingDeepLinkUri = uri;
      debugPrint('🔗 Cold start URI captured: $uri');
    }
  } catch (e) {
    debugPrint('⚠️ Failed to capture cold start link: $e');
  }
}

void _listenToWarmStartLinks() {
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen(
        (uri) {
      debugPrint('🔗 Warm start DeepLink received: $uri');

      // ✅ تجاهل لو نفس الـ cold start URI
      if (pendingDeepLinkUri != null &&
          uri.toString() == pendingDeepLinkUri.toString()) {
        debugPrint('🔗 Ignoring duplicate warm start (same as cold start)');
        return;
      }

      // ✅ delay + postFrameCallback عشان Navigator يكون جاهز
      Future.delayed(const Duration(milliseconds: 300), () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateFromUri(uri);
        });
      });
    },
    onError: (e) => debugPrint('DeepLink stream error: $e'),
  );
}

String? _extractPersonId(Uri uri) {
  final segments = uri.pathSegments;

  if (segments.length >= 3 &&
      segments[0] == 'marriage' &&
      segments[1] == 'profile') {
    return segments[2];
  }

  if (uri.scheme == 'tayseer' && uri.host == 'marriage') {
    return uri.queryParameters['profileId'];
  }

  return null;
}

void _navigateFromUri(Uri uri) {
  final personId = _extractPersonId(uri);
  if (personId == null) return;

  final token = CachNetwork.getStringData(key: ktoken);
  final hasToken = token != null && token.isNotEmpty;

  if (!hasToken || isGuest || isUserAnonymous) {
    pendingDeepLinkPersonId = personId;
    debugPrint('🔗 Warm start: saved for after login: $personId');
    return;
  }

  _navigateSafely(personId);
}

void _navigateSafely(String personId) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed(
        AppRouter.kMarriageView,
        arguments: {'personId': personId},
      );
    } else {
      pendingDeepLinkPersonId = personId;
      debugPrint('🔗 Navigator not ready, saved as pending: $personId');
    }
  });
}

/// ✅ استدعيها بعد نجاح اللوجن في RegistrationView
void consumePendingDeepLink() {
  final personId = pendingDeepLinkPersonId;
  if (personId == null) return;

  pendingDeepLinkPersonId = null;
  debugPrint('🔗 Consuming pending deep link: $personId');

  WidgetsBinding.instance.addPostFrameCallback((_) {
    navigatorKey.currentState?.pushNamed(
      AppRouter.kMarriageView,
      arguments: {'personId': personId},
    );
  });
}

// ─────────────────────────────────────────────
// Video
// ─────────────────────────────────────────────

Future<void> _initializeVideoSystem() async {
  try {
    await VideoControllerManager().initialize();
    debugPrint('✅ Video system initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Error initializing video system: $e');
  }
}