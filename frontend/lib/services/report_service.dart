// lib/services/report_service.dart

import 'dart:convert';
import 'dart:io';
import 'dart:js' as js;
import 'dart:html' as html;

import 'package:http/http.dart' as http;
import 'package:apk_absensi/models/report_model.dart';
import 'package:apk_absensi/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ReportService {
  static final String _baseUrl = ApiConfig.baseUrl;
  static final Dio _dio = Dio();

  // ============================
  // GET ATTENDANCE REPORT
  // ============================
  static Future<List<AttendanceReport>> getAttendanceReport(
    ReportFilter filter,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token tidak ditemukan');

      final uri = Uri.parse(
        '$_baseUrl/reports/attendance',
      ).replace(queryParameters: filter.toQueryParams());

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data'];
        return items.map((e) => AttendanceReport.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat laporan');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============================
  // GET SALARY REPORT
  // ============================
  static Future<List<SalaryReport>> getSalaryReport(ReportFilter filter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) throw Exception('Token tidak ditemukan');

      final uri = Uri.parse(
        '$_baseUrl/reports/salary',
      ).replace(queryParameters: filter.toQueryParams());

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items = data['data'];
        return items.map((e) => SalaryReport.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat laporan gaji');
      }
    } catch (e) {
      rethrow;
    }
  }

  static ReportSummary calculateAttendanceSummary(
    List<AttendanceReport> reports,
  ) {
    if (reports.isEmpty) {
      return ReportSummary(
        totalRecords: 0,
        totalLembur: 0,
        totalPotongan: 0,
        totalGaji: 0,
        rataRataTerlambat: 0,
      );
    }

    final totalLembur = reports.fold(0.0, (sum, report) => sum + report.lembur);
    final totalPotongan = reports.fold(
      0.0,
      (sum, report) => sum + report.potongan,
    );
    final totalGaji = reports.fold(
      0.0,
      (sum, report) => sum + report.totalGaji,
    );
    final rataRataTerlambat =
        reports.fold(0, (sum, report) => sum + report.terlambat) /
        reports.length;

    return ReportSummary(
      totalRecords: reports.length,
      totalLembur: totalLembur,
      totalPotongan: totalPotongan,
      totalGaji: totalGaji,
      rataRataTerlambat: rataRataTerlambat,
    );
  }

  // ============================================================
  // 🔥 FIX #2 — Tambahkan calculateSalaryDecisionTree()
  // ============================================================

  static Map<String, dynamic> calculateSalaryDecisionTree(
    AttendanceReport report,
  ) {
    String kategori;
    double bonus = 0;

    // Contoh logika sederhana
    if (report.lembur >= 2) {
      kategori = "Kinerja Tinggi";
      bonus = 50000;
    } else if (report.terlambat > 30) {
      kategori = "Kurang Disiplin";
      bonus = -20000;
    } else {
      kategori = "Standar";
      bonus = 0;
    }

    return {"kategori": kategori, "bonus": bonus};
  }

  // ============================
  // EXPORT ATTENDANCE REPORT
  // ============================
  static Future<String> exportAttendanceReport({
    required ReportFilter filter,
    required String format,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final params = filter.toQueryParams()..['format'] = format;

    final url = Uri.parse(
      '$_baseUrl/reports/attendance/export',
    ).replace(queryParameters: params).toString();

    if (kIsWeb) {
      return _downloadWeb(url, token, 'laporan_absensi', format);
    } else {
      return _downloadMobile(url, token, 'laporan_absensi', format);
    }
  }

  // ============================
  // EXPORT SALARY REPORT
  // ============================
  static Future<String> exportSalaryReport({
    required ReportFilter filter,
    required String format,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token tidak ditemukan');

    final params = filter.toQueryParams()..['format'] = format;

    final url = Uri.parse(
      '$_baseUrl/reports/salary/export',
    ).replace(queryParameters: params).toString();

    if (kIsWeb) {
      return _downloadWeb(url, token, 'laporan_gaji', format);
    } else {
      return _downloadMobile(url, token, 'laporan_gaji', format);
    }
  }

  // ============================
  // DOWNLOAD (WEB)
  // ============================
  // ============================
  // DOWNLOAD (WEB) — FIX TANPA JS EXTERNAL
  // ============================
  static Future<String> _downloadWeb(
    String url,
    String token,
    String filename,
    String format,
  ) async {
    final ext = format.toLowerCase() == "pdf" ? ".pdf" : ".xlsx";
    final fullName = "$filename$ext";

    try {
      // Ambil file dari server
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode != 200) {
        throw Exception("Gagal mengambil file dari server");
      }

      // Convert bytes → blob
      final blob = html.Blob([response.bodyBytes]);

      // Buat URL blob
      final blobUrl = html.Url.createObjectUrlFromBlob(blob);

      // Buat link download
      final anchor = html.AnchorElement(href: blobUrl)
        ..download = fullName
        ..style.display = "none";

      html.document.body!.children.add(anchor);
      anchor.click(); // 👉 Trigger download
      anchor.remove();

      // Bersihkan URL blob
      html.Url.revokeObjectUrl(blobUrl);

      return "Download berhasil dimulai.";
    } catch (e) {
      return "Gagal download file web: $e";
    }
  }

  // ============================
  // DOWNLOAD (MOBILE)
  // ============================
  static Future<String> _downloadMobile(
    String url,
    String token,
    String filename,
    String format,
  ) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final bytes = response.data as List<int>;
      final ext = format.toLowerCase() == "pdf" ? ".pdf" : ".xlsx";

      // SIMPAN FILE (ditulis manual)
      final dir = Directory.systemTemp.path;
      final fullPath = "$dir/$filename$ext";
      final file = File(fullPath);
      await file.writeAsBytes(bytes);

      return fullPath;
    } catch (e) {
      throw Exception("Gagal download file mobile: $e");
    }
  }
}
