import 'package:flutter/material.dart';

class StatItem {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final Color color;

  StatItem({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.color,
  });
}
