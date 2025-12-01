// lib/models/division_setting_model.dart
import 'package:flutter/material.dart';

class DivisionSetting {
  final String division;
  final String workStart;
  final String workEnd;
  final int lateThreshold;
  final double overtimeRate;
  final double deductionRate;
  final double? baseSalary;
  final double? deductionPerMinute;

  DivisionSetting({
    required this.division,
    required this.workStart,
    required this.workEnd,
    required this.lateThreshold,
    required this.overtimeRate,
    required this.deductionRate,
    this.baseSalary,
    this.deductionPerMinute,
  });

  factory DivisionSetting.fromJson(Map<String, dynamic> json) {
    return DivisionSetting(
      division: json['division'] ?? '',
      workStart: json['workStart'] ?? '08:00',
      workEnd: json['workEnd'] ?? '17:00',
      lateThreshold: (json['lateThreshold'] is int)
          ? json['lateThreshold']
          : (json['lateThreshold'] as num).toInt(),
      overtimeRate: (json['overtimeRate'] is double)
          ? json['overtimeRate']
          : (json['overtimeRate'] as num).toDouble(),
      deductionRate: (json['deductionRate'] is double)
          ? json['deductionRate']
          : (json['deductionRate'] as num).toDouble(),
      baseSalary: json['baseSalary'] != null
          ? (json['baseSalary'] is double
                ? json['baseSalary']
                : (json['baseSalary'] as num).toDouble())
          : null,
      deductionPerMinute: json['deductionPerMinute'] != null
          ? (json['deductionPerMinute'] is double
                ? json['deductionPerMinute']
                : (json['deductionPerMinute'] as num).toDouble())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'division': division,
      'workStart': workStart,
      'workEnd': workEnd,
      'lateThreshold': lateThreshold,
      'overtimeRate': overtimeRate,
      'deductionRate': deductionRate,
      if (baseSalary != null) 'baseSalary': baseSalary,
      if (deductionPerMinute != null) 'deductionPerMinute': deductionPerMinute,
    };
  }

  DivisionSetting copyWith({
    String? division,
    String? workStart,
    String? workEnd,
    int? lateThreshold,
    double? overtimeRate,
    double? deductionRate,
    double? baseSalary,
    double? deductionPerMinute,
  }) {
    return DivisionSetting(
      division: division ?? this.division,
      workStart: workStart ?? this.workStart,
      workEnd: workEnd ?? this.workEnd,
      lateThreshold: lateThreshold ?? this.lateThreshold,
      overtimeRate: overtimeRate ?? this.overtimeRate,
      deductionRate: deductionRate ?? this.deductionRate,
      baseSalary: baseSalary ?? this.baseSalary,
      deductionPerMinute: deductionPerMinute ?? this.deductionPerMinute,
    );
  }
}

class DivisionSettingData {
  static List<String> get divisions => [
    'FINANCE',
    'HR',
    'IT',
    'OPERATIONAL',
    'MARKETING',
  ];

  static String getDivisionLabel(String division) {
    switch (division) {
      case 'FINANCE':
        return 'Keuangan';
      case 'HR':
        return 'HR';
      case 'IT':
        return 'IT';
      case 'OPERATIONAL':
        return 'Operasional';
      case 'MARKETING':
        return 'Pemasaran';
      default:
        return division;
    }
  }

  static Color getDivisionColor(String division) {
    switch (division) {
      case 'FINANCE':
        return Colors.green;
      case 'HR':
        return Colors.blue;
      case 'IT':
        return Colors.purple;
      case 'OPERATIONAL':
        return Colors.orange;
      case 'MARKETING':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getDivisionIcon(String division) {
    switch (division) {
      case 'FINANCE':
        return Icons.attach_money;
      case 'HR':
        return Icons.people;
      case 'IT':
        return Icons.computer;
      case 'OPERATIONAL':
        return Icons.build;
      case 'MARKETING':
        return Icons.trending_up;
      default:
        return Icons.business;
    }
  }

  // Default values for new division settings
  static DivisionSetting getDefaultSetting(String division) {
    return DivisionSetting(
      division: division,
      workStart: '08:00',
      workEnd: '17:00',
      lateThreshold: 15,
      overtimeRate: 1.5,
      deductionRate: 0.5,
      baseSalary: 5000000,
      deductionPerMinute: 1000,
    );
  }
}
