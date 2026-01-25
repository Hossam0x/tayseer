// lib/features/user/my_space/presentation/manager/call_cubit/session_call_cancel_event_bus.dart

import 'dart:async';

class SessionCallCancelEventBus {
  SessionCallCancelEventBus._();
  static final _instance = SessionCallCancelEventBus._();
  static get instance => _instance;

  final _sessionCallCancelledController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onSessionCallCancelled =>
      _sessionCallCancelledController.stream;

  void notifySessionCallCancelled({
    required String sessionId,
    required String reason,
    String? advisorName,
  }) {
    _sessionCallCancelledController.add({
      'sessionId': sessionId,
      'reason': reason,
      'advisorName': advisorName,
    });
  }

  void dispose() {
    _sessionCallCancelledController.close();
  }
}
