import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api.dart';

class AbsensiAddPage extends StatefulWidget {
  @override
  _AbsensiAddPageState createState() => _AbsensiAddPageState();
}

class _AbsensiAddPageState extends State<AbsensiAddPage> {
  File? _imageFile;
  XFile? _webImageFile;
  String? _webImageDataUrl;
  bool loading = false;

  Future<void> pickImage({required bool fromCamera}) async {
    final picker = ImagePicker();
    if (kIsWeb) {
      if (!fromCamera) {
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _webImageFile = pickedFile;
            _webImageDataUrl = null;
          });
        }
      } else {
        // implement Web camera
      }
    } else {
      final pickedFile = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    }
  }

  Future<Map<String, dynamic>> getCurrentLocation() async {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return {"lat": pos.latitude, "lng": pos.longitude};
  }

  Future<void> checkInOut(String type) async {
    setState(() => loading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    String? base64Image;
    if (kIsWeb) {
      if (_webImageFile != null) {
        final bytes = await _webImageFile!.readAsBytes();
        base64Image = base64Encode(bytes);
      } else if (_webImageDataUrl != null) {
        base64Image = _webImageDataUrl!.split(',').last;
      }
    } else if (_imageFile != null) {
      final bytes = await _imageFile!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final loc = await getCurrentLocation();

    final uri = Uri.parse("${ApiConfig.baseUrl}/attendance/$type");
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = "Bearer $token";
    request.headers['Accept'] = "application/json";

    if (!kIsWeb && _imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('photo', _imageFile!.path),
      );
    } else if (base64Image != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          base64Decode(base64Image),
          filename: 'photo.jpg',
        ),
      );
    }

    request.fields['lat'] = loc['lat'].toString();
    request.fields['lng'] = loc['lng'].toString();

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    setState(() => loading = false);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$type berhasil")));
    } else {
      final data = jsonDecode(resBody);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(data['message'] ?? "Gagal $type")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Absensi")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            Center(
              child: _imageFile != null
                  ? Image.file(_imageFile!, height: 150)
                  : _webImageDataUrl != null
                  ? Image.network(_webImageDataUrl!, height: 150)
                  : Icon(Icons.camera_alt, size: 150),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(fromCamera: true),
                    icon: Icon(Icons.camera_alt),
                    label: Text("Ambil Foto"),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => pickImage(fromCamera: false),
                    icon: Icon(Icons.upload_file),
                    label: Text("Upload Foto"),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => checkInOut('checkIn'),
              child: loading ? CircularProgressIndicator() : Text("Check-in"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => checkInOut('checkOut'),
              child: loading ? CircularProgressIndicator() : Text("Check-out"),
            ),
          ],
        ),
      ),
    );
  }
}
