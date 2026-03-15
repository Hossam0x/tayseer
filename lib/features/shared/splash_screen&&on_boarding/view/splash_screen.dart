// import 'dart:developer';

// import 'package:tayseer/core/utils/helper/socket_helper.dart';

import 'dart:developer';

import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';

import '../../../../my_import.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // double _opacity = 0.0;
  // late AnimationController _controller;

  @override
  void initState() {
    _initializeSocket();
    super.initState();
    // _controller = AnimationController(
    //   duration: const Duration(seconds: 2),
    //   vsync: this,
    // )..repeat();
    // Future.delayed(const Duration(seconds: 1), () {
    //   // if (mounted) {
    //   //   setState(() {
    //   //     _opacity = 1.0;
    //   //   });
    //   // }
    // });
    _navigateBasedOnToken();
  }

  Future<void> _initializeSocket() async {
    try {
      // التحقق من نوع المستخدم قبل الاتصال
      final userType = CachNetwork.getStringData(key: kUserType);
      final token = CachNetwork.getStringData(key: ktoken);

      // لا نحاول الاتصال إذا كان guest أو لا يوجد token
      if (userType == UserTypeEnum.guest.name || token.isEmpty) {
        log('⏭️ Skipping socket connection for guest or no token');
        return;
      }

      final socketHelper = getIt<tayseerSocketHelper>();
      final connected = await socketHelper.connect();

      if (connected) {
        log('✅ Socket connected successfully');
      } else {
        log('⚠️ Socket connection failed, but continuing...');
      }
    } catch (e) {
      log('❌ Socket initialization error: $e');
      // لا نوقف التطبيق إذا فشل الاتصال بالـ socket
    }
  }

  Future<void> _navigateBasedOnToken() async {
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;

    String? token = CachNetwork.getStringData(key: ktoken);
    String? userType = CachNetwork.getStringData(key: kUserType);

    log(
      '🔍 Navigation check - Token: ${token.isNotEmpty}, UserType: $userType, selectedUserType: $selectedUserType',
    );

    if (!mounted) return;

    if (token.isNotEmpty) {
      // المستخدم لديه token
      if (selectedUserType == UserTypeEnum.asConsultant) {
        if (kCurrentUserData?.compeletedData == true) {
          context.pushReplacementNamed(AppRouter.kAdvisorLayoutView);
        } else {
          context.pushReplacementNamed(AppRouter.kRegisrationView);
        }
      } else if (selectedUserType == UserTypeEnum.user) {
        if (kCurrentUserData?.isNew == false) {
          context.pushReplacementNamed(AppRouter.kUserLayoutView);
        } else {
          context.pushReplacementNamed(AppRouter.kRegisrationView);
        }
      } else if (selectedUserType == UserTypeEnum.guest) {
        // Guest user - go directly to user layout
        log('✅ Guest user detected, navigating to user layout');
        context.pushReplacementNamed(AppRouter.kUserLayoutView);
      } else {
        // Unknown user type, go to registration
        log('⚠️ Unknown user type, navigating to registration');
        context.pushReplacementNamed(AppRouter.kRegisrationView);
      }
    } else {
      // لا يوجد token، اذهب للتسجيل
      log('⚠️ No token found, navigating to registration');
      context.pushReplacementNamed(AppRouter.kRegisrationView);
    }
  }
  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

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
