import 'dart:async';

import 'package:tayseer/features/user/my_space/data/model/session_start_model.dart';

class HomeEventBus {
  HomeEventBus._privateConstructor();
  static final HomeEventBus _instance = HomeEventBus._privateConstructor();
  static HomeEventBus get instance => _instance;

  final sessionstarteventController =
      StreamController<SessionStartModel>.broadcast();

  Stream<SessionStartModel> get onsessionstart =>
      sessionstarteventController.stream;

  void notifysessionstart(SessionStartModel sessionStartModel) {
    sessionstarteventController.add(sessionStartModel);
  }

  void dispose() {
    sessionstarteventController.close();
  }
}
