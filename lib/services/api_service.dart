import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'storage_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api'; // Update with your backend URL
  final StorageService _storageService = Get.find<StorageService>();
  Future<Map<String, dynamic>> signup(UserModel user, String password) async {
    print('Signup request: ${user.toJson()}, password: [hidden]');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': user.username,
        'email': user.email.toLowerCase(),
        'password': password,
        'role': user.role,
      }),
    );

    print('Signup response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Signup failed');
    }
  }

  Future<Map<String, dynamic>> signin(String email, String password) async {
    print('Signin request: email: $email, password: [hidden]');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.toLowerCase(),
        'password': password,
      }),
    );

    print('Signin response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Signin failed');
    }
  }


Future<void> changePassword(String email, String currentPassword, String newPassword) async {
    try {
      final token = _storageService.getToken();
      final url = '$baseUrl/auth/change-password';
      print('Sending change password request to: $url with email: $email');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('API call successful: Password changed');
        return; // Success
      } else {
        String errorMessage = 'Failed to change password';
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? errorMessage;
        } catch (e) {
          print('Failed to parse response: $e');
          errorMessage = 'Invalid server response: ${response.body}';
        }
        print('API error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Change password API error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<Map<String, dynamic>> updateProfile(
      String email, String username, String? bio, String? profilePicture) async {
    // Simulate API call
    final response = await http.post(
      Uri.parse('$baseUrl/auth/update-profile'),
      body: {
        'email': email,
        'username': username,
        'bio': bio ?? '',
        'profilePicture': profilePicture ?? '',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['user'];
    }
    throw Exception('Failed to update profile');
  }

  Future<void> setSecurityQuestion(String email, String question, String answer) async {
    // Simulate API call
    final response = await http.post(
      Uri.parse('$baseUrl/set-security-question'),
      body: {
        'email': email,
        'question': question,
        'answer': answer,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to set security question');
    }
  }

}