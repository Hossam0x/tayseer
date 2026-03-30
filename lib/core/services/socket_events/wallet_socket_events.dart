/// Base class for wallet socket events
abstract class WalletSocketEvent {
  const WalletSocketEvent();
}

/// Event: advisorPointsUpdate — backend sends updated points value
class AdvisorPointsUpdateEvent extends WalletSocketEvent {
  final int points;
  const AdvisorPointsUpdateEvent(this.points);

  factory AdvisorPointsUpdateEvent.fromJson(Map<String, dynamic> json) {
    return AdvisorPointsUpdateEvent((json['points'] as num?)?.toInt() ?? 0);
  }
}
