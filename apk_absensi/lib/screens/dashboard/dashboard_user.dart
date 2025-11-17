import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/dashboard_template.dart';
import '../attendance/absensi_list_page.dart';
import '../attendance/absensi_page.dart';
import '../attendance/absensi_check_in_page.dart';
import '../attendance/absensi_check_out_page.dart';

class DashboardUser extends StatefulWidget {
  @override
  _DashboardUserState createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  List<Map<String, dynamic>> menu = [
    {"title": "Absensi", "icon": Icons.camera_alt},
    // {"title": "Absen Pulang", "icon": Icons.exit_to_app},
    {"title": "Ajukan Cuti", "icon": Icons.beach_access},
    {"title": "Ajukan Lembur", "icon": Icons.timer},
    {"title": "Riwayat Absensi", "icon": Icons.history},
    {"title": "Gaji & Potongan", "icon": Icons.money},
  ];

  String? Name = "";
  String? userEmail = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      Name = prefs.getString("user_name") ?? "Karyawan";
      userEmail = prefs.getString("user_email") ?? "email@example.com";
    });
  }

  Future<void> handleMenuClick(String title) async {
    if (title == "Riwayat Absensi") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AbsensiListPage()),
      );
    } else if (title == "Absensi" || title == "Absen Pulang") {
      // Ambil token dari SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String loggedInUserName = prefs.getString("user_name") ?? "Rifani";
      String loggedInUserToken = prefs.getString("user_token") ?? "";

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AbsensiPage(
            userName: loggedInUserName,
            token: loggedInUserToken, // ✅ sekarang sudah ada
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Menu $title diklik")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return buildDashboard(
      context: context,
      title: "Karyawan",
      menu: menu,
      color: Colors.grey[100],
      Name: Name,
      userEmail: userEmail,
      onMenuTap: handleMenuClick,
    );
  }
}
