import 'package:apk_absensi/screens/admin/attedance/attedance_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:apk_absensi/widgets/dashboard_template.dart';
import 'package:apk_absensi/screens/admin/users/user_list_screen.dart';
import 'package:apk_absensi/screens/admin/leaves/leave_approval_screen.dart';

class DashboardFinance extends StatelessWidget {
  final List<Map<String, dynamic>> menu = [
    {"title": "Data Karyawan", "icon": Icons.people_alt},
    {"title": "Absensi", "icon": Icons.fingerprint},
    {"title": "Persetujuan Cuti", "icon": Icons.fact_check},
    {"title": "Persetujuan Lembur", "icon": Icons.add_alarm},
    {"title": "Laporan", "icon": Icons.analytics},
    {"title": "Export Laporan", "icon": Icons.file_download},
    {"title": "Potongan", "icon": Icons.payments},
    {"title": "Jam Kerja", "icon": Icons.schedule},
  ];

// Dalam class DashboardFinance
  void handleMenuTap(String title, BuildContext context) {
    switch (title) {
      case "Data Karyawan":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserListScreen(division: 'FINANCE'),
          ),
        );
        break;
      case "Absensi":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceListScreen(division: 'FINANCE'),
          ),
        );
        break;
      case "Persetujuan Cuti":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LeaveApprovalScreen(division: 'FINANCE'),
          ),
        );
        break;
      // ... case lainnya ...
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardTemplate(
      title: "Dashboard Finance",
      menu: menu,
      color: Colors.purple[100],
      onMenuTap: (title) => handleMenuTap(title, context),
    );
  }
}