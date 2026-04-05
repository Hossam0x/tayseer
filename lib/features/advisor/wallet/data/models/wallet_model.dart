class WalletModel {
  final String id;
  final String advisorId;
  final num balance;
  final String currency;
  final int points;

  const WalletModel({
    required this.id,
    required this.advisorId,
    required this.balance,
    required this.currency,
    this.points = 0,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] ?? '',
      advisorId: json['advisorId'] ?? '',
      balance: json['balance'] ?? 0,
      currency: json['currency'] ?? 'USD',
      points: (json['points'] as num?)?.toInt() ?? 0,
    );
  }

  WalletModel copyWith({num? balance, int? points}) {
    return WalletModel(
      id: id,
      advisorId: advisorId,
      balance: balance ?? this.balance,
      currency: currency,
      points: points ?? this.points,
    );
  }
}
