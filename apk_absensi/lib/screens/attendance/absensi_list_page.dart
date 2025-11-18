import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_absensi/config/api.dart';
import 'absensi_detail_page.dart';

class AbsensiListPage extends StatefulWidget {
  @override
  _AbsensiListPageState createState() => _AbsensiListPageState();
}

class _AbsensiListPageState extends State<AbsensiListPage> {
  List<dynamic> _attendanceList = [];
  bool _loading = true;
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndHistory();
  }

  Future<void> _loadTokenAndHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString("token");
      
      if (_token == null || _token!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token tidak ditemukan, silakan login kembali'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      await _loadAttendanceHistory();
    } catch (e) {
      print('Error loading token: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadAttendanceHistory() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/attendance/history");
      
      print('Mengambil riwayat absensi dengan token: ${_token!.substring(0, 20)}...');

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $_token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      if (!mounted) return;

      print('Status history: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _attendanceList = data['data'] ?? [];
          _loading = false;
        });
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token tidak valid, silakan login kembali'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat riwayat: ${response.statusCode}'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _loading = false);
      }
    } catch (e) {
      print('Error load history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Absensi"),
        backgroundColor: Colors.blueAccent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _attendanceList.isEmpty
              ? const Center(
                  child: Text(
                    "Tidak ada data absensi",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _attendanceList.length,
                  itemBuilder: (context, index) {
                    final attendance = _attendanceList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today,
                            color: Colors.blueAccent),
                        title: Text(
                          attendance['date'] ?? 'Tanggal tidak tersedia',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Check-in: ${attendance['check_in_time'] ?? '-'}"),
                            Text(
                                "Check-out: ${attendance['check_out_time'] ?? '-'}"),
                            Text(
                                "Status: ${attendance['status'] ?? 'Tidak diketahui'}"),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AbsensiDetailPage(
                                attendance: attendance,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}