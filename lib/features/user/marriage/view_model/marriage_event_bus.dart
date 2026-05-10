import 'dart:async';

class MarriageEventBus {
  MarriageEventBus._();
  static final MarriageEventBus instance = MarriageEventBus._();

  // ✅ فلتر الزواج
  final _filterController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onFilterApplied => _filterController.stream;

  void applyFilter(Map<String, dynamic> filters) {
    _filterController.add(filters);
  }

  // ✅ التحويل لتاب الزواج بعد تطبيق الفلتر
  final _switchToMarriageTabController = StreamController<void>.broadcast();
  Stream<void> get onSwitchToMarriageTab =>
      _switchToMarriageTabController.stream;

  void switchToMarriageTab() {
    _switchToMarriageTabController.add(null);
  }

  // ✅ refresh الـ regards balance بعد شراء باقة تهاني
  final _regardsRefreshController = StreamController<void>.broadcast();
  Stream<void> get onRegardsRefreshed => _regardsRefreshController.stream;

  void refreshRegards() {
    _regardsRefreshController.add(null);
  }

  void dispose() {
    _filterController.close();
    _switchToMarriageTabController.close();
    _regardsRefreshController.close();
  }
}
