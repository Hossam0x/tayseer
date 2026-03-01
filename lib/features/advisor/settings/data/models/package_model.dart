import 'package:flutter/material.dart';

class PackageFeatureModel {
  final String title;
  final String iconPath;

  PackageFeatureModel({required this.title, required this.iconPath});
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
