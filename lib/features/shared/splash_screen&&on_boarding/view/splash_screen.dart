import 'dart:developer';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/notifications/notificationHelper.dart';
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
    super.initState();
    _initializeSocket();
    _navigateBasedOnToken();
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

    final String? token = CachNetwork.getStringData(key: ktoken);
    final String? userType = CachNetwork.getStringData(key: kUserType);

    log(
      '🔍 Navigation check - Token: ${token?.isNotEmpty}, '
      'UserType: $userType, selectedUserType: $selectedUserType',
    );

    // ✅ نسحب الـ cold start URI ونمسحه فوراً
    final coldUri = pendingDeepLinkUri;
    pendingDeepLinkUri = null;

    if (!mounted) return;

    String? token = CachNetwork.getStringData(key: ktoken);
    if (mounted) {
      if (token.isNotEmpty) {
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
          
        }
      } else {
        navigatorKey.currentState?.pushReplacementNamed(
          AppRouter.kRegisrationView,
        );
      }

      // ✅ استخدام NotificationHelper بدل go()
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
      navigatorKey.currentState?.pushReplacementNamed(
        AppRouter.kRegisrationView,
      );
    }
  }
        Future.delayed(const Duration(milliseconds: 1000), () {
          consumePendingDeepLink();
        });
      }
    } else {
      // ─── مش مسجل ───
      log('⚠️ No token found, navigating to registration');

      // ✅ حفظ الـ cold start deep link لما يسجل دخول
      if (coldUri != null) {
        final personId = _extractPersonId(coldUri);
        if (personId != null) {
          pendingDeepLinkPersonId = personId;
          debugPrint('🔗 Cold start: saved for after login: $personId');
        }
      }

      if (!mounted) return;
      context.pushReplacementNamed(AppRouter.kRegisrationView);
    }
  }

  void _handleDeepLinkAfterLogin(Uri uri) {
    final personId = _extractPersonId(uri);
    if (personId == null) return;

    // ✅ delay أكبر عشان الـ destination screen يتبني خالص
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState?.pushNamed(
          AppRouter.kMarriageView,
          arguments: {'personId': personId},
        );
      });
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
