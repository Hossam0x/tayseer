import 'package:tayseer/features/shared/packages/data/models/new_advisor_sub_model.dart';

class NewUserSubModel {
  final String id;
  final String appleProductId;
  final String androidProductId; // Google Play product ID
  final String subscriptionType; // "gold" | "ultra"
  final String subscriptionDurationType; // "monthly" | "weekly" | "threeMonths"
  final bool isCurrentSub;
  final bool isCancelled;
  final String? subscriptionExpiresAt;
  final int numberOfChatRooms;
  final int numberOfChatRoomMins;
  final int numberOfLikes;
  final int numberOfDailyGreetings;
  final int numberOfFreeWeeklyReinforcements;
  final int numberOfFreeMatchingRenables;
  final num? price;
  final num? pricePerMonth;
  final String? currency;
  final int? savePercentage;

  NewUserSubModel({
    required this.id,
    required this.appleProductId,
    this.androidProductId = '',
    required this.subscriptionType,
    required this.subscriptionDurationType,
    required this.isCurrentSub,
    this.isCancelled = false,
    this.subscriptionExpiresAt,
    required this.numberOfChatRooms,
    required this.numberOfChatRoomMins,
    required this.numberOfLikes,
    required this.numberOfDailyGreetings,
    required this.numberOfFreeWeeklyReinforcements,
    required this.numberOfFreeMatchingRenables,
    this.price,
    this.pricePerMonth,
    this.currency,
    this.savePercentage,
  });

  factory NewUserSubModel.fromJson(Map<String, dynamic> json) {
    return NewUserSubModel(
      id: json['id'] ?? '',
      appleProductId: json['appleProductId'] ?? '',
      androidProductId: json['googleProductId'] as String? ?? json['androidProductId'] as String? ?? '',
      subscriptionType: (json['subscriptionType'] ?? '')
          .toString()
          .toLowerCase(),
      subscriptionDurationType: (json['subscriptionDurationType'] ?? '')
          .toString()
          .toLowerCase(),
      isCurrentSub: json['isCurrentSub'] ?? false,
      isCancelled: json['isCancelled'] ?? false,
      subscriptionExpiresAt: json['subscriptionExpiresAt'],
      numberOfChatRooms: json['numberOfChatRooms'] ?? 0,
      numberOfChatRoomMins: json['numberOfChatRoomMins'] ?? 0,
      numberOfLikes: json['numberOfLikes'] ?? 0,
      numberOfDailyGreetings: json['numberOfDailyGreetings'] ?? 0,
      numberOfFreeWeeklyReinforcements:
          json['numberOfFreeWeeklyReinforcements'] ?? 0,
      numberOfFreeMatchingRenables: json['numberOfFreeMatchingRenables'] ?? 0,
      price: json['price'],
      pricePerMonth: json['pricePerMonth'] != null
          ? num.tryParse(json['pricePerMonth'].toString())
          : null,
      currency: json['currency'],
      savePercentage: json['savePercentage'],
    );
  }

  bool get isGold => subscriptionType == 'gold';
  bool get isUltra => subscriptionType == 'ultra';
  bool get isMonthly => subscriptionDurationType == 'monthly';
  bool get isWeekly => subscriptionDurationType == 'weekly';
  bool get isThreeMonths => subscriptionDurationType == 'threemonths';

  /// الاشتراك نشط في Apple (لم يُلغَ auto-renew بعد)
  bool get isActiveInApple => isCurrentSub && !isCancelled;

  /// الاشتراك ملغي auto-renew لكن لسه شغال لحد تاريخ الانتهاء
  bool get isCancelledButActive {
    if (!isCancelled || subscriptionExpiresAt == null) return false;
    final expiry = DateTime.tryParse(subscriptionExpiresAt!);
    if (expiry == null) return false;
    return DateTime.now().isBefore(expiry);
  }

  /// Maps to NewAdvisorSubModel so shared UI (GetPackageDisplayData) can reuse it.
  NewAdvisorSubModel toAdvisorSubModel() {
    return NewAdvisorSubModel(
      id: id,
      appleProductId: appleProductId,
      androidProductId: androidProductId,
      subscriptionType: subscriptionType,
      subscriptionDurationType: subscriptionDurationType,
      isCurrentSub: isCurrentSub,
      isCancelled: isCancelled,
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
