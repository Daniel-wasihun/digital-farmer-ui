import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../models/user_model.dart';
import 'storage_service.dart';

class ApiService {
  static const String apiBaseUrl = 'http://localhost:5000/api';
  static const String imageBaseUrl = 'http://localhost:5000';
  final StorageService _storageService = Get.find<StorageService>();

  Future<Map<String, dynamic>> signup(UserModel user, String password) async {
    print('Signup request: ${user.toJson()}, password: [hidden]');
    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/signup'),
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
      Uri.parse('$apiBaseUrl/auth/signin'),
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
      final url = '$apiBaseUrl/auth/change-password';
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
        return;
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

  static const Map<String, String> _imageMimeTypes = {
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.gif': 'image/gif',
    '.bmp': 'image/bmp',
    '.webp': 'image/webp',
    '.tiff': 'image/tiff',
    '.tif': 'image/tiff',
    '.heic': 'image/heic',
    '.heif': 'image/heif',
  };

  Future<Map<String, dynamic>> updateProfile(
    String email,
    String username,
    String? bio,
    File? profilePicture,
  ) async {
    try {
      var uri = Uri.parse('$apiBaseUrl/auth/update-profile');
      var request = http.MultipartRequest('POST', uri);

      request.fields['email'] = email;
      request.fields['username'] = username.trim();
      if (bio != null) request.fields['bio'] = bio;

      if (profilePicture != null) {
        String extension = path.extension(profilePicture.path).toLowerCase();
        String? mimeType = _imageMimeTypes[extension];

        if (mimeType == null) {
          print('Unsupported file extension: $extension');
          throw Exception('unsupported_image_format'.tr);
        }

        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
          contentType: MediaType.parse(mimeType),
        ));
        print('Uploading file: ${profilePicture.path}, type: $mimeType, size: ${await profilePicture.length()} bytes');
      }

      print('Sending update profile request: email=$email, username=${username.trim()}');
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Update profile response: status=${response.statusCode}, body=$responseBody');

      if (response.statusCode == 200) {
        var json = jsonDecode(responseBody);
        print('Profile updated: ${json['user']}');
        return json['user'];
      } else {
        var errorJson = jsonDecode(responseBody);
        String errorMessage = errorJson['message'] ?? 'update_failed'.tr;
        print('Update profile failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('ApiService updateProfile error: $e');
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> setSecurityQuestion(String email, String question, String answer) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/auth/set-security-question'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'question': question,
        'answer': answer,
      }),
    );
    if (response.statusCode == 200) {
      print('Security question set for: $email');
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to set security question');
    }
  }

  Future<List<dynamic>> getUsers() async {
    final token = _storageService.getToken();
    if (token == null) {
      print('ApiService: No token found');
      throw Exception('No token found');
    }
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/auth/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 5));
      print('Get users response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid token');
      } else if (response.statusCode == 500) {
        throw Exception('Server error');
      } else {
        throw Exception('Failed to fetch users: ${response.statusCode}');
      }
    } catch (e) {
      print('ApiService: Get users error: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(String userId1, String userId2) async {
    final token = _storageService.getToken();
    if (token == null) {
      print('ApiService: No token found');
      throw Exception('No token found');
    }
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/messages?userId1=$userId1&userId2=$userId2'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 5));
      print('Get messages response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is List ? data.cast<Map<String, dynamic>>() : [];
      } else if (response.statusCode == 401) {
        throw Exception('Invalid token');
      } else if (response.statusCode == 400) {
        throw Exception('Invalid user IDs');
      } else if (response.statusCode == 500) {
        throw Exception('Server error');
      } else {
        throw Exception('Failed to fetch messages: ${response.statusCode}');
      }
    } catch (e) {
      print('ApiService: Get messages error: $e');
      rethrow;
    }
  }

  Future<bool> refreshToken() async {
    final refreshToken = _storageService.getRefreshToken();
    if (refreshToken == null) {
      print('ApiService: No refresh token available');
      return false;
    }
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      print('Refresh token response: ${response.statusCode} ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];
        _storageService.saveToken(newToken);
        if (newRefreshToken != null) {
          _storageService.saveRefreshToken(newRefreshToken);
        }
        print('ApiService: Token refreshed successfully');
        return true;
      } else {
        print('ApiService: Token refresh failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('ApiService: Token refresh error: $e');
      return false;
    }
  }
}