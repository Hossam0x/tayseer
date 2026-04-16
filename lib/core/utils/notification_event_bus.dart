import 'dart:async';

/// Fired whenever a push notification arrives while the app is in foreground,
/// so any listener (e.g. HomeCubit) can refresh the notification count.
class PushNotificationReceivedEvent {
  const PushNotificationReceivedEvent();
}

class NotificationEventBus {
  NotificationEventBus._();
  static final NotificationEventBus instance = NotificationEventBus._();

  final _controller =
      StreamController<PushNotificationReceivedEvent>.broadcast();

  Stream<PushNotificationReceivedEvent> get onNotificationReceived =>
      _controller.stream;

  void fire() => _controller.add(const PushNotificationReceivedEvent());

  void dispose() => _controller.close();
}
