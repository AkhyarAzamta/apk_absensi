import 'package:flutter/material.dart';
import './jam_kerja_form_page.dart';

class JamKerjaPage extends StatelessWidget {
  final Map<String, dynamic> data;

  JamKerjaPage(this.data);

  Widget buildItem(String title, String? value) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value ?? "-"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Jam Kerja"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JamKerjaFormPage(existingData: data),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
