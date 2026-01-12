import 'package:flutter/material.dart';

class SettingItemModel {
  final String id;
  final String title;
  final String? subtitle;
  final String iconAsset;
  final bool hasSwitch;
  final bool switchValue;
  final bool isDangerous;
  final String routeName;
  final Future<void> Function()? onTap;
  final ValueChanged<bool>? onSwitchChanged;

  SettingItemModel({
    required this.id,
    required this.title,
    this.subtitle,
    required this.iconAsset,
    this.hasSwitch = false,
    this.switchValue = false,
    this.isDangerous = false,
    required this.routeName,
    this.onTap,
    this.onSwitchChanged,
  });

  SettingItemModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? iconAsset,
    bool? hasSwitch,
    bool? switchValue,
    bool? isDangerous,
    String? routeName,
    Future<void> Function()? onTap,
    ValueChanged<bool>? onSwitchChanged,
  }) {
    return SettingItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconAsset: iconAsset ?? this.iconAsset,
      hasSwitch: hasSwitch ?? this.hasSwitch,
      switchValue: switchValue ?? this.switchValue,
      isDangerous: isDangerous ?? this.isDangerous,
      routeName: routeName ?? this.routeName,
      onTap: onTap ?? this.onTap,
      onSwitchChanged: onSwitchChanged ?? this.onSwitchChanged,
    );
  }
}
