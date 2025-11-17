import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/auth/login_page.dart';

Widget buildDashboard({
  required BuildContext context,
  required String title,
  required List<Map<String, dynamic>> menu,
  Color? color,
  String? Name,
  String? userEmail,
  void Function(String title)? onMenuTap, // tambahkan callback opsional
}) {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  return Scaffold(
    key: _scaffoldKey,
    appBar: AppBar(
      title: Text(title),
      backgroundColor: Colors.blueAccent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
    ),
    drawer: Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Colors.blueAccent,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Name ?? "Nama Pengguna",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userEmail ?? "email@example.com",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...menu.map((item) {
                    return ListTile(
                      leading: Icon(item["icon"], color: Colors.blueAccent),
                      title: Text(item["title"]),
                      onTap: () {
                        Navigator.of(context).pop(); // tutup drawer
                        if (onMenuTap != null) {
                          onMenuTap(item["title"]); // panggil callback
                        } else if (item.containsKey("route")) {
                          Navigator.of(context).pushNamed(item["route"]);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Menu ${item["title"]} diklik"),
                            ),
                          );
                        }
                      },
                    );
                  }).toList(),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.person, color: Colors.blueAccent),
                    title: Text("Profil"),
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Navigasi ke Profil")),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.settings, color: Colors.blueAccent),
                    title: Text("Pengaturan"),
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Navigasi ke Pengaturan")),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.help, color: Colors.blueAccent),
                    title: Text("Bantuan"),
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Navigasi ke Bantuan")),
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.logout, color: Colors.redAccent),
                    title: Text("Logout"),
                    onTap: () async {
                      Navigator.of(context).pop();
                      bool confirm =
                          await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text("Konfirmasi Logout"),
                              content: Text("Apakah Anda yakin ingin logout?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text("Logout"),
                                ),
                              ],
                            ),
                          ) ??
                          false;
                      if (confirm) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.clear();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    body: Container(
      padding: EdgeInsets.all(16),
      color: color ?? Colors.grey[100],
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.dashboard, color: Colors.blueAccent, size: 30),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Selamat datang di Dashboard $title",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: menu.map((item) {
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      if (onMenuTap != null) {
                        onMenuTap(item["title"]); // panggil callback
                      } else if (item.containsKey("route")) {
                        Navigator.of(context).pushNamed(item["route"]);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Menu ${item["title"]} diklik"),
                          ),
                        );
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item["icon"], size: 50, color: Colors.blueAccent),
                        SizedBox(height: 10),
                        Text(
                          item["title"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
