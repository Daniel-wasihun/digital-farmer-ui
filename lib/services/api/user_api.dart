import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'base_api.dart';

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
    File? profilePicture,
  ) async {
    print('Update profile request: email: $email, username: $username, bio: $bio');
    final token = await storageService.getToken();
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
      String extension = path.extension(profilePicture.path).toLowerCase();
      const imageMimeTypes = {
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
      String? mimeType = imageMimeTypes[extension];
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

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    print('Update profile response: status=${response.statusCode}, body=$responseBody');

    if (response.statusCode == 200) {
      return jsonDecode(responseBody)['user'];
    } else {
      String errorMessage = 'update_failed'.tr;
      try {
        var errorJson = jsonDecode(responseBody);
        errorMessage = errorJson['message'] ?? errorMessage;
      } catch (e) {
        errorMessage = 'Update failed with status: ${response.statusCode}';
      }
      throw Exception(errorMessage);
    }
  }
}