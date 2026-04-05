import 'dart:async';

/// Fired whenever the advisor's subscription changes (new sub, cancel, upgrade).
/// Any cubit/widget that depends on subscription state should listen and refresh.
class SubscriptionChangedEvent {
  /// The new subscription type: 'free', 'gold', 'ultra'
  final String subscriptionType;
  const SubscriptionChangedEvent({required this.subscriptionType});
}

class SubscriptionEventBus {
  SubscriptionEventBus._();
  static final SubscriptionEventBus instance = SubscriptionEventBus._();

  final _controller = StreamController<SubscriptionChangedEvent>.broadcast();

  Stream<SubscriptionChangedEvent> get onSubscriptionChanged =>
      _controller.stream;

  void fire(SubscriptionChangedEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}
