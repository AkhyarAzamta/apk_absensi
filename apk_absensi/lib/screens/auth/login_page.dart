import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:apk_absensi/config/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  bool loading = false;
  bool _obscureText = true;

  // Mapping untuk role dan division
  int _mapRoleToId(String role) {
    switch (role) {
      case 'SUPER_ADMIN':
        return 1;
      case 'USER':
        return 2;
      default:
        return 2;
    }
  }

  int _mapDivisionToId(String division) {
    switch (division) {
      case 'FINANCE':
        return 1;
      case 'APO':
        return 2;
      case 'FRONT_DESK':
        return 3;
      case 'ONSITE':
        return 4;
      default:
        return 0;
    }
  }

  Future<void> login() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password harus diisi')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/auth/login");

      print('Mengirim login request ke: $url');
      print('Email: ${emailC.text.trim()}');

      final response = await http.post(
        url,
        body: {"email": emailC.text.trim(), "password": passC.text.trim()},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (!mounted) return;
      setState(() => loading = false);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Debug: print structure of response
        print('Response keys: ${responseData.keys}');

        if (responseData['success'] == true) {
          final data = responseData['data'];
          print('Data keys: ${data.keys}');

          final user = data['user'];
          print('User data: $user');

          // ✅ PERBAIKAN: Ambil token dari data, bukan langsung dari response
          String? token = data["token"];
          if (token == null) {
            // Coba alternatif key names
            token = data["access_token"] ?? data["auth_token"];
          }

          if (token == null) {
            throw Exception('Token tidak ditemukan dalam response');
          }

          print('Token yang disimpan: ${token.substring(0, 20)}...');

          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString("token", token);

          // ✅ PERBAIKAN: Gunakan mapping untuk role dan division
          int roleId = _mapRoleToId(user["role"]);
          int divId = _mapDivisionToId(user["division"]);

          await prefs.setInt("role_id", roleId);
          await prefs.setInt("division_id", divId);
          await prefs.setInt("user_id", user["id"]);
          await prefs.setString("user_name", user["name"]);
          await prefs.setString("user_email", user["email"]);
          await prefs.setString("employee_id", user["employeeId"] ?? "");
          await prefs.setString("position", user["position"] ?? "");
          await prefs.setString("division", user["division"] ?? "");

          print('Login berhasil - Role: $roleId, Division: $divId');

          // Navigasi berdasarkan role dan division
          if (roleId == 1) {
            // SUPER_ADMIN
            switch (roleId) {
              case 1: // FINANCE
                Navigator.pushReplacementNamed(context, "/dashboard_finance");
                break;
              case 2: // APO
                Navigator.pushReplacementNamed(context, "/dashboard_apo");
                break;
              case 3: // FRONT_DESK
                Navigator.pushReplacementNamed(context, "/dashboard_frontdesk");
                break;
              case 4: // ONSITE
                Navigator.pushReplacementNamed(context, "/dashboard_onsite");
                break;
              default:
                Navigator.pushReplacementNamed(context, "/dashboard_user");
            }
          } else {
            // USER atau role lainnya
            Navigator.pushReplacementNamed(context, "/dashboard_user");
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData["message"] ?? "Login gagal!")),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData["message"] ?? "Email atau password salah!"),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      print('Error during login: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Absensi Karyawan"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Login",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailC,
                    decoration: InputDecoration(
                      labelText: "Email",
                      hintText: "masukkan email anda",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passC,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: "Password",
                      hintText: "masukkan password anda",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Fitur lupa password belum tersedia"),
                        ),
                      );
                    },
                    child: const Text(
                      "Lupa Password?",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
