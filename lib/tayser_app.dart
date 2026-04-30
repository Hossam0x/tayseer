import 'package:country_picker/country_picker.dart';
import 'package:tayseer/core/services/audio_service.dart';
import 'package:tayseer/core/services/connectivity_cubit.dart';
import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/core/video/feed_video_preloader.dart';
import 'package:tayseer/features/shared/splash_screen&&on_boarding/view/splash_screen.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/main.dart';
import 'package:tayseer/my_import.dart';

/// يعمل restart كامل للتطبيق من الـ root — نفس تأثير Hot Restart
class AppRestarter extends StatefulWidget {
  const AppRestarter({super.key, required this.child});

  final Widget child;

  /// استدعي هذه الدالة لإعادة تشغيل التطبيق بالكامل
  static Future<void> restart(BuildContext context) async {
    final state = context.findAncestorStateOfType<_AppRestarterState>();
    await state?.restartApp();
  }

  @override
  State<AppRestarter> createState() => _AppRestarterState();
}

class _AppRestarterState extends State<AppRestarter> {
  Key _key = UniqueKey();

  Future<void> restartApp() async {
    // إعادة تسجيل كل الـ singletons في getIt
    await getIt.reset();
    await setupGetIt();

    // إعادة بناء الـ widget tree كاملاً
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}

class TayseerApp extends StatefulWidget {
  const TayseerApp({super.key});

  @override
  State<TayseerApp> createState() => _TayseerAppState();
}

class _TayseerAppState extends State<TayseerApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Add app lifecycle observer for AudioService
    WidgetsBinding.instance.addObserver(this);
    // ✅ الـ Warm Start بيتهندل في main.dart عبر _listenToWarmStartLinks()
    // بيستخدم navigatorKey مباشرة — مش محتاج حاجة هنا
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        // ✅ بس نوقف الـ audio — الـ RealVideoPlayer بيتعامل مع الفيديو بنفسه
        AudioService.instance.onAppPaused();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        // ✅ التطبيق راح للخلفية فعلاً — نوقف كل حاجة
        AudioService.instance.onAppPaused();
        FeedVideoPreloader.instance.pauseAll();
        break;
      case AppLifecycleState.resumed:
        AudioService.instance.onAppResumed();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => LanguageCubit()),
            BlocProvider.value(value: getIt<ConnectivityCubit>()),
          ],
          child: ColoredBox(
            color: AppColors.kScaffoldColor,
            child: BlocBuilder<LanguageCubit, Locale>(
              builder: (context, state) {
                final cubit = context.read<LanguageCubit>();
                final pendingRoute = cubit.consumePendingWidget();
                return MaterialApp(
                  navigatorKey: navigatorKey,
                  key: ValueKey(state.languageCode),
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: const TextScaler.linear(1.0)),
                      child: child!,
                    );
                  },
                  locale: state,
                  supportedLocales: const [Locale('ar'), Locale('en')],
                  localizationsDelegates: [
                    CountryLocalizations.delegate,
                    AppLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                  ],
                  title: isArabic ? kAppNameAr : kAppNameEn,
                  debugShowCheckedModeBanner: false,
                  useInheritedMediaQuery: true,
                  theme: ThemeData(
                    scaffoldBackgroundColor: AppColors.kScaffoldColor,
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: AppColors.kprimaryColor,
                    ),
                    useMaterial3: true,
                    fontFamily: kAppFont,
                  ),
                  navigatorObservers: [
                    DrawerRouteObserver(),
                    videoRouteObserver,
                  ],
                  onGenerateRoute: AppRouter.onGenerateRoute,
                  home: pendingRoute ?? const SplashScreen(),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
