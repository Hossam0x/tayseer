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

    // ✅ سحب الـ cold start URI وحفظ الـ IDs قبل أي حاجة
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

    // ✅ لو فيه ID من cold start، احفظه
    if (coldPersonId != null) {
      pendingDeepLinkPersonId = coldPersonId;
      log('🔗 Cold start marriage deep link: $coldPersonId');
    } else if (coldAdvisorId != null) {
      pendingDeepLinkAdvisorId = coldAdvisorId;
      log('🔗 Cold start advisor deep link: $coldAdvisorId');
    } else if (coldUserId != null) {
      pendingDeepLinkUserId = coldUserId;
      log('🔗 Cold start user deep link: $coldUserId');
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
        _openDeepLinkWithRetry(pendingType: _PendingType.marriage);
      } else if (coldAdvisorId != null) {
        _openDeepLinkWithRetry(pendingType: _PendingType.advisor);
      } else if (coldUserId != null) {
        _openDeepLinkWithRetry(pendingType: _PendingType.user);
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

  void _openDeepLinkWithRetry({
    required _PendingType pendingType,
    int retries = 15,
  }) {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      if (isMainLayoutReady) {
        switch (pendingType) {
          case _PendingType.marriage:
            final id = pendingDeepLinkPersonId;
            if (id != null) {
              pendingDeepLinkPersonId = null;
              log('🔗 Opening marriage deep link: $id');
              DeepLinkService.handleMarriageProfileLink(
                context: context,
                personId: id,
              );
            }
          case _PendingType.advisor:
            final id = pendingDeepLinkAdvisorId;
            if (id != null) {
              pendingDeepLinkAdvisorId = null;
              log('🔗 Opening advisor deep link: $id');
              DeepLinkService.handleAdvisorProfileLink(
                context: context,
                advisorId: id,
              );
            }
          case _PendingType.user:
            final id = pendingDeepLinkUserId;
            if (id != null) {
              pendingDeepLinkUserId = null;
              log('🔗 Opening user deep link: $id');
              DeepLinkService.handleUserProfileLink(
                context: context,
                userId: id,
              );
            }
        }
      } else if (retries > 0) {
        log('🔗 Layout not ready yet, retrying... ($retries left)');
        _openDeepLinkWithRetry(pendingType: pendingType, retries: retries - 1);
      } else {
        log('🔗 Max retries reached, deep link lost');
      }
    });
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

enum _PendingType { marriage, advisor, user }
