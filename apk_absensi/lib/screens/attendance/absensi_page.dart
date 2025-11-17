import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class DailyLog {
  String date;
  String? checkIn;
  String? checkOut;
  Uint8List? photoBytes;

  DailyLog({required this.date, this.checkIn, this.checkOut, this.photoBytes});
}

class ApiConfig {
  static const String baseUrl = "http://192.168.1.33:8000/api";
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

  // ================== HANDLE MESSAGES FROM IFRAME ==================
  void _handleMessage(html.MessageEvent event) async {
    if (!mounted) return;

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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wajah tidak terdeteksi. Ambil foto gagal!'),
            ),
          );
        }
      }
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
      final completer = Completer<Map<String, double>>();

      if (html.window.navigator.geolocation != null) {
        html.window.navigator.geolocation!
            .getCurrentPosition(enableHighAccuracy: true)
            .then((position) {
              // pastikan coords tidak null
              final coords = position.coords;
              final lat = coords?.latitude ?? 0.0;
              final lng = coords?.longitude ?? 0.0;

              completer.complete({
                'lat': lat.toDouble(),
                'lng': lng.toDouble(),
              });
            })
            .catchError((e) {
              print('Error ambil lokasi: $e');
              completer.complete({'lat': 0.0, 'lng': 0.0});
            });
      } else {
        print('Geolocation tidak tersedia di browser ini');
        completer.complete({'lat': 0.0, 'lng': 0.0});
      }

      return completer.future;
    } catch (e) {
      print('Error exception ambil lokasi: $e');
      return {'lat': 0.0, 'lng': 0.0};
    }
  }

  // ================== UPLOAD ATTENDANCE ==================
  Future<void> _uploadAttendance(
    String dataUrl, {
    required bool isCheckIn,
  }) async {
    setState(() => _isProcessing = true);

    try {
      final location = await _getCurrentLocation();
      final lat = location?['lat'] ?? 0.0;
      final lng = location?['lng'] ?? 0.0;

      final blob = html.Blob([
        base64Decode(dataUrl.split(',')[1]),
      ], 'image/png');
      final formData = html.FormData();
      formData.appendBlob('photo', blob, 'attendance.png');

      // Gunakan lokasi yang sebenarnya
      formData.append('lat', lat.toString());
      formData.append('lng', lng.toString());

      final url = isCheckIn
          ? '${ApiConfig.baseUrl}/attendance/checkin'
          : '${ApiConfig.baseUrl}/attendance/checkout';

      print('Mengirim request ke: $url dengan lat=$lat, lng=$lng');

      final request = html.HttpRequest();
      request
        ..open('POST', url)
        ..setRequestHeader('Authorization', 'Bearer ${widget.token}')
        ..onLoad.listen((event) {
          if (!mounted) return;
          setState(() => _isProcessing = false);

          print('Status: ${request.status}');
          print('Response: ${request.responseText}');

          if (request.status == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isCheckIn ? 'Check-In berhasil!' : 'Check-Out berhasil!',
                ),
              ),
            );
            setState(() {
              if (isCheckIn) {
                _getTodayLog().checkIn = TimeOfDay.now().format(context);
              } else {
                _getTodayLog().checkOut = TimeOfDay.now().format(context);
              }
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Absensi gagal: ${request.responseText}')),
            );
          }
        })
        ..onError.listen((event) {
          if (!mounted) return;
          setState(() => _isProcessing = false);
          print('Request error: $event');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terjadi kesalahan saat upload!')),
          );
        })
        ..send(formData);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      print('Error exception: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => captureImage(isCheckIn: true),
                  icon: const Icon(Icons.login),
                  label: Text(_isProcessing ? 'Memproses...' : 'Masuk'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () => captureImage(isCheckIn: false),
                  icon: const Icon(Icons.logout),
                  label: Text(_isProcessing ? 'Memproses...' : 'Keluar'),
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
