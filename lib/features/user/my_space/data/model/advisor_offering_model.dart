// lib/features/user/my_space/data/model/advisor_offering_model.dart

class AdvisorOfferingResponseModel {
  final bool success;
  final String message;
  final List<AdvisorOfferingModel> data;

  AdvisorOfferingResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AdvisorOfferingResponseModel.fromJson(Map<String, dynamic> json) {
    return AdvisorOfferingResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => AdvisorOfferingModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AdvisorOfferingModel {
  final String id;
  final String name;
  final String type;
  final int price;
  final String currency;
  final int duration;
  final String country;
  final String advisorId;

  AdvisorOfferingModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.currency,
    required this.duration,
    required this.country,
    required this.advisorId,
  });

  factory AdvisorOfferingModel.fromJson(Map<String, dynamic> json) {
    return AdvisorOfferingModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'session',
      price: json['price'] ?? 0,
      currency: json['currency'] ?? '',
      duration: json['duration'] ?? 45,
      country: json['country'] ?? '',
      advisorId: json['advisorId']?.toString() ?? '',
    );
  }

  bool get isPackage => type == 'package';
  bool get isSession => type == 'session';

  String get typeAr {
    switch (type) {
      case 'session':
        return 'جلسة فردية';
      case 'package':
        return 'باقة جلسات';
      default:
        return type;
    }
  }

  String get typeEn {
    switch (type) {
      case 'session':
        return 'Individual Session';
      case 'package':
        return 'Package';
      default:
        return type;
    }
  }

  String get durationAr => '$duration دقيقة';
  String get durationEn => '$duration minutes';
  String get priceWithCurrency => '$price $currency';
}
