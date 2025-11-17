import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/dashboard_template.dart';

class DashboardFrontdesk extends StatefulWidget {
  @override
  _DashboardFrontdesk createState() => _DashboardFrontdesk();
}

class _DashboardFrontdesk extends State<DashboardFrontdesk> {
  String? userName = "Nama Pengguna";
  String? userEmail = "email@example.com";
  final List<Map<String, dynamic>> menu = [
    {"title": "Data Karyawan", "icon": Icons.people_outline, "route": "/users"},
    {"title": "Absensi", "icon": Icons.check},
    {"title": "Cuti & Lembur", "icon": Icons.badge},
    {"title": "Laporan", "icon": Icons.insert_chart},
    {"title": "Export Laporan", "icon": Icons.print},
    {"title": "Potongan", "icon": Icons.money_off_csred_outlined},
    {"title": "Pengaturan Jam Kerja", "icon": Icons.timer_outlined},
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

  @override
  Widget build(BuildContext context) {
    return buildDashboard(
      context: context,
      title: "Dashboard Frontdesk",
      menu: menu,
      color: Colors.purple[100],
    );
  }
}
