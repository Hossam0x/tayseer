import 'dart:async';

class MarriageEventBus {
  MarriageEventBus._();
  static final MarriageEventBus instance = MarriageEventBus._();

  final _filterController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onFilterApplied => _filterController.stream;

  void applyFilter(Map<String, dynamic> filters) {
    _filterController.add(filters);
  }

  void dispose() {
    _filterController.close();
  }
}
