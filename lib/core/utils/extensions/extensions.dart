import 'package:tayseer/core/appLocalizations/appLocalizations.dart';
import 'package:tayseer/my_import.dart';

extension MediaQueryExtensions on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  double get scale => MediaQuery.of(this).devicePixelRatio;
  double get textScale => MediaQuery.of(this).textScaleFactor;
  double get safeTop => MediaQuery.of(this).padding.top;
  double get safeBottom => MediaQuery.of(this).padding.bottom;
  double get safeLeft => MediaQuery.of(this).padding.left;
  double get safeRight => MediaQuery.of(this).padding.right;
  double get safeWidth => width - safeLeft - safeRight;
  double get safeHeight => height - safeTop - safeBottom;
  double get safeScale => scale * textScale;

  static const double _designHeight = 932;
  static const double _designWidth = 430;

  double responsiveWidth(double widgetWidth) {
    return width * (widgetWidth / _designWidth);
  }

  double responsiveHeight(double widgetHeight) {
    return height * (widgetHeight / _designHeight);
  }

  bool isMobile() => MediaQuery.sizeOf(this).width < 450;

  bool isTablet() =>
      MediaQuery.sizeOf(this).width >= 600 &&
      MediaQuery.sizeOf(this).width < 1200;

  bool isDesktop() => MediaQuery.sizeOf(this).width >= 1200;
}

extension LocalizationExtension on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)!.translate(key);
  }

  AppLocalizations get loc => AppLocalizations.of(this)!;
}

extension Navigation on BuildContext {
  /// Always use root navigator for named routes
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(
      this,
      rootNavigator: true, // THIS FIXES THE ISSUE
    ).pushNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName, {Object? arguments}) {
    return Navigator.of(
      this,
      rootNavigator: true,
    ).pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(
    String routeName, {
    Object? arguments,
    required RoutePredicate predicate,
  }) {
    return Navigator.of(
      this,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  void popUntil({required String routeName}) {
    final navigator = Navigator.of(this, rootNavigator: true);

    if (!navigator.canPop()) {
      debugPrint("⚠️ لا يمكن الرجوع، لا توجد صفحات في المكدس.");
      return;
    }

    navigator.popUntil((route) {
      return route.settings.name == routeName;
    });
  }

  void pop() {
    Navigator.of(this, rootNavigator: true).pop();
  }

  bool canPop() => Navigator.of(this, rootNavigator: true).canPop();
}
