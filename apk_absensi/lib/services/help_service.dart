// services/help_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_absensi/config/api.dart';

class HelpService {
  Future<HelpResponse> getHelpData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/help'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return HelpResponse.fromJson(responseData['data']);
        } else {
          throw Exception(
            responseData['message'] ?? 'Gagal memuat data bantuan',
          );
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Error getting help data: $e');
      throw e;
    }
  }
}

class HelpResponse {
  final List<HelpContent> faqs;
  final List<HelpContent> contacts;
  final List<HelpContent> appInfo;
  final List<HelpContent> general;

  HelpResponse({
    required this.faqs,
    required this.contacts,
    required this.appInfo,
    required this.general,
  });

  factory HelpResponse.fromJson(Map<String, dynamic> json) {
    return HelpResponse(
      faqs:
          (json['faqs'] as List?)
              ?.map((e) => HelpContent.fromJson(e))
              .toList() ??
          [],
      contacts:
          (json['contacts'] as List?)
              ?.map((e) => HelpContent.fromJson(e))
              .toList() ??
          [],
      appInfo:
          (json['appInfo'] as List?)
              ?.map((e) => HelpContent.fromJson(e))
              .toList() ??
          [],
      general:
          (json['general'] as List?)
              ?.map((e) => HelpContent.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class HelpContent {
  final int id;
  final String? division;
  final String title;
  final String content;
  final String type;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  HelpContent({
    required this.id,
    this.division,
    required this.title,
    required this.content,
    required this.type,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HelpContent.fromJson(Map<String, dynamic> json) {
    return HelpContent(
      id: json['id'],
      division: json['division'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      order: json['order'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Helper method untuk kontak
  Map<String, dynamic> get contactInfo {
    if (type == 'CONTACT') {
      try {
        return jsonDecode(content);
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  // Helper method untuk app info
  Map<String, dynamic> get appInfo {
    if (type == 'APP_INFO') {
      try {
        return jsonDecode(content);
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  bool get isGlobal => division == null;
}
