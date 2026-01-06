import '../../../my_import.dart';

/// Global RouteObserver for video pause/resume on route changes
final RouteObserver<ModalRoute<void>> videoRouteObserver =
    RouteObserver<ModalRoute<void>>();

class DrawerRouteObserver extends NavigatorObserver {
  static String? currentRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    currentRoute = route.settings.name;
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    currentRoute = newRoute?.settings.name;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRoute = previousRoute?.settings.name;
  }
}
