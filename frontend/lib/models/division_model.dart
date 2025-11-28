// lib/models/division_model.dart
import 'package:flutter/material.dart';

enum Division {
  FINANCE,
  APO,
  FRONT_DESK,
  ONSITE,
}

extension DivisionExtension on Division {
  String get label {
    switch (this) {
      case Division.FINANCE:
        return 'FINANCE';
      case Division.APO:
        return 'APO';
      case Division.FRONT_DESK:
        return 'FRONT DESK';
      case Division.ONSITE:
        return 'ONSITE';
      default:
        return 'UNKNOWN';
    }
  }

  String get displayName {
    switch (this) {
      case Division.FINANCE:
        return 'Finance';
      case Division.APO:
        return 'APO';
      case Division.FRONT_DESK:
        return 'Front Desk';
      case Division.ONSITE:
        return 'Onsite';
      default:
        return 'Unknown';
    }
  }

  Color get color {
    switch (this) {
      case Division.FINANCE:
        return Colors.green;
      case Division.APO:
        return Colors.blue;
      case Division.FRONT_DESK:
        return Colors.orange;
      case Division.ONSITE:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case Division.FINANCE:
        return Icons.attach_money;
      case Division.APO:
        return Icons.business_center;
      case Division.FRONT_DESK:
        return Icons.desk;
      case Division.ONSITE:
        return Icons.location_on;
      default:
        return Icons.business;
    }
  }
}

class DivisionHelper {
  static List<Division> get allDivisions => Division.values;

  static Division fromString(String value) {
    try {
      return Division.values.firstWhere(
        (e) => e.toString().split('.').last == value.toUpperCase(),
      );
    } catch (e) {
      return Division.ONSITE; // default fallback
    }
  }

  static String toDisplayString(String value) {
    final division = fromString(value);
    return division.displayName;
  }
}