import 'dart:async';

import 'package:tayseer/features/advisor/session/data/models/advisor_session_response.dart';

class AcceptOrDeclneSessionEventBus {
  AcceptOrDeclneSessionEventBus._();
  static final AcceptOrDeclneSessionEventBus _instance =
      AcceptOrDeclneSessionEventBus._();
  factory AcceptOrDeclneSessionEventBus() => _instance;
  static AcceptOrDeclneSessionEventBus get instance => _instance;
  final sessionrescheduledStreamController =
      StreamController<AdvisorSession>.broadcast();

  Stream<AdvisorSession> get onacceptSession =>
      sessionrescheduledStreamController.stream;

  void notifyacceptSession(AdvisorSession acceptSessionData) {
    sessionrescheduledStreamController.add(acceptSessionData);
  }
}
