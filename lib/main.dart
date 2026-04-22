import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:tayseer/core/cache/chat_cache_service.dart';
import 'package:tayseer/core/notifications/message_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/services/connectivity_service.dart';
import 'package:tayseer/core/services/deep_link_service.dart';
import 'package:tayseer/core/services/screenshot_detector.dart';
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

/// personId بعد ما يسجل دخول (marriage)
String? pendingDeepLinkPersonId;

/// advisorId بعد ما يسجل دخول
String? pendingDeepLinkAdvisorId;

/// userId بعد ما يسجل دخول (user public profile)
String? pendingDeepLinkUserId;

/// postId بعد ما يسجل دخول
String? pendingDeepLinkPostId;

/// ✅ flag — بيتبقى true لما الـ Layout يكون جاهز فعلاً
bool isMainLayoutReady = false;

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

  // Initialize ChatCacheService
  await getIt<ChatCacheService>().init();

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

  // ✅ زود حجم الـ ImageCache — الـ default (100 صورة / 100MB) قليل جداً
  // للـ social media feed. بدونها الصور بتتطرد من الـ memory cache
  // ولما ترجع بـ pop بتتحمل من الـ disk cache → flicker
  PaintingBinding.instance.imageCache.maximumSize = 500;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 300 << 20; // 300 MB

  // ✅ أولاً runApp عشان الـ Navigator يكون جاهز
  runApp(const TayseerApp());

  // ✅ تشغيل مراقب الـ screenshot على Android
  ScreenshotDetector.init();

  // ✅ بعد runApp — initialize الإشعارات بعد ما التطبيق يشتغل
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // Initialize AudioService AFTER runApp so platform channels are ready
    await AudioService.instance.initialize();

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
  appLinks.uriLinkStream.listen((uri) {
    debugPrint('🔗 Warm start DeepLink received: $uri');
    // ✅ تجاهل لو نفس الـ cold start URI
    if (pendingDeepLinkUri != null &&
        uri.toString() == pendingDeepLinkUri.toString()) {
      debugPrint('🔗 Ignoring duplicate warm start (same as cold start)');
      return;
    }

    _navigateFromUri(uri);
  }, onError: (e) => debugPrint('DeepLink stream error: $e'));
}

String? _extractPersonId(Uri uri) {
  return DeepLinkService.extractPersonId(uri);
}

String? _extractAdvisorId(Uri uri) {
  return DeepLinkService.extractAdvisorId(uri);
}

String? _extractUserId(Uri uri) {
  return DeepLinkService.extractUserId(uri);
}

String? _extractPostId(Uri uri) {
  return DeepLinkService.extractPostId(uri);
}

void _navigateFromUri(Uri uri) {
  final token = CachNetwork.getStringData(key: ktoken);
  final hasToken = token.isNotEmpty;

  // ── Marriage ──
  final personId = _extractPersonId(uri);
  if (personId != null) {
    if (!hasToken || isGuest || isUserAnonymous) {
      pendingDeepLinkPersonId = personId;
      debugPrint('🔗 Warm start: saved marriage for after login: $personId');
      return;
    }
    _navigateMarriageSafely(personId);
    return;
  }

  // ── Advisor ──
  final advisorId = _extractAdvisorId(uri);
  if (advisorId != null) {
    if (!hasToken || isGuest || isUserAnonymous) {
      pendingDeepLinkAdvisorId = advisorId;
      debugPrint('🔗 Warm start: saved advisor for after login: $advisorId');
      return;
    }
    _navigateAdvisorSafely(advisorId);
    return;
  }

  // ── User public profile ──
  final userId = _extractUserId(uri);
  if (userId != null) {
    if (!hasToken || isGuest || isUserAnonymous) {
      pendingDeepLinkUserId = userId;
      debugPrint('🔗 Warm start: saved user for after login: $userId');
      return;
    }
    _navigateUserSafely(userId);
    return;
  }

  // ── Post ──
  final postId = _extractPostId(uri);
  if (postId != null) {
    if (!hasToken || isGuest || isUserAnonymous) {
      pendingDeepLinkPostId = postId;
      debugPrint('🔗 Warm start: saved post for after login: $postId');
      return;
    }
    _navigatePostSafely(postId);
    return;
  }
}

void _navigateMarriageSafely(String personId) {
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

void _navigateAdvisorSafely(String advisorId) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed(
        AppRouter.kUserProfileView,
        arguments: {'advisorId': advisorId},
      );
    } else {
      pendingDeepLinkAdvisorId = advisorId;
      debugPrint(
        '🔗 Navigator not ready, saved advisor as pending: $advisorId',
      );
    }
  });
}

void _navigateUserSafely(String userId) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed(
        AppRouter.kUserPublicProfileView,
        arguments: userId,
      );
    } else {
      pendingDeepLinkUserId = userId;
      debugPrint('🔗 Navigator not ready, saved user as pending: $userId');
    }
  });
}

void _navigatePostSafely(String postId) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamed(
        AppRouter.kPostDetailsView,
        arguments: {'postID': postId},
      );
    } else {
      pendingDeepLinkPostId = postId;
      debugPrint('🔗 Navigator not ready, saved post as pending: $postId');
    }
  });
}

/// ✅ استدعيها بعد نجاح اللوجن في RegistrationView
void consumePendingDeepLink() {
  // ── Marriage ──
  final personId = pendingDeepLinkPersonId;
  if (personId != null) {
    pendingDeepLinkPersonId = null;
    debugPrint('🔗 Consuming pending marriage deep link: $personId');
    void tryNavigate([int retries = 5]) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamed(
            AppRouter.kMarriageView,
            arguments: {'personId': personId},
          );
        } else if (retries > 0) {
          Future.delayed(
            const Duration(milliseconds: 300),
            () => tryNavigate(retries - 1),
          );
        }
      });
    }

    tryNavigate();
    return;
  }

  // ── Advisor ──
  final advisorId = pendingDeepLinkAdvisorId;
  if (advisorId != null) {
    pendingDeepLinkAdvisorId = null;
    debugPrint('🔗 Consuming pending advisor deep link: $advisorId');
    void tryNavigate([int retries = 5]) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamed(
            AppRouter.kUserProfileView,
            arguments: {'advisorId': advisorId},
          );
        } else if (retries > 0) {
          Future.delayed(
            const Duration(milliseconds: 300),
            () => tryNavigate(retries - 1),
          );
        }
      });
    }

    tryNavigate();
    return;
  }

  // ── User public profile ──
  final userId = pendingDeepLinkUserId;
  if (userId != null) {
    pendingDeepLinkUserId = null;
    debugPrint('🔗 Consuming pending user deep link: $userId');
    void tryNavigate([int retries = 5]) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamed(
            AppRouter.kUserPublicProfileView,
            arguments: userId,
          );
        } else if (retries > 0) {
          Future.delayed(
            const Duration(milliseconds: 300),
            () => tryNavigate(retries - 1),
          );
        }
      });
    }

    tryNavigate();
    return;
  }

  // ── Post ──
  final postId = pendingDeepLinkPostId;
  if (postId != null) {
    pendingDeepLinkPostId = null;
    debugPrint('🔗 Consuming pending post deep link: $postId');
    void tryNavigate([int retries = 5]) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamed(
            AppRouter.kPostDetailsView,
            arguments: {'postID': postId},
          );
        } else if (retries > 0) {
          Future.delayed(
            const Duration(milliseconds: 300),
            () => tryNavigate(retries - 1),
          );
        }
      });
    }

    tryNavigate();
    return;
  }
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
