import 'package:flutter/material.dart';
import 'package:apk_absensi/widgets/dashboard_template.dart';

class DashboardFrontdesk extends StatelessWidget {
  final List<Map<String, dynamic>> menu = [
    {"title": "Data Karyawan", "icon": Icons.people_outline},
    {"title": "Absensi", "icon": Icons.check},
    {"title": "Cuti & Lembur", "icon": Icons.badge},
    {"title": "Laporan", "icon": Icons.insert_chart},
    {"title": "Export Laporan", "icon": Icons.print},
    {"title": "Potongan", "icon": Icons.money_off_csred_outlined},
    {"title": "Pengaturan Jam Kerja", "icon": Icons.timer_outlined},
  ];

  void handleMenuTap(String title) {
    // Implementasi menu tap untuk frontdesk
    print('Menu tapped: $title');
  }

  @override
  Widget build(BuildContext context) {
    return DashboardTemplate(
      title: "Dashboard Frontdesk",
      menu: menu,
      color: Colors.purple[100],
      onMenuTap: handleMenuTap,
    );
  }
}