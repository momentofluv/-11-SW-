// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000/'; // Django 서버 URL
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Successful response
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw const FormatException('Failed to decode JSON');
      }
    } else {
      // Handle error response
      throw Exception('Failed to load data: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> signup(
      String email, String password, String username) async {
    final response = await http.post(
      Uri.parse('${baseUrl}users/signup/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'username': username,
      }),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${baseUrl}users/login/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(response);
  }

  Future<void> logout(String refreshToken) async {
    await http.post(
      Uri.parse('${baseUrl}users/logout/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $refreshToken',
      },
      body: jsonEncode(<String, String>{
        'refresh': refreshToken,
      }),
    );
  }
}
