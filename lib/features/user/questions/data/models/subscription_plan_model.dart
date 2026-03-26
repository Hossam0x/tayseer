import 'package:flutter/material.dart';

enum PlanType { basic, premium, gold }

class SubscriptionFeature {
  final String imagePath;
  final String titleKey;

  const SubscriptionFeature({required this.imagePath, required this.titleKey});
}

class SubscriptionPlanModel {
  final PlanType type;
  final String titleKey;
  final String buttonTextKey;
  final List<SubscriptionFeature> features;
  final Color primaryColor;
  final Color secondaryColor;
  final Color shadowColor;
  final String? extraBadgeTextKey;

  const SubscriptionPlanModel({
    required this.type,
    required this.titleKey,
    required this.buttonTextKey,
    required this.features,
    required this.primaryColor,
    required this.secondaryColor,
    required this.shadowColor,
    this.extraBadgeTextKey,
  });
}
