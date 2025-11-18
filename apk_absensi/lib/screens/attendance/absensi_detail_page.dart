import 'dart:convert';
import 'package:apk_absensi/config/api.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class AbsensiDetailPage extends StatelessWidget {
  final Map<String, dynamic> attendance;

  const AbsensiDetailPage({required this.attendance, super.key});

  Widget buildPhoto(String? photo) {
    if (photo == null || photo.isEmpty) {
      return _placeholder();
    }

    // sudah full URL dari backend → load saja
    if (photo.startsWith("http")) {
      return _buildNetworkImage(photo);
    }

    // base64
    if (photo.startsWith("/9j") || photo.startsWith("iVBOR")) {
      return Image.memory(
        base64Decode(photo),
        height: 150,
        width: 150,
        fit: BoxFit.cover,
      );
    }

    return _buildNetworkImage(
      "${ApiConfig.baseUrl.replaceFirst('/api', '')}$photo",
    );
  }

  Widget _placeholder() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildNetworkImage(String url) {
    return Image.network(
      url,
      height: 150,
      width: 150,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                color: isImportant ? Colors.blueAccent : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Absensi"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo Section
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Foto Absensi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(child: buildPhoto(attendance['check_in_photo'])),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Attendance Details
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informasi Absensi",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),

                    _buildInfoRow("Tanggal:", attendance['date'] ?? '-'),
                    _buildInfoRow(
                      "Check-in:",
                      attendance['check_in_time'] ?? '-',
                    ),
                    _buildInfoRow(
                      "Check-out:",
                      attendance['check_out_time'] ?? '-',
                    ),
                    _buildInfoRow(
                      "Status:",
                      attendance['status'] ?? '-',
                      isImportant: true,
                    ),
                    _buildInfoRow(
                      "Telat:",
                      "${attendance['late_minutes'] ?? 0} menit",
                    ),
                    _buildInfoRow(
                      "Denda:",
                      "Rp ${attendance['late_penalty'] ?? 0}",
                    ),
                    _buildInfoRow(
                      "Lokasi Valid:",
                      attendance['location_verified'] == true ? 'Ya' : 'Tidak',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
