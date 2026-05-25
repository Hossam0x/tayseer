import 'package:flutter/widgets.dart';

/// Global navigator key shared across the app.
/// Defined here (not in main.dart) to avoid circular imports between
/// main.dart and get_it.dart.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
