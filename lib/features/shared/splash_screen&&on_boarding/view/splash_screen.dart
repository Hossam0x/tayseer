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
      final socketHelper = getIt<tayseerSocketHelper>();

      final connected = await socketHelper.connect();

      if (connected) {
        log('✅ Socket connected successfully');
      }
    } catch (e) {
      log('❌ Socket initialization error: $e');
    }
  }

  Future<void> _navigateBasedOnToken() async {
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    String? token = CachNetwork.getStringData(key: 'token');
    if (mounted) {
      if (token.isNotEmpty) {
        selectedUserType == UserTypeEnum.asConsultant
            ? context.pushReplacementNamed(AppRouter.kRegisrationView)
            : context.pushReplacementNamed(AppRouter.kRegisrationView);
      } else {
        context.pushReplacementNamed(AppRouter.kRegisrationView);
      }
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
