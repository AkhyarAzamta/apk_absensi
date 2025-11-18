import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:apk_absensi/config/api.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class DailyLog {
  String date;
  String? checkIn;
  String? checkOut;
  Uint8List? photoBytes;

  DailyLog({required this.date, this.checkIn, this.checkOut, this.photoBytes});
}

class AbsensiPage extends StatefulWidget {
  final String userName;
  final String token;

  const AbsensiPage({required this.userName, required this.token, super.key});

  @override
  _AbsensiPageState createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  List<DailyLog> _dailyLogs = [];
  String _todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _isProcessing = false;
  bool _isCheckIn = true;

  late final StreamSubscription<html.MessageEvent> _messageSub;

  @override
  void initState() {
    super.initState();
    _messageSub = html.window.onMessage.listen(_handleMessage);
  }

  @override
  void dispose() {
    _messageSub.cancel();
    super.dispose();
  }

  void _handleMessage(html.MessageEvent event) async {
    if (!mounted) return;

    try {
      if (event.data != null && event.data is Map) {
        final data = Map<String, dynamic>.from(event.data);

        if (data['type'] == 'capture' && data['dataUrl'] != null) {
          final dataUrl = data['dataUrl'] as String;
          final bytes = base64Decode(dataUrl.split(',')[1]);

          setState(() {
            _getTodayLog().photoBytes = bytes;
          });

          await _uploadAttendance(dataUrl, isCheckIn: _isCheckIn);
        } else if (data['type'] == 'faceDetection' &&
            data['faceDetected'] != null) {
          bool faceDetected = data['faceDetected'] as bool;
          if (faceDetected) {
            final element = html.document.querySelector('iframe');
            if (element is html.IFrameElement) {
              element.contentWindow?.postMessage({'type': 'takePhoto'}, '*');
            }
          } else {
            setState(() => _isProcessing = false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wajah tidak terdeteksi. Ambil foto gagal!'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
    }
  }

  DailyLog _getTodayLog() {
    var log = _dailyLogs.firstWhere(
      (l) => l.date == _todayDate,
      orElse: () {
        final newLog = DailyLog(date: _todayDate);
        _dailyLogs.add(newLog);
        return newLog;
      },
    );
    return log;
  }

  void captureImage({required bool isCheckIn}) {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _isCheckIn = isCheckIn;
    });

    final element = html.document.querySelector('iframe');
    if (element is html.IFrameElement) {
      element.contentWindow?.postMessage({'type': 'detectFace'}, '*');
    } else {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Iframe tidak ditemukan!')));
    }
  }

  // ================== GET LOCATION ==================
  Future<Map<String, double>> _getCurrentLocation() async {
    try {
      // Attempt to get current position; browsers that don't support geolocation
      // will throw and be handled by the catch block.
      final position = await html.window.navigator.geolocation
          .getCurrentPosition(enableHighAccuracy: true);

      // Handle null safety untuk coords
      final coords = position.coords;
      if (coords == null) {
        print('Koordinat tidak tersedia');
        return {'lat': -6.9173248, 'lng': 107.6461568};
      }

      // Akses latitude dan longitude dengan null safety
      final lat = (coords.latitude ?? -6.9173248).toDouble();
      final lng = (coords.longitude ?? 107.6461568).toDouble();

      print('Lokasi berhasil didapat: lat=$lat, lng=$lng');
      return {'lat': lat, 'lng': lng};
    } catch (e) {
      print('Error geolocation: $e');
      // Return default location (Kantor)
      return {'lat': -6.9173248, 'lng': 107.6461568};
    }
  }

  // ================== UPLOAD ATTENDANCE ==================
  Future<void> _uploadAttendance(
    String dataUrl, {
    required bool isCheckIn,
  }) async {
    if (!mounted) return;
    setState(() => _isProcessing = true);

    try {
      // Ambil lokasi
      final location = await _getCurrentLocation();

      final url = Uri.parse(
        isCheckIn
            ? '${ApiConfig.baseUrl}/attendance/checkin'
            : '${ApiConfig.baseUrl}/attendance/checkout',
      );

      // Extract base64
      final base64String = dataUrl.split(',').last;
      final bytes = base64Decode(base64String);

      // ===== FIX: WAJIB pakai MultipartRequest untuk WEB =====
      final request = http.MultipartRequest("POST", url);

      request.headers.addAll({
        "Authorization": "Bearer ${widget.token}",
        "Accept": "application/json",
      });

      // FILE
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: "attendance.jpg",
          contentType: MediaType("image", "jpeg"),
        ),
      );

      // Fields
      request.fields['lat'] = location['lat'].toString();
      request.fields['lng'] = location['lng'].toString();

      // Kirim request
      final responseStream = await request.send();
      final responseBody = await responseStream.stream.bytesToString();

      if (!mounted) return;
      setState(() => _isProcessing = false);

      // Cek hasil
      if (responseStream.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCheckIn ? 'Check-In berhasil!' : 'Check-Out berhasil!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Update DailyLog
        final today = _getTodayLog();
        final now = DateFormat('HH:mm:ss').format(DateTime.now());
        if (isCheckIn) {
          today.checkIn = now;
        } else {
          today.checkOut = now;
        }

        if (today.photoBytes == null) {
          today.photoBytes = bytes;
        }

        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Upload gagal: $responseBody"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error upload: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek jika token kosong
    if (widget.token.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Absensi - ${widget.userName}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: 320,
              height: 240,
              child: HtmlElementView(viewType: 'face-detect'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => captureImage(isCheckIn: true),
                    icon: const Icon(Icons.login),
                    label: Text(_isProcessing ? 'Memproses...' : 'Masuk'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => captureImage(isCheckIn: false),
                    icon: const Icon(Icons.logout),
                    label: Text(_isProcessing ? 'Memproses...' : 'Keluar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Log Harian:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            _dailyLogs.isEmpty
                ? const Text('Belum ada log')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _dailyLogs.length,
                    itemBuilder: (context, index) {
                      final log = _dailyLogs[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal: ${DateFormat('dd MMM yyyy').format(DateTime.parse(log.date))}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Masuk: ${log.checkIn ?? '-'}'),
                              Text('Pulang: ${log.checkOut ?? '-'}'),
                              const SizedBox(height: 4),
                              log.photoBytes != null
                                  ? Image.memory(
                                      log.photoBytes!,
                                      height: 100,
                                      width: 100,
                                    )
                                  : const Text('Foto: -'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
