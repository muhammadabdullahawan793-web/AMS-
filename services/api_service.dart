import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://abdullah.bugcreators.com/api";

  // 🔐 SIGNUP API
  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup.php"),
      body: {
        "full_name": fullName,
        "email": email,
        "password": password,
        "role": role,
      },
    );

    return jsonDecode(response.body);
  }

  // 🔐 LOGIN API
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      body: {"email": email, "password": password},
    );

    return jsonDecode(response.body);
  }
}
