import 'package:flutter/material.dart';

class ValidasiGpsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  ValidasiGpsPage(this.data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Validasi GPS")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Koordinat Kantor",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text("Latitude : ${data["office_lat"] ?? "-"}"),
                Text("Longitude: ${data["office_lng"] ?? "-"}"),
                SizedBox(height: 20),
                Text(
                  "Radius Validasi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text("${data["radius_meters"] ?? 0} meter"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
