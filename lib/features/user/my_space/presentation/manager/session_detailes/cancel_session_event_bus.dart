import 'dart:async';

class SessionEventService {
  SessionEventService._();
  static final SessionEventService _instance = SessionEventService._();
  static SessionEventService get instance => _instance;

  final _sessionCancelledController = StreamController<String>.broadcast();

  Stream<String> get onSessionCancelled => _sessionCancelledController.stream;

  void notifySessionCancelled(String sessionId) {
    _sessionCancelledController.add(sessionId);
  }

  void dispose() {
    _sessionCancelledController.close();
  }
}
