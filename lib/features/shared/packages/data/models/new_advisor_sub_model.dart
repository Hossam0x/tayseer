class NewAdvisorSubModel {
  final String id;
  final String appleProductId;
  final String subscriptionType; // "gold" | "ultra"
  final String subscriptionDurationType; // "monthly" | "weekly"
  final bool isCurrentSub;
  final String? subscriptionExpiresAt;
  final int numberOfSessions; // -1 = unlimited
  final int sessionsAppInterestPercentage;
  final int numberOfChatRooms; // -1 = unlimited
  final int numberOfMonthlyReinforcements;
  final int numberOfMonthlyEvents;
  final int eventsAppInterestPercentage;
  final num? price;
  final String? currency;

  NewAdvisorSubModel({
    required this.id,
    required this.appleProductId,
    required this.subscriptionType,
    required this.subscriptionDurationType,
    required this.isCurrentSub,
    this.subscriptionExpiresAt,
    required this.numberOfSessions,
    required this.sessionsAppInterestPercentage,
    required this.numberOfChatRooms,
    required this.numberOfMonthlyReinforcements,
    required this.numberOfMonthlyEvents,
    required this.eventsAppInterestPercentage,
    this.price,
    this.currency,
  });

  factory NewAdvisorSubModel.fromJson(Map<String, dynamic> json) {
    return NewAdvisorSubModel(
      id: json['id'] ?? '',
      appleProductId: json['appleProductId'] ?? '',
      subscriptionType: (json['subscriptionType'] ?? '')
          .toString()
          .toLowerCase(),
      subscriptionDurationType: (json['subscriptionDurationType'] ?? '')
          .toString()
          .toLowerCase(),
      isCurrentSub: json['isCurrentSub'] ?? false,
      subscriptionExpiresAt: json['subscriptionExpiresAt'],
      numberOfSessions: json['numberOfSessions'] ?? 0,
      sessionsAppInterestPercentage: json['sessionsAppInterestPercentage'] ?? 0,
      numberOfChatRooms: json['numberOfChatRooms'] ?? 0,
      numberOfMonthlyReinforcements: json['numberOfMonthlyReinforcements'] ?? 0,
      numberOfMonthlyEvents: json['numberOfMonthlyEvents'] ?? 0,
      eventsAppInterestPercentage: json['eventsAppInterestPercentage'] ?? 0,
      price: json['price'],
      currency: json['currency'],
    );
  }

  /// gold = Pro في الـ UI, ultra = Elite في الـ UI
  bool get isGold => subscriptionType == 'gold';
  bool get isUltra => subscriptionType == 'ultra';
  bool get isMonthly => subscriptionDurationType == 'monthly';
  bool get isWeekly => subscriptionDurationType == 'weekly';
}
