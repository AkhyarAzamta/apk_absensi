import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api.dart';
import '../onsite/jam_kerja_page.dart';
import '../onsite/validasi_gps_page.dart';
import '../onsite/potongan_page.dart';
import '../attendance/absensi_list_page.dart';
import '../../widgets/dashboard_template.dart';

class DashboardOnsite extends StatefulWidget {
  @override
  _DashboardOnsiteState createState() => _DashboardOnsiteState();
}

class _DashboardOnsiteState extends State<DashboardOnsite> {
  String? userName = "Nama Pengguna";
  String? userEmail = "email@example.com";

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

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("user_name") ?? "Nama Pengguna";
      userEmail = prefs.getString("user_email") ?? "email@example.com";
    });
  }

  // Ambil data API sebelum pindah halaman
  Future<Map<String, dynamic>?> fetchDivisionSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      int divisionId = prefs.getInt("division_id") ?? 1;

      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/division-settings/by-division/$divisionId",
        ),
        headers: {"Authorization": "Bearer $token"},
      );

      return json.decode(response.body);
    } catch (e) {
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
          MaterialPageRoute(builder: (_) => JamKerjaPage(data!)),
        );
        break;

      case "Validasi GPS":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ValidasiGpsPage(data!)),
        );
        break;

      case "Potongan":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PotonganPage(data!)),
        );
        break;

      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Menu '$title' belum tersedia")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildDashboard(
      context: context,
      title: "Onsite",
      menu: menu,
      Name: userName,
      userEmail: userEmail,
      color: Colors.purple[100],
      onMenuTap: handleMenuTap,
    );
  }
}
