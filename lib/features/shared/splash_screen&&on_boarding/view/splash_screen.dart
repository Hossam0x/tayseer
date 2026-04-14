import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/notifications/notificationHelper.dart';
import 'package:tayseer/core/services/deep_link_service.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/main.dart';
import '../../../../my_import.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeSocket();
    _navigateBasedOnToken();
    _playSoundAfterHalfAnimation();
  }

  Future<void> _playSoundAfterHalfAnimation() async {
    // نص الـ animation = 4800 / 2 = 2400ms
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/whistle.mp3'));
    } catch (e) {
      log('🔊 Sound error: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeSocket() async {
    try {
      final userType = CachNetwork.getStringData(key: kUserType);
      final token = CachNetwork.getStringData(key: ktoken);

      if (userType == UserTypeEnum.guest.name || token.isEmpty) return;

      final socketHelper = getIt<tayseerSocketHelper>();
      final connected = await socketHelper.connect();
      if (connected) {
        log('✅ Socket connected successfully');
      } else {
        log('⚠️ Socket connection failed, but continuing...');
      }
    } catch (e) {
      log('❌ Socket initialization error: $e');
    }
  }

  Future<void> _navigateBasedOnToken() async {
    await Future.delayed(const Duration(milliseconds: 4800));
    if (!mounted) return;

    final String token = CachNetwork.getStringData(key: ktoken);
    final String? userType = CachNetwork.getStringData(key: kUserType);

    log(
      '🔍 Navigation check - Token: ${token.isNotEmpty}, '
      'UserType: $userType, selectedUserType: $selectedUserType',
    );

    // ✅ سحب الـ cold start URI وحفظ الـ personId قبل أي حاجة
    final coldUri = pendingDeepLinkUri;
    pendingDeepLinkUri = null;

    final String? coldPersonId = coldUri != null
        ? _extractPersonId(coldUri)
        : null;

    // ✅ لو فيه personId من cold start، احفظه دايماً
    if (coldPersonId != null) {
      pendingDeepLinkPersonId = coldPersonId;
      log('🔗 Cold start deep link personId: $coldPersonId');
    }

    if (!mounted) return;

    if (token.isNotEmpty) {
      // ─── مسجل دخول ───
      _navigateLoggedInUser();

      // ✅ handle pending notification
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (pendingNotificationMessage != null) {
            debugPrint('✅ Handling pending notification from terminated state');
            NotificationHelper.handleNotificationClick(
              message: pendingNotificationMessage,
            );
            pendingNotificationMessage = null;
          }
        });
      });

      // ✅ فتح البروفيل بعد ما الـ Layout يكون جاهز خالص
      if (coldPersonId != null) {
        _openDeepLinkWithRetry(coldPersonId);
      }
    } else {
      // ─── مش مسجل ───
      // الـ pendingDeepLinkPersonId اتحفظ فوق، هيتستخدم بعد Login
      log('⚠️ No token found, navigating to registration');
      if (!mounted) return;
      context.pushReplacementNamed(AppRouter.kRegisrationView);
    }
  }

  void _navigateLoggedInUser() {
    if (!mounted) return;

    if (selectedUserType == UserTypeEnum.asConsultant) {
      if (kCurrentUserData?.compeletedData == true) {
        context.pushReplacementNamed(AppRouter.kAdvisorLayoutView);
      } else {
        context.pushReplacementNamed(AppRouter.kRegisrationView);
      }
    } else if (selectedUserType == UserTypeEnum.user) {
      kCurrentUserData?.isNew == false
          ? context.pushReplacementNamed(AppRouter.kUserLayoutView)
          : context.pushReplacementNamed(AppRouter.kRegisrationView);
    } else {
      navigatorKey.currentState?.pushReplacementNamed(
        AppRouter.kRegisrationView,
      );
    }
  }

  void _openDeepLinkWithRetry(String personId, [int retries = 10]) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      // ✅ تحقق إن الـ navigator جاهز وفيه route مش الـ splash
      final navState = navigatorKey.currentState;

      if (navState != null && navState.canPop()) {
        final id = pendingDeepLinkPersonId;
        if (id != null) {
          pendingDeepLinkPersonId = null;
          log('🔗 Opening deep link profile: $id (retries left: $retries)');
          DeepLinkService.handleMarriageProfileLink(
            context: context,
            personId: id,
          );
        }
      } else if (retries > 0) {
        log('🔗 Navigator not ready, retrying... ($retries left)');
        _openDeepLinkWithRetry(personId, retries - 1);
      } else {
        log('🔗 Max retries reached, deep link lost');
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AppImage(
            AssetsData.kBackgroundtayseerImage,
            fit: BoxFit.fill,
            width: context.width,
            height: context.height,
          ),
          Positioned(
            top: context.height * .3,
            left: 0,
            right: 0,
            child: Hero(
              tag: 'app_logo',
              child: AppImage(
                AssetsData.kAppLogoGif,
                width: context.width * 0.4,
                height: context.height * 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
