// ============================================
// 📌 OFFERING ITEM MODEL
// ============================================
class OfferingItemModel {
  final String? id;
  final String name;
  final double price;
  final String currency;
  final String duration; // '45' or '90'
  final String type; // 'session' or 'package'
  final String? country;
  final int? numberOfSessions; // only for packages

  const OfferingItemModel({
    this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.duration,
    required this.type,
    this.country,
    this.numberOfSessions,
  });

  factory OfferingItemModel.fromJson(Map<String, dynamic> json) {
    return OfferingItemModel(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'SAR',
      duration: json['duration']?.toString() ?? '45',
      type: json['type']?.toString() ?? 'session',
      country: json['country']?.toString(),
      numberOfSessions: json['numberOfSessions'] != null
          ? int.tryParse(json['numberOfSessions'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'price': price,
      'currency': currency,
      'duration': duration,
      'type': type,
    };
    if (type == 'package' && numberOfSessions != null) {
      map['numberOfSessions'] = numberOfSessions;
    }
    return map;
  }
}

// ============================================
// 📌 COUNTRY OFFERINGS MODEL (for local state)
// ============================================
class CountryOfferingsModel {
  final String countryKey; // e.g. 'country_saudi'
  final String flagEmoji;
  final List<OfferingItemModel> offerings;

  const CountryOfferingsModel({
    required this.countryKey,
    required this.flagEmoji,
    required this.offerings,
  });

  CountryOfferingsModel copyWith({
    String? countryKey,
    String? flagEmoji,
    List<OfferingItemModel>? offerings,
  }) {
    return CountryOfferingsModel(
      countryKey: countryKey ?? this.countryKey,
      flagEmoji: flagEmoji ?? this.flagEmoji,
      offerings: offerings ?? this.offerings,
    );
  }
}

// ============================================
// 📌 OFFERINGS RESPONSE MODEL
// ============================================
class OfferingsResponse {
  final bool success;
  final String message;
  final Map<String, List<OfferingItemModel>> data;
  final String subscriptionType;
  final double sessionsAppInterestPercentage;

  const OfferingsResponse({
    required this.success,
    required this.message,
    required this.data,
    this.subscriptionType = 'free',
    this.sessionsAppInterestPercentage = 25.0,
  });

  factory OfferingsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, List<OfferingItemModel>> data = {};

    // الـ data قد تكون object يحتوي على offerings + metadata
    dynamic rawData = json['data'];
    List? offeringsList;

    if (rawData is Map) {
      // الشكل الجديد: {offerings: [], subscriptionType: "free", sessionsAppInterestPercentage: 30}
      final rawOfferings = rawData['offerings'];
      if (rawOfferings is List) {
        offeringsList = rawOfferings;
      } else {
        // Legacy grouped format
        rawData.forEach((key, value) {
          if (key != 'subscriptionType' &&
              key != 'sessionsAppInterestPercentage' &&
              value is List) {
            data[key.toString()] = value
                .map(
                  (e) => OfferingItemModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
          }
        });
      }
    } else if (rawData is List) {
      offeringsList = rawData;
    }

    if (offeringsList != null) {
      for (final e in offeringsList) {
        final item = OfferingItemModel.fromJson(e as Map<String, dynamic>);
        final key = item.country ?? 'unknown';
        data.putIfAbsent(key, () => []).add(item);
      }
    }

    final dataMap = rawData is Map<dynamic, dynamic>
        ? rawData
        : <String, dynamic>{};

    return OfferingsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: data,
      subscriptionType: dataMap['subscriptionType']?.toString() ?? 'free',
      sessionsAppInterestPercentage:
          (dataMap['sessionsAppInterestPercentage'] as num?)?.toDouble() ??
          25.0,
    );
  }
}
