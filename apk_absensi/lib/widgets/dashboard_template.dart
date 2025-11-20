import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apk_absensi/screens/auth/login_page.dart';
import 'package:apk_absensi/screens/users/profile/profile_page.dart';

Widget buildDashboard({
  required BuildContext context,
  required String title,
  required List<Map<String, dynamic>> menu,
  Color? color,
  String? Name, // Tetap gunakan Name dengan kapital untuk kompatibilitas
  String? userEmail,
  void Function(String title)? onMenuTap,
}) {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  return Scaffold(
    key: _scaffoldKey,
    appBar: AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.greenAccent[700],
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
    ),
    drawer: _buildDrawer(
      context: context,
      name: Name, // Tetap kompatibel dengan parameter Name
      userEmail: userEmail,
      menu: menu,
      onMenuTap: onMenuTap,
    ),
    body: _buildBody(
      context: context,
      title: title,
      menu: menu,
      color: color,
      onMenuTap: onMenuTap,
    ),
  );
}

Widget _buildDrawer({
  required BuildContext context,
  required String? name,
  required String? userEmail,
  required List<Map<String, dynamic>> menu,
  required void Function(String title)? onMenuTap,
}) {
  return Drawer(
    child: Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header Drawer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.greenAccent[700],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.greenAccent,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name ?? "Nama Pengguna",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail ?? "email@example.com",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Menu List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Menu utama dari parameter
                ...menu.map((item) {
                  return ListTile(
                    leading: Icon(
                      item["icon"],
                      color: Colors.greenAccent[700],
                    ),
                    title: Text(
                      item["title"],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(); // Tutup drawer
                      if (onMenuTap != null) {
                        onMenuTap(item["title"]);
                      } else if (item.containsKey("route")) {
                        Navigator.of(context).pushNamed(item["route"]);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Menu ${item["title"]} diklik"),
                            backgroundColor: Colors.greenAccent[700],
                          ),
                        );
                      }
                    },
                  );
                }).toList(),

                const Divider(thickness: 1),

                // Menu Profil dengan navigasi ke ProfilePage
                ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.greenAccent[700],
                  ),
                  title: const Text(
                    "Profil",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(); // Tutup drawer
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Colors.greenAccent[700],
                  ),
                  title: const Text(
                    "Pengaturan",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Navigasi ke Pengaturan"),
                        backgroundColor: Colors.blueAccent,
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: Icon(
                    Icons.help_outline,
                    color: Colors.greenAccent[700],
                  ),
                  title: const Text(
                    "Bantuan",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Navigasi ke Bantuan"),
                        backgroundColor: Colors.orangeAccent,
                      ),
                    );
                  },
                ),

                const Divider(thickness: 1),

                // Logout
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    "Logout",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _showLogoutConfirmation(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBody({
  required BuildContext context,
  required String title,
  required List<Map<String, dynamic>> menu,
  required Color? color,
  required void Function(String title)? onMenuTap,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    color: color ?? Colors.grey[100],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Colors.greenAccent[700],
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selamat Datang",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Akses menu $title dengan mudah",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Grid Menu
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.9,
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
                      onMenuTap(item["title"]);
                    } else if (item.containsKey("route")) {
                      Navigator.of(context).pushNamed(item["route"]);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Menu ${item["title"]} diklik"),
                          backgroundColor: Colors.greenAccent[700],
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent[700]?.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item["icon"],
                            size: 32,
                            color: Colors.greenAccent[700],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item["title"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    ),
  );
}

Future<void> _showLogoutConfirmation(BuildContext context) async {
  bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            "Konfirmasi Logout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text("Apakah Anda yakin ingin logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ) ??
      false;

  if (confirm) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logout berhasil"),
        backgroundColor: Colors.green,
      ),
    );
  }
}