import 'package:flutter/material.dart';

class PackageFeatures {
  final int sessionNumber;
  final int chatsNumber;
  final int eventsNumber;
  final int promotionNumber;
  final String supportsType;
  final bool vipSupport;
  final bool verified;
  final bool visitors;

  PackageFeatures({
    required this.sessionNumber,
    required this.chatsNumber,
    required this.eventsNumber,
    required this.promotionNumber,
    required this.supportsType,
    required this.vipSupport,
    required this.verified,
    required this.visitors,
  });

  factory PackageFeatures.fromJson(Map<String, dynamic> json) {
    return PackageFeatures(
      sessionNumber: json['sessionNumber'] ?? 0,
      chatsNumber: json['chatsNumber'] ?? 0,
      eventsNumber: json['eventsNumber'] ?? 0,
      promotionNumber: json['PromotionNumber'] ?? 0,
      supportsType: json['supportsType'] ?? '',
      vipSupport: json['vipSupport'] ?? false,
      verified: json['Verified'] ?? false,
      visitors: json['visitors'] ?? false,
    );
  }
}

class AdvisorPackageModel {
  final String id;
  final String name;
  final String type;
  final num egPrice;
  final num sarPrice;
  final int duration;
  final PackageFeatures features;

  AdvisorPackageModel({
    required this.id,
    required this.name,
    required this.type,
    required this.egPrice,
    required this.sarPrice,
    required this.duration,
    required this.features,
  });

  factory AdvisorPackageModel.fromJson(Map<String, dynamic> json) {
    return AdvisorPackageModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: (json['type'] ?? '').toString().toLowerCase(),
      egPrice: json['egPrice'] ?? 0,
      sarPrice: json['sarPrice'] ?? 0,
      duration: json['duration'] ?? 0,
      features: PackageFeatures.fromJson(json['features'] ?? {}),
    );
  }
}

class PackageModel {
  final String id;
  final String packageTitle;
  final List<PackageFeatureModel> features;
  final String price;
  final String buttonText;
  final List<Color> backgroundGradient;
  final Color themeColor;
  final String? topIllustration;

  PackageModel({
    required this.id,
    required this.packageTitle,
    required this.features,
    required this.price,
    required this.buttonText,
    required this.backgroundGradient,
    required this.themeColor,
    this.topIllustration,
  });
}

class PackageFeatureModel {
  final String title;
  final String iconPath;

  PackageFeatureModel({required this.title, required this.iconPath});
}
