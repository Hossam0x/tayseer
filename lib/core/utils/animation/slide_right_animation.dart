import 'package:flutter/material.dart';

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings? routeSettings;

  SlideRightRoute({required this.page, this.routeSettings})
    : super(
        settings: routeSettings,
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => page,
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              const begin = Offset(-1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
        transitionDuration: const Duration(milliseconds: 400),
      );
}

class SlideLeftRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings? routeSettings;

  SlideLeftRoute({required this.page, this.routeSettings})
    : super(
        settings: routeSettings,
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => page,
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOutCubic;

              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
        transitionDuration: const Duration(milliseconds: 400),
      );
}

class FadeScaleRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings? routeSettings;

  FadeScaleRoute({required this.page, this.routeSettings})
    : super(
        settings: routeSettings,
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => page,
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutBack,
                    ),
                  ),
                  child: child,
                ),
              );
            },
        transitionDuration: const Duration(milliseconds: 500),
      );
}

class CustomRotationRoute extends PageRouteBuilder {
  final Widget page;
  final RouteSettings? routeSettings;

  CustomRotationRoute({required this.page, this.routeSettings})
    : super(
        settings: routeSettings,
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => page,
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              return RotationTransition(
                turns: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubic,
                  ),
                ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.fastOutSlowIn,
                    ),
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                ),
              );
            },
        transitionDuration: const Duration(milliseconds: 600),
      );
}
