import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_api.dart';

class FeedbackApi extends BaseApi {
  Future<void> submitFeedback(String feedbackText) async {
    print('Submitting feedback');
    final token = await storageService.getToken();
    if (token == null) {
      print('Submit feedback failed: No auth token found');
      throw Exception('Authentication token not found. Please log in again.');
    }
    final user = await storageService.getUser();
    if (user == null || user['email'] == null) {
      print('Submit feedback failed: No user email found');
      throw Exception('User email not found. Please log in again.');
    }
    final userEmail = user['email'] as String;
    final response = await http.post(
      Uri.parse('${BaseApi.apiBaseUrl}/feedback'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': userEmail.toLowerCase(),
        'feedback': feedbackText,
      }),
    );
    await handleResponse(response, 'Submit feedback');
  }
}