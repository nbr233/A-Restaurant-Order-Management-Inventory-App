import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF5E35B1); // Deep Purple
  static const Color secondaryColor = Color(0xFFF3E5F5); // Light Purple
  static const Color backgroundColor = Color(0xFFF5F6FA); // Light Grey
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFE0E0E0);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Table Status
  static const Color tableAvailable = Color(0xFFE8F5E9);
  static const Color tableAvailableText = Color(0xFF2E7D32);
  static const Color tableOccupied = Color(0xFFFFEBEE);
  static const Color tableOccupiedText = Color(0xFFC62828);
  static const Color tableReserved = Color(0xFFFFF3E0);
  static const Color tableReservedText = Color(0xFFEF6C00);
}

class AppConstants {
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const String currencySymbol = '৳'; // BDT symbol from the design
}
