import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'base_api.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserApi extends BaseApi {
  Future<List<Map<String, dynamic>>> getUsers() async {
    print('Fetching users...');
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('${BaseApi.apiBaseUrl}/users'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));
    final data = await handleResponse(response, 'Get users');
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    } else {
      print('Get users: Expected List, got ${data.runtimeType}');
      return [];
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    String email,
    String username,
    String? bio,
    dynamic profilePicture, // Can be File or Uint8List
    String? imageName, // Optional: Provide the image name for web
    MediaType? contentType, // Added for proper MIME type
  ) async {
    print('Update profile request: email: $email, username: $username, bio: $bio, imageType: ${profilePicture.runtimeType}, imageName: $imageName, contentType: $contentType');
    final token = storageService.getToken();
    if (token == null) {
      print('Update profile failed: No auth token found');
      throw Exception('Authentication token not found. Please log in again.');
    }

    var uri = Uri.parse('${BaseApi.apiBaseUrl}/update-profile');
    var request = http.MultipartRequest('POST', uri)..headers['Authorization'] = 'Bearer $token';

    request.fields['email'] = email.toLowerCase();
    request.fields['username'] = username.trim();
    if (bio != null) request.fields['bio'] = bio;

    if (profilePicture != null) {
      if (profilePicture is File) {
        String extension = path.extension(profilePicture.path).toLowerCase().replaceAll('.', '');
        const imageMimeTypes = {
          'jpg': 'image/jpeg',
          'jpeg': 'image/jpeg',
          'png': 'image/png',
          'gif': 'image/gif',
          'bmp': 'image/bmp',
          'webp': 'image/webp',
        };
        String? mimeType = imageMimeTypes[extension] ?? 'application/octet-stream';
        var multipartFile = await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
          contentType: contentType ?? MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
        print('Uploading file (mobile): ${profilePicture.path}, type: $mimeType, size: ${await profilePicture.length()} bytes');
      } else if (profilePicture is Uint8List && imageName != null) {
        String extension = path.extension(imageName).toLowerCase().replaceAll('.', '');
        const imageMimeTypes = {
          'jpg': 'image/jpeg',
          'jpeg': 'image/jpeg',
          'png': 'image/png',
          'gif': 'image/gif',
          'bmp': 'image/bmp',
          'webp': 'image/webp',
        };
        String? mimeType = imageMimeTypes[extension] ?? 'application/octet-stream';
        var multipartFile = http.MultipartFile.fromBytes(
          'profilePicture',
          profilePicture,
          filename: imageName,
          contentType: contentType ?? MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
        print('Uploading bytes (web): $imageName, type: $mimeType, size: ${profilePicture.length} bytes');
      } else {
        print('Unsupported profile picture type or missing name: ${profilePicture.runtimeType}, imageName: $imageName');
        throw Exception('Invalid image input: Unsupported type or missing filename');
      }
    }

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    print('Update profile response: status=${response.statusCode}, body=$responseBody');

    if (response.statusCode == 200) {
      return jsonDecode(responseBody)['user'];
    } else {
      String errorMessage = 'Update failed';
      try {
        var errorJson = jsonDecode(responseBody);
        errorMessage = errorJson['message'] ?? errorMessage;
        print('Error details: $errorJson');
      } catch (e) {
        errorMessage = 'Update failed with status: ${response.statusCode}, body: $responseBody';
      }
      throw Exception(errorMessage);
    }
  }
}