import 'dart:developer';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:tayseer/core/enum/user_type.dart';
import 'package:tayseer/core/notifications/notificationHelper.dart';
import 'package:tayseer/core/utils/otp_resumption_service.dart';
import 'package:tayseer/core/utils/otp_screen_guard.dart';
import 'package:tayseer/core/services/appsflyer_events/appsflyer_events.dart';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/services/chat_socket_service.dart';
import 'package:tayseer/core/services/deep_link_service.dart';
import 'package:tayseer/core/utils/helper/socket_helper.dart';
import 'package:tayseer/features/shared/force_update/data/repo/force_update_repo.dart';
import 'package:tayseer/features/shared/force_update/presentation/views/force_update_screen.dart';
import 'package:tayseer/features/shared/home/view_model/home_cubit.dart';
import 'package:tayseer/features/advisor/stories/presentation/view_model/stories_cubit/stories_cubit.dart';
import 'package:tayseer/features/shared/rating/services/app_usage_tracker_service.dart';
import 'package:tayseer/main.dart';
import '../../../../my_import.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _badgeController;
  late Animation<double> _badgeFade;
  late Animation<Offset> _badgeSlide;
  late Animation<double> _badgeScale;

  @override
  void initState() {
    super.initState();

    // Badge animation: fade + slide up + scale — total 900ms
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Fade: starts immediately, eases out quickly in first 60% of duration
    _badgeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
      ),
    );

    // Slide: slight upward travel with elastic bounce at the end
    _badgeSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _badgeController,
            curve: const Interval(0.0, 1.0, curve: Curves.elasticOut),
          ),
        );

    // Scale: grows from 80% → 100% with a gentle overshoot
    _badgeScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // تشغيل الأنيميشن في نص الـ GIF (2400ms)
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) _badgeController.forward();
    });

    _initializeSocket();
    _initializeHomeData();
    _navigateBasedOnToken();
    _playSoundAfterHalfAnimation();
    _trackFirstOpen();
    // ✅ طلب إذن App Tracking Transparency على iOS
    if (Platform.isIOS) {
      _requestTrackingPermission();
    }
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  /// Sends [first_open] to AppsFlyer once — on the very first app launch after install.
  /// Uses a SharedPreferences flag so it never fires again on subsequent opens.
  Future<void> _trackFirstOpen() async {
    const flagKey = 'af_first_open_tracked';
    final alreadyTracked = CachNetwork.getBoolData(key: flagKey) ?? false;
    if (alreadyTracked) return;

    await AppsFlyerEvents.firstOpen();
    await CachNetwork.setBool(key: flagKey, value: true);
    log('✅ AppsFlyer: first_open event sent');
  }

  /// ✅ طلب إذن App Tracking Transparency (iOS 14+)
  /// Apple تشترط هذا الإذن قبل أي tracking للمستخدم
  Future<void> _requestTrackingPermission() async {
    try {
      // انتظر شوية عشان الـ UI يكون جاهز
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;

      final status = await AppTrackingTransparency.trackingAuthorizationStatus;

      // لو لسه مش اتسأل، اسأل المستخدم
      if (status == TrackingStatus.notDetermined) {
        // انتظر الـ dialog يظهر بعد ما الـ splash animation تخلص
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        await AppTrackingTransparency.requestTrackingAuthorization();
      }

      log(
        '📊 ATT Status: ${await AppTrackingTransparency.trackingAuthorizationStatus}',
      );
    } catch (e) {
      log('⚠️ ATT request error: $e');
    }
  }

  /// تحميل بيانات الهوم والـ Stories مسبقاً في الـ Splash
  Future<void> _initializeHomeData() async {
    try {
      final token = CachNetwork.getStringData(key: ktoken);
      final userType = CachNetwork.getStringData(key: kUserType);

      // ✅ فقط لو اليوزر مسجل دخول وليس guest
      if (token.isEmpty || userType == UserTypeEnum.guest.name) {
        log('⏭️ Splash: skipping home init — not logged in');
        return;
      }

      final homeCubit = getIt<HomeCubit>();
      final storiesCubit = getIt<StoriesCubit>();

      // تحميل بيانات الهوم والـ Stories بالتوازي
      await Future.wait([
        homeCubit.initHome(),
        storiesCubit.fetchStories(context: context),
        if (selectedUserType == UserTypeEnum.asConsultant)
          storiesCubit.fetchMyStories(),
      ]);

      // ✅ ضع الـ flag بعد نجاح التحميل
      homeCubit.isInitializedFromSplash = true;
      log('✅ Home data and stories initialized in splash');
    } catch (e) {
      log('⚠️ Failed to initialize home data in splash: $e');
    }
  }

  Future<void> _playSoundAfterHalfAnimation() async {
    // نص الـ animation = 4800 / 2 = 2400ms
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    try {
      await AudioService.instance.playSound(
        AudioService.splashSound,
        forcePlay: true,
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

      // ✅ لو الـ socket already connected (من _connectSocketForNewUser بعد login)
      // تأكد بس إن الـ ChatSocketService initialized وارجع
      if (socketHelper.isConnected) {
        chatSocketService.init();
        return;
      }

      // ✅ استخدم resetAndConnect بدل connect مباشرة
      // عشان يضمن إن _authorizedToken بيتعيَّن صح
      final connected = await socketHelper.resetAndConnect(token: token);

      if (connected) {
        chatSocketService.init();
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

    // ── Soft-resume guard (in-memory) ───────────────────────────────────────
    // The OS kept the Dart isolate alive. The OTP screen is still mounted.
    // Nothing to do — the user will see exactly the screen they left.
    if (OtpScreenGuard.isActive) {
      log('🛡️ Splash: OTP screen active in memory — skipping navigation');
      return;
    }
    // ────────────────────────────────────────────────────────────────────────

    // ── Process-death resume (SharedPreferences) ─────────────────────────────
    // The OS killed the Dart isolate while the app was backgrounded.
    // The token is still valid, but all in-memory state is gone.
    // Restore the user to the correct OTP screen.
    final otpCtx = await OtpResumptionService.instance.load();
    if (otpCtx != null) {
      // Only restore if the user still has a valid token — an expired session
      // will be caught by the API on the OTP screen itself (toast + can resend).
      final token = CachNetwork.getStringData(key: ktoken);
      if (token.isNotEmpty) {
        log(
          '🛡️ Splash: restoring OTP screen after process death '
          '(type=${otpCtx.screenType.name})',
        );
        // Clear the record — it will be re-saved by the screen's initState.
        await OtpResumptionService.instance.clear();
        if (!mounted) return;
        _restoreOtpScreen(otpCtx);
        return;
      } else {
        // No token — session is gone. Clear the stale record and fall through
        // to the normal "no token → registration" path.
        log(
          '🛡️ Splash: OTP context found but no token — clearing and '
          'proceeding to registration',
        );
        await OtpResumptionService.instance.clear();
      }
    }
    // ────────────────────────────────────────────────────────────────────────

    // ── Force Update Check ──────────────────────────────────────────────────
    final forceUpdateRepo = getIt<ForceUpdateRepo>();
    final updateRequired = await forceUpdateRepo.isUpdateRequired();

    if (updateRequired) {
      if (!mounted) return;
      final storeUrl = await forceUpdateRepo.getStoreUrl();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ForceUpdateScreen(storeUrl: storeUrl),
        ),
      );
      return;
    }
    // ────────────────────────────────────────────────────────────────────────

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
      // Track launch for rating eligibility (only for authenticated users).
      AppUsageTrackerService.instance.onAppLaunch();

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

  /// Navigates to the appropriate OTP screen after a process-death resume.
  void _restoreOtpScreen(OtpResumptionContext ctx) {
    if (!mounted) return;
    switch (ctx.screenType) {
      case OtpScreenType.authOtp:
        // Registration/login email OTP — the AuthCubit is a LazySingleton,
        // so it still holds the phone/email in its controllers.
        context.pushReplacementNamed(AppRouter.kOtpView);

      case OtpScreenType.phoneOtp:
        // Phone OTP in the onboarding / questions flow.
        context.pushReplacementNamed(
          AppRouter.kOtpPhoneUserQuestion,
          arguments: {
            'isOnboarding': ctx.isOnboarding,
            'isAdvisorFlow': ctx.isAdvisorFlow,
          },
        );
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: FadeTransition(
                opacity: _badgeFade,
                child: SlideTransition(
                  position: _badgeSlide,
                  child: ScaleTransition(
                    scale: _badgeScale,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [AppImage(AssetsData.logoAthr, width: 80)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
