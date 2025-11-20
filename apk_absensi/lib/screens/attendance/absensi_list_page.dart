import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_absensi/config/api.dart';
import 'package:intl/intl.dart';
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

      print(
        'Mengambil riwayat absensi dengan token: ${_token!.substring(0, 20)}...',
      );

      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $_token",
          "Accept": "application/json",
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
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _loading = false);
      }
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'PRESENT':
        return 'Hadir';
      case 'LATE':
        return 'Terlambat';
      case 'ABSENT':
        return 'Tidak Hadir';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PRESENT':
        return Colors.green;
      case 'LATE':
        return Colors.orange;
      case 'ABSENT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Absensi"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _attendanceList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "Tidak ada riwayat absensi",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAttendanceHistory,
              child: ListView.builder(
                itemCount: _attendanceList.length,
                itemBuilder: (context, index) {
                  final attendance = _attendanceList[index];
                  final date = DateTime.parse(attendance['date']).toLocal();
                  final checkIn = attendance['checkIn'] != null
                      ? DateFormat('HH:mm').format(
                          DateTime.parse(attendance['checkIn']).toLocal(),
                        )
                      : '-';
                  final checkOut = attendance['checkOut'] != null
                      ? DateFormat('HH:mm').format(
                          DateTime.parse(attendance['checkOut']).toLocal(),
                        )
                      : '-';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('dd').format(date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueAccent,
                              ),
                            ),
                            Text(
                              DateFormat('MMM').format(date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('EEEE', 'id_ID').format(date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                attendance['status'],
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getStatusColor(attendance['status']),
                              ),
                            ),
                            child: Text(
                              _formatStatus(attendance['status']),
                              style: TextStyle(
                                color: _getStatusColor(attendance['status']),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.login, size: 16, color: Colors.green),
                              const SizedBox(width: 4),
                              const Text(
                                'Masuk: ',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(checkIn),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.logout, size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              const Text(
                                'Pulang: ',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(checkOut),
                            ],
                          ),
                          if (attendance['lateMinutes'] != null &&
                              attendance['lateMinutes'] > 0) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Terlambat: ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text('${attendance['lateMinutes']} menit'),
                              ],
                            ),
                          ],
                          if (attendance['notes'] != null &&
                              attendance['notes'].isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.note,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Catatan: ',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Expanded(
                                  child: Text(
                                    attendance['notes'],
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AbsensiDetailPage(attendance: attendance),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
    );
  }
}
