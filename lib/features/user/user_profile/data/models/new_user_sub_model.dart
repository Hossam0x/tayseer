import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';

class NewUserSubModel {
  final String id;
  final String appleProductId;
  final String subscriptionType; // "gold" | "ultra"
  final String subscriptionDurationType; // "monthly" | "weekly" | "threeMonths"
  final bool isCurrentSub;
  final String? subscriptionExpiresAt;
  final int numberOfChatRooms;
  final int numberOfChatRoomMins;
  final int numberOfLikes;
  final int numberOfDailyGreetings;
  final int numberOfFreeWeeklyReinforcements;
  final int numberOfFreeMatchingRenables;
  final num? price;
  final String? currency;

  NewUserSubModel({
    required this.id,
    required this.appleProductId,
    required this.subscriptionType,
    required this.subscriptionDurationType,
    required this.isCurrentSub,
    this.subscriptionExpiresAt,
    required this.numberOfChatRooms,
    required this.numberOfChatRoomMins,
    required this.numberOfLikes,
    required this.numberOfDailyGreetings,
    required this.numberOfFreeWeeklyReinforcements,
    required this.numberOfFreeMatchingRenables,
    this.price,
    this.currency,
  });

  factory NewUserSubModel.fromJson(Map<String, dynamic> json) {
    return NewUserSubModel(
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
      numberOfChatRooms: json['numberOfChatRooms'] ?? 0,
      numberOfChatRoomMins: json['numberOfChatRoomMins'] ?? 0,
      numberOfLikes: json['numberOfLikes'] ?? 0,
      numberOfDailyGreetings: json['numberOfDailyGreetings'] ?? 0,
      numberOfFreeWeeklyReinforcements:
          json['numberOfFreeWeeklyReinforcements'] ?? 0,
      numberOfFreeMatchingRenables: json['numberOfFreeMatchingRenables'] ?? 0,
      price: json['price'],
      currency: json['currency'],
    );
  }

  bool get isGold => subscriptionType == 'gold';
  bool get isUltra => subscriptionType == 'ultra';
  bool get isMonthly => subscriptionDurationType == 'monthly';
  bool get isWeekly => subscriptionDurationType == 'weekly';
  bool get isThreeMonths => subscriptionDurationType == 'threemonths';

  /// Maps to NewAdvisorSubModel so shared UI (GetPackageDisplayData) can reuse it.
  NewAdvisorSubModel toAdvisorSubModel() {
    return NewAdvisorSubModel(
      id: id,
      appleProductId: appleProductId,
      subscriptionType: subscriptionType,
      subscriptionDurationType: subscriptionDurationType,
      isCurrentSub: isCurrentSub,
      subscriptionExpiresAt: subscriptionExpiresAt,
      numberOfSessions: 0,
      sessionsAppInterestPercentage: 0,
      numberOfChatRooms: numberOfChatRooms,
      numberOfMonthlyReinforcements: numberOfFreeWeeklyReinforcements,
      numberOfMonthlyEvents: 0,
      eventsAppInterestPercentage: 0,
      price: price,
      currency: currency,
    );
  }
}
