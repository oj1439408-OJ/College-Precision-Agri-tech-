import 'package:flutter/material.dart';

class SoilHealthItem {
  final String title;
  final String currentValue;
  final String status; // Low, Normal, Good, High
  final String explanation;
  final String statusColorHex;
  final double progressValue; // 0.0 to 1.0
  final IconData icon;

  SoilHealthItem({
    required this.title,
    required this.currentValue,
    required this.status,
    required this.explanation,
    required this.statusColorHex,
    required this.progressValue,
    required this.icon,
  });
}

class SoilHealthScore {
  final int score; // 0 to 100
  final String overallRating; // e.g. "Good", "Optimal"
  final String summary;
  final String disclaimer;
  final List<SoilHealthItem> items;

  SoilHealthScore({
    required this.score,
    required this.overallRating,
    required this.summary,
    required this.disclaimer,
    required this.items,
  });
}
