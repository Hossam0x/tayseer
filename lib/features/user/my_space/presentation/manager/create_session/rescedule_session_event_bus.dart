import 'dart:async';

import 'package:tayseer/features/user/my_space/data/model/sessiondetailes/session_detailes_model.dart';

class ResceduleSessionEventBus {
  ResceduleSessionEventBus._privateConstructor();
  static final ResceduleSessionEventBus _instance =
      ResceduleSessionEventBus._privateConstructor();
  static ResceduleSessionEventBus get instance => _instance;
  final sessionrescheduledStreamController =
      StreamController<SessionDetailsDataResponse>.broadcast();

  Stream<SessionDetailsDataResponse> get onSessionRescheduled =>
      sessionrescheduledStreamController.stream;

  void notifySessionRescheduled(SessionDetailsDataResponse sessionData) {
    sessionrescheduledStreamController.add(sessionData);
  }

  void dispose() {
    sessionrescheduledStreamController.close();
  }
}
