import 'package:flutter/material.dart';

/// Centralized color palette for list items across the app.
///
/// Use `AppColors.itemColors` or `AppColors.colorForIndex(i)` wherever
/// you need a rotating color for subjects, classes, timetable slots, etc.
///
/// ```dart
/// final color = AppColors.colorForIndex(index);
/// ```
class AppColors {
  AppColors._();

  /// Shared 8-color palette for list items (subjects, classes, timetable, etc.)
  static const List<Color> itemColors = [
    Color(0xFF5C6BC0), // Indigo
    Color(0xFF26A69A), // Teal
    Color(0xFFEF5350), // Red
    Color(0xFF42A5F5), // Blue
    Color(0xFFFF7043), // Deep Orange
    Color(0xFF66BB6A), // Green
    Color(0xFFAB47BC), // Purple
    Color(0xFFFFA726), // Amber
  ];

  /// Returns a color from [itemColors] for the given index (wraps around).
  static Color colorForIndex(int index) =>
      itemColors[index % itemColors.length];
}
