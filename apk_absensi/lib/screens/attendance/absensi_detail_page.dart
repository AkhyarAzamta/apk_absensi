import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class AbsensiDetailPage extends StatelessWidget {
  final Map<String, dynamic> attendance;

  AbsensiDetailPage({required this.attendance});

  Widget buildPhoto(String? photo) {
    if (photo == null || photo.isEmpty) {
      return Icon(Icons.account_circle, size: 150, color: Colors.grey);
    }
    try {
      if (photo.startsWith("http")) {
        return Image.network(photo, height: 150);
      } else {
        Uint8List bytes = base64Decode(photo);
        return Image.memory(bytes, height: 150);
      }
    } catch (e) {
      return Icon(Icons.account_circle, size: 150, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Detail Absensi")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Center(child: buildPhoto(attendance['check_in_photo'])),
            SizedBox(height: 10),
            Text("Check-in: ${attendance['check_in_time'] ?? '-'}"),
            SizedBox(height: 5),
            Text("Check-out: ${attendance['check_out_time'] ?? '-'}"),
            SizedBox(height: 5),
            Text("Status: ${attendance['status'] ?? '-'}"),
            SizedBox(height: 5),
            Text("Telat: ${attendance['late_minutes'] ?? 0} menit"),
            SizedBox(height: 5),
            Text("Denda: ${attendance['late_penalty'] ?? 0}"),
            SizedBox(height: 5),
            Text(
              "Lokasi valid: ${attendance['location_verified'] == true ? 'Ya' : 'Tidak'}",
            ),
          ],
        ),
      ),
    );
  }
}
