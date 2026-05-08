class MySubscriptionModel {
  final String subscriptionType; // free | gold | ultra
  final String
  subscriptionDurationType; // unlimited | weekly | monthly | threeMonths
  final String? subscriptionActivatedAt;
  final String? subscriptionExpiresAt;
  final String subscriptionStatus; // active | cancelled | expired
  final bool autoRenewal;

  const MySubscriptionModel({
    required this.subscriptionType,
    required this.subscriptionDurationType,
    this.subscriptionActivatedAt,
    this.subscriptionExpiresAt,
    required this.subscriptionStatus,
    this.autoRenewal = true,
  });

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    return MySubscriptionModel(
      subscriptionType: (json['subscriptionType'] ?? 'free')
          .toString()
          .toLowerCase(),
      subscriptionDurationType:
          (json['subscriptionDurationType'] ?? 'unlimited')
              .toString()
              .toLowerCase(),
      subscriptionActivatedAt: json['subscriptionActivatedAt'],
      subscriptionExpiresAt: json['subscriptionExpiresAt'],
      subscriptionStatus: (json['subscriptionStatus'] ?? 'active')
          .toString()
          .toLowerCase(),
      autoRenewal: json['autoRenewal'] as bool? ?? true,
    );
  }

  bool get isFree => subscriptionType == 'free';
  bool get isGold => subscriptionType == 'gold';
  bool get isUltra => subscriptionType == 'ultra';
  bool get isActive => subscriptionStatus == 'active';

  /// الاشتراك ملغي auto-renew — إما من الـ status أو من الـ autoRenewal flag
  bool get isCancelled => subscriptionStatus == 'cancelled' || !autoRenewal;

  bool get isExpired => subscriptionStatus == 'expired';
  bool get isUnlimited => subscriptionDurationType == 'unlimited';
}
