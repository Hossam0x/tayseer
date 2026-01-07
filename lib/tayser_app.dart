import 'package:tayseer/core/appLocalizations/appLocalizations.dart';
import 'package:tayseer/core/utils/router/route_observers.dart';
import 'package:tayseer/features/shared/the_list/view_model/language_cubit.dart';
import 'package:tayseer/my_import.dart';

class TayseerApp extends StatelessWidget {
  const TayseerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (context) => LanguageCubit(),
          child: BlocBuilder<LanguageCubit, Locale>(
            builder: (context, state) {
              return MaterialApp(
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
                  AppLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                title: kAppNameAr,
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
                navigatorObservers: [DrawerRouteObserver(), videoRouteObserver],
                onGenerateRoute: AppRouter.onGenerateRoute,
                initialRoute: AppRouter.kSplashView,
              );
            },
          ),
        );
      },
    );
  }
}
