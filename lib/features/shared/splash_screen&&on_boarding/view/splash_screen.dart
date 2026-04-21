import 'dart:developer';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/notifications/notificationHelper.dart';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/services/chat_socket_service.dart';
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
      // استخدام AudioService عشان يحترم إعداد الصوت
      await AudioService.instance.playSound(
        AudioService.splashSound,
        forcePlay: false,
      );
    } catch (e) {
      log('🔊 Sound error: $e');
    }
  }

  Future<void> _initializeSocket() async {
    try {
      final userType = CachNetwork.getStringData(key: kUserType);
      final token = CachNetwork.getStringData(key: ktoken);

      if (userType == UserTypeEnum.guest.name || token.isEmpty) return;

      final socketHelper = getIt<tayseerSocketHelper>();
      final chatSocketService = getIt<ChatSocketService>();

      // ✅ FIX 1: لو الـ socket already connected (من _connectSocketForNewUser بعد login)
      // تأكد بس إن الـ ChatSocketService initialized وارجع
      if (socketHelper.isConnected) {
        log(
          '✅ Splash: Socket already connected, ensuring ChatSocketService is init',
        );
        // لو مش initialized، initialize
        chatSocketService.init();
        return;
      }

      // ✅ FIX 2: استخدم resetAndConnect بدل connect مباشرة
      // عشان يضمن إن _authorizedToken بيتعيَّن صح
      // وأي reconnect مستقبلي هيستخدم نفس الـ token
      log('🔄 Splash: Connecting socket via resetAndConnect...');
      final connected = await socketHelper.resetAndConnect(token: token);

      if (connected) {
        chatSocketService.init();
        log('✅ Splash: Socket connected and ChatSocketService initialized');
      } else {
        log('⚠️ Splash: Socket connection failed, but continuing app flow...');
      }
    } catch (e) {
      log('❌ Splash: Socket initialization error: $e');
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

    final coldUri = pendingDeepLinkUri;
    pendingDeepLinkUri = null;

    final String? coldPersonId = coldUri != null
        ? DeepLinkService.extractPersonId(coldUri)
        : null;
    final String? coldAdvisorId = coldUri != null
        ? DeepLinkService.extractAdvisorId(coldUri)
        : null;
    final String? coldUserId = coldUri != null
        ? DeepLinkService.extractUserId(coldUri)
        : null;
    final String? coldPostId = coldUri != null
        ? DeepLinkService.extractPostId(coldUri)
        : null;

    if (coldPersonId != null) {
      pendingDeepLinkPersonId = coldPersonId;
      log('🔗 Cold start marriage deep link: $coldPersonId');
    } else if (coldAdvisorId != null) {
      pendingDeepLinkAdvisorId = coldAdvisorId;
      log('🔗 Cold start advisor deep link: $coldAdvisorId');
    } else if (coldUserId != null) {
      pendingDeepLinkUserId = coldUserId;
      log('🔗 Cold start user deep link: $coldUserId');
    } else if (coldPostId != null) {
      pendingDeepLinkPostId = coldPostId;
      log('🔗 Cold start post deep link: $coldPostId');
    }

    if (!mounted) return;

    if (token.isNotEmpty) {
      _navigateLoggedInUser();

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
    } else {
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
