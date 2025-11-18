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

  Future<void> login() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password harus diisi')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/login");

      print('Mengirim login request ke: $url');
      print('Email: ${emailC.text.trim()}');

      final response = await http.post(
        url,
        body: {
          "email": emailC.text.trim(), 
          "password": passC.text.trim()
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (!mounted) return;
      setState(() => loading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data["user"];

        // Debug: print structure of response
        print('Data keys: ${data.keys}');
        print('User keys: ${user.keys}');

        SharedPreferences prefs = await SharedPreferences.getInstance();

        // ✅ PERBAIKAN: Gunakan "token" bukan "token"
        String? token = data["token"];
        if (token == null) {
          // Coba alternatif key names
          token = data["access_token"] ?? data["auth_token"] ?? data["token"];
        }

        if (token == null) {
          throw Exception('Token tidak ditemukan dalam response');
        }

        print('Token yang disimpan: ${token.substring(0, 20)}...');

        await prefs.setString("token", token); // ✅ Key yang benar
        await prefs.setInt("role_id", user["role_id"]);
        await prefs.setInt("division_id", user["division_id"] ?? 0);
        await prefs.setInt("user_id", user["id"]);
        await prefs.setString("user_name", user["name"]);
        await prefs.setString("user_email", user["email"]);

        int roleId = user["role_id"];
        int divId = user["division_id"] ?? 0;

        print('Login berhasil - Role: $roleId, Division: $divId');

        if (roleId == 1) {
          if (divId == 1) {
            Navigator.pushReplacementNamed(context, "/dashboard_finance");
          } else if (divId == 2) {
            Navigator.pushReplacementNamed(context, "/dashboard_apo");
          } else if (divId == 3) {
            Navigator.pushReplacementNamed(context, "/dashboard_frontdesk");
          } else if (divId == 4) {
            Navigator.pushReplacementNamed(context, "/dashboard_onsite");
          } else {
            // Default untuk admin tanpa division spesifik
            Navigator.pushReplacementNamed(context, "/dashboard_user");
          }
        } else if (roleId == 2) {
          Navigator.pushReplacementNamed(context, "/dashboard_user");
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Role tidak dikenali!")),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorData["message"] ?? "Email atau password salah!"
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Absensi Karyawan"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
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
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passC,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
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
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(fontSize: 18, color: Colors.white),
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