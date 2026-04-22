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

  const OfferingItemModel({
    this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.duration,
    required this.type,
    this.country,
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
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'currency': currency,
    'duration': duration,
    'type': type,
  };
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

  const OfferingsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OfferingsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, List<OfferingItemModel>> data = {};
    final rawData = json['data'];

    if (rawData is List) {
      // Flat array — group by country field
      for (final e in rawData) {
        final item = OfferingItemModel.fromJson(e as Map<String, dynamic>);
        final key = item.country ?? 'unknown';
        data.putIfAbsent(key, () => []).add(item);
      }
    } else if (rawData is Map) {
      // Legacy grouped format
      rawData.forEach((key, value) {
        if (value is List) {
          data[key.toString()] = value
              .map((e) => OfferingItemModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      });
    }

    return OfferingsResponse(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString() ?? '',
      data: data,
    );
  }
}
