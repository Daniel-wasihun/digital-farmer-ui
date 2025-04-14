import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
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
    String email,
    String username,
    String? bio,
    File? profilePicture,
  ) async {
    try {
      var uri = Uri.parse('$baseUrl/auth/update-profile'); // Fixed endpoint
      var request = http.MultipartRequest('POST', uri);

      // Add fields
      request.fields['email'] = email;
      request.fields['username'] = username;
      if (bio != null) request.fields['bio'] = bio;

      // Add file
      if (profilePicture != null) {
        String extension = path.extension(profilePicture.path).toLowerCase();
        String mimeType = 'image/jpeg'; // Default
        if (extension == '.png') mimeType = 'image/png';
        else if (extension == '.jpg' || extension == '.jpeg') mimeType = 'image/jpeg';
        else {
          print('Unsupported file extension: $extension');
          throw Exception('unsupported_image_format'.tr);
        }

        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
          contentType: MediaType.parse(mimeType),
        ));
        print('Uploading file: ${profilePicture.path}, type: $mimeType');
      }

      print('Sending update profile request: email=$email, username=$username');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var json = jsonDecode(responseBody);
        print('Profile updated: ${json['user']}');
        return json['user'];
      } else {
        print('Update profile failed: $responseBody');
        throw Exception(jsonDecode(responseBody)['message'] ?? 'update_failed'.tr);
      }
    } catch (e) {
      print('ApiService updateProfile error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
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