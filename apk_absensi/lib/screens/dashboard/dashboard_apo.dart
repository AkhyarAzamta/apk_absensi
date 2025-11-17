import 'package:flutter/material.dart';
import '../../widgets/dashboard_template.dart';

class DashboardApo extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return buildDashboard(
      context: context, 
      title: "Dashboard APO",
      menu: menu,
      color: Colors.purple[100],
    );
  }
}
