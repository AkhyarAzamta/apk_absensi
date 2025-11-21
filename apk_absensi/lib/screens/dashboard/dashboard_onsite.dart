import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_absensi/widgets/dashboard_template.dart';
import 'package:apk_absensi/screens/onsite/jam_kerja_page.dart';
import 'package:apk_absensi/screens/onsite/validasi_gps_page.dart';
import 'package:apk_absensi/screens/onsite/potongan_page.dart';
import 'package:apk_absensi/screens/attendance/absensi_list_page.dart';

class DashboardOnsite extends StatefulWidget {
  @override
  _DashboardOnsiteState createState() => _DashboardOnsiteState();
}

class _DashboardOnsiteState extends State<DashboardOnsite> {
  final List<Map<String, dynamic>> menu = [
    {"title": "Absensi Onsite", "icon": Icons.location_on},
    {"title": "Validasi GPS", "icon": Icons.map},
    {"title": "Lembur", "icon": Icons.timer_sharp},
    {"title": "Cuti", "icon": Icons.beach_access},
    {"title": "Laporan Onsite", "icon": Icons.list_alt},
    {"title": "Export", "icon": Icons.import_export},
    {"title": "Potongan", "icon": Icons.money_off},
    {"title": "Jam Kerja", "icon": Icons.access_time_filled},
  ];

  // Method untuk fetch division settings
  Future<Map<String, dynamic>?> fetchDivisionSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      // Untuk demo, kita gunakan division id 1
      int divisionId = 1;

      final response = await http.get(
        Uri.parse(
          "http://localhost:3000/api/division-settings/by-division/$divisionId",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching division settings: $e');
      return null;
    }
  }

  void handleMenuTap(String title) async {
    Map<String, dynamic>? data = await fetchDivisionSettings();

    switch (title) {
      case "Absensi Onsite":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AbsensiListPage()),
        );
        break;

      case "Jam Kerja":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => JamKerjaPage(data: data)),
        );
        break;

      case "Validasi GPS":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ValidasiGpsPage(data: data)),
        );
        break;

      case "Potongan":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PotonganPage(data: data)),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Menu '$title' belum tersedia"))
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardTemplate(
      title: "Onsite",
      menu: menu,
      color: Colors.purple[100],
      onMenuTap: handleMenuTap,
    );
  }
}