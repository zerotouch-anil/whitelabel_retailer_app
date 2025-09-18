import 'package:flutter/material.dart';
import 'package:eWarranty/models/dashboard_model.dart';

class ScreenUtil {
  static late double _unitHeight;

  static void initialize(BuildContext context) {
    _unitHeight = MediaQuery.of(context).size.height / 1000;
  }

  static double get unitHeight => _unitHeight;

  static double calculateCustomerCardHeight(
    BuildContext context,
    String? notes,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    const double paddingHeight = 32; // Container padding
    const double headerRowHeight = 36; // Icon + name + warranty key
    const double spacingAfterHeader = 12;
    const double categoryModelRowHeight = 32;
    const double spacingAfterChips = 8;
    const double dateAmountRowHeight = 20;
    const double spacingAfterDate = 8;

    double notesHeight = 0;
    if (notes?.isNotEmpty == true) {
      notesHeight = 8 + 20; // Padding + text height
    }

    double calculatedHeight =
        paddingHeight +
        headerRowHeight +
        spacingAfterHeader +
        categoryModelRowHeight +
        spacingAfterChips +
        dateAmountRowHeight +
        spacingAfterDate +
        notesHeight;

    double totalHeight = calculatedHeight + 15;

    double minHeight = screenHeight * 0.18;
    double maxHeight = screenHeight * 0.35;

    return totalHeight.clamp(minHeight, maxHeight);
  }
}
