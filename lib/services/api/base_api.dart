import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../storage_service.dart';
import 'package:flutter/foundation.dart';

abstract class BaseApi {


  static const String apiBaseUrl = kIsWeb ? 'http://localhost:8000/api':'http://192.168.251.76:8000/api';
  static const String imageBaseUrl =kIsWeb ? 'http://localhost:8000':'http://192.168.251.76:8000';
  static const String aiBaseUrl = kIsWeb ? 'http://localhost:8000': 'http://192.168.251.76:7000';  


  // Private StorageService instance
  final StorageService _storageService = Get.find<StorageService>();

  // Protected getter for StorageService
  @protected
  StorageService get storageService => _storageService;

  // Helper to handle HTTP responses
  @protected
  Future<dynamic> handleResponse(http.Response response, String action) async {
    print('$action response: ${response.statusCode} ${response.body}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      String errorMessage = '$action failed';
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (e) {
        errorMessage = '$action failed with status: ${response.statusCode}';
      }
      throw Exception(errorMessage);
    }
  }

  // Helper for protected POST requests
  @protected
  Future<Map<String, dynamic>> protectedPost(String url, Map<String, dynamic> body, String action) async {
    final token = storageService.getToken();
    if (token == null) {
      print('$action failed: No auth token found');
      throw Exception('Authentication token not found. Please log in again.');
    }
    print('Sending $action request to: $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    return await handleResponse(response, action) as Map<String, dynamic>;
  }

  // Helper to get auth headers
  @protected
  Future<Map<String, String>> getAuthHeaders() async {
    final token = storageService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in again.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}