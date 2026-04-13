/// Prevents double navigation by throttling pushes within a short window.
class NavigationGuard {
  NavigationGuard._();

  static DateTime? _lastNavTime;
  static const _throttle = Duration(milliseconds: 600);

  static bool canNavigate() {
    final now = DateTime.now();
    if (_lastNavTime != null && now.difference(_lastNavTime!) < _throttle) {
      return false;
    }
    _lastNavTime = now;
    return true;
  }
}
