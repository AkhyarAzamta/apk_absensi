import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api.dart';
import 'absensi_detail_page.dart';

class AbsensiListPage extends StatefulWidget {
  @override
  _AbsensiListPageState createState() => _AbsensiListPageState();
}

class _AbsensiListPageState extends State<AbsensiListPage> {
  List<dynamic> records = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final uri = Uri.parse("${ApiConfig.baseUrl}/attendance/history");
    final response = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token", "Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        records = data['data'];
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat absensi")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Absensi")),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: records.length,
              itemBuilder: (context, index) {
                final att = records[index];
                return ListTile(
                  title: Text("Tanggal: ${att['date']}"),
                  subtitle: Text(
                    "Masuk: ${att['check_in_time'] ?? '-'} | Pulang: ${att['check_out_time'] ?? '-'}",
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AbsensiDetailPage(attendance: att),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
