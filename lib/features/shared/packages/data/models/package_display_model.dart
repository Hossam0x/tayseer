import 'package:flutter/material.dart';
import 'package:tayseer/features/shared/packages/data/models/package_feature_model.dart';

class PackageDisplayModel {
  final String id;
  final String packageTitle;
  final List<PackageFeatureModel> features;
  final String price;
  final String buttonText;
  final List<Color> backgroundGradient;
  final Color themeColor;

  const PackageDisplayModel({
    required this.id,
    required this.packageTitle,
    required this.features,
    required this.price,
    required this.buttonText,
    required this.backgroundGradient,
    required this.themeColor,
  });
}
