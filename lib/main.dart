import 'package:app_links/app_links.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:tayseer/core/cache/chat_cache_service.dart';
import 'package:tayseer/core/notifications/message_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tayseer/core/services/appsflyer_service.dart';
import 'package:tayseer/core/services/paymob_config_service.dart';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/services/connectivity_service.dart';
import 'package:tayseer/core/services/deep_link_service.dart';
import 'package:tayseer/core/services/screenshot_detector.dart';
import 'package:tayseer/core/utils/global_mute_manager.dart';
import 'package:tayseer/firebase_options.dart';
import 'package:tayseer/core/utils/app_navigator.dart';
import 'package:tayseer/tayser_app.dart';
import 'package:tayseer/core/utils/simple_bloc_observer.dart';
import 'package:tayseer/core/video/video_controller_manager.dart';
// ⚠️ ADS TEMPORARILY DISABLED
// import 'package:tayseer/core/services/ad_service.dart';
// import 'package:tayseer/core/services/ads_config.dart';
import 'package:tayseer/my_import.dart';

// ─────────────────────────────────────────────
// Globals
// ─────────────────────────────────────────────

// navigatorKey is defined in app_navigator.dart and re-exported here
// for backward compatibility with existing code that imports from main.dart.
export 'package:tayseer/core/utils/app_navigator.dart' show navigatorKey;

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

  // ✅ تفعيل StoreKit 2 — بعد ensureInitialized مباشرة
  // بيخلي serverVerificationData يرجع JWS (JWT موقع من Apple) بدل PKCS#7 blob
  if (Platform.isIOS) {
    await InAppPurchaseStoreKitPlatform.enableStoreKit2();
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light, // Android: white icons
      statusBarBrightness: Brightness.dark, // iOS: white icons
    ),
  );

  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await CachNetwork.cacheInitializaion();
  await setupGetIt();

  // ⚠️ ADS TEMPORARILY DISABLED — uncomment when Google Ads account is ready.
  // await AdsConfig.instance.load();
  // await getIt<AdService>().initialize();
  // getIt<AdService>().debugAdState();

  // Initialize ChatCacheService
  await getIt<ChatCacheService>().init();

  // Fire-and-forget: refresh Paymob status + store links in background
  getIt<PaymobConfigService>().fetchAndUpdateStatus();

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

  // ✅ تجاهل PlatformException المعروفة من UiKitView على iOS:
  //   • unknown_view   — gesture arena يبعت event لـ platform view اتـdispose
  //   • recreating_view — hot restart يحاول يعمل view جديد بنفس الـ id القديم
  // كلهم race conditions معروفة في Flutter ومش بيأثروا على الـ UX
  PlatformDispatcher.instance.onError = (error, stack) {
    if (error is PlatformException &&
        (error.code == 'unknown_view' || error.code == 'recreating_view')) {
      return true; // تجاهل بصمت
    }
    return false; // اتركه للـ default handler
  };

  // ✅ زود حجم الـ ImageCache — Task 1.4: cap at 150 MB
  PaintingBinding.instance.imageCache.maximumSize = 500;
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      150 * 1024 * 1024; // 150 MB

  // ✅ أولاً runApp عشان الـ Navigator يكون جاهز
  runApp(const AppRestarter(child: TayseerApp()));

  // ✅ تشغيل مراقب الـ screenshot على Android
  ScreenshotDetector.init();

  // ✅ بعد runApp — initialize الإشعارات وATT بعد ما التطبيق يشتغل
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // Initialize AudioService AFTER runApp so platform channels are ready
    await AudioService.instance.initialize();

    final localNotification = LocalNotification(navigatorKey: navigatorKey);
    await localNotification.initialize();

    // ✅ ATT request بعد ما الـ UI يكون جاهز تماماً
    // Apple تشترط أن يكون الـ UIWindow ظاهراً قبل طلب الإذن
    // استدعاؤه قبل runApp يمنع ظهور الـ dialog على بعض الأجهزة
    await _initAppsFlyer();
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

// ─────────────────────────────────────────────
// AppsFlyer + ATT
// ─────────────────────────────────────────────

/// على iOS: نطلب ATT أولاً ثم نهيئ AppsFlyer بغض النظر عن قرار المستخدم.
/// على Android: نهيئ مباشرة بدون ATT.
Future<void> _initAppsFlyer() async {
  if (Platform.isIOS) {
    // ✅ نتحقق من الحالة الحالية — لو مش determined نطلب الإذن
    final status = await AppTrackingTransparency.trackingAuthorizationStatus;
    debugPrint('📊 ATT initial status: $status');

    if (status == TrackingStatus.notDetermined) {
      debugPrint('📊 ATT: Requesting authorization...');
      // ✅ نأخر عشان الـ UIWindow يكون ظاهر تماماً — Apple requirement
      // الـ 200ms مش كافية على بعض الأجهزة، خصوصاً iPad وiPadOS الجديد
      await Future.delayed(const Duration(milliseconds: 500));
      final result =
          await AppTrackingTransparency.requestTrackingAuthorization();
      debugPrint('📊 ATT: User response: $result');
    } else {
      debugPrint('📊 ATT: Already determined, skipping request');
    }

    final updatedStatus =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    debugPrint('📊 ATT final status: $updatedStatus');
  }

  // ✅ نهيئ AppsFlyer بغض النظر عن قرار ATT
  // AppsFlyer SDK بيتعامل مع الـ limited tracking تلقائياً
  await AppsFlyerService.instance.initialize();
}
