import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/dashboard_template.dart';
import '../attendance/absensi_list_page.dart';
import '../attendance/absensi_page.dart';

class DashboardUser extends StatefulWidget {
  @override
  _DashboardUserState createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  List<Map<String, dynamic>> menu = [
    {"title": "Absensi", "icon": Icons.camera_alt},
    {"title": "Ajukan Cuti", "icon": Icons.beach_access},
    {"title": "Ajukan Lembur", "icon": Icons.timer},
    {"title": "Riwayat Absensi", "icon": Icons.history},
    {"title": "Gaji & Potongan", "icon": Icons.money},
  ];

  String? Name = "";
  String? userEmail = "";
  String? userToken = "";

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
      userToken = prefs.getString("token") ?? ""; // ✅ PERBAIKAN: gunakan "token" bukan "token"
    });
    
    // Check semua keys yang ada di SharedPreferences
    final allKeys = prefs.getKeys();
    print('All SharedPreferences keys: $allKeys');
  }

  Future<void> handleMenuClick(String title) async {
    if (title == "Riwayat Absensi") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AbsensiListPage()),
      );
    } else if (title == "Absensi") {
      // Reload token untuk memastikan data terbaru
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? currentToken = prefs.getString("token");
      
      if (currentToken == null || currentToken.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token tidak ditemukan, silakan login kembali'),
            backgroundColor: Colors.red,
          ),
        );
        
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AbsensiPage(
            userName: Name ?? "Karyawan",
            token: currentToken,
          ),
        ),
      );
    } else if (title == "Ajukan Cuti") {
      // ✅ TAMBAHKAN: Navigasi ke halaman ajukan cuti
      Navigator.pushNamed(context, '/apply-leave');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fitur $title sedang dalam pengembangan"))
      );
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