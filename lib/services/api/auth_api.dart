import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/user_model.dart';
import 'base_api.dart';

class AuthApi extends BaseApi {
  Future<Map<String, dynamic>> signup(UserModel user, String password) async {
    print('Signup request: ${user.toJson()}, password: [hidden]');
    final response = await http.post(
      Uri.parse('${BaseApi.apiBaseUrl}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': user.username,
        'email': user.email.toLowerCase(),
        'password': password,
        'role': user.role,
      }),
    );
    return await handleResponse(response, 'Signup') as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    print('Verify OTP request: email: $email, otp: $otp');
    final response = await http.post(
      Uri.parse('${BaseApi.apiBaseUrl}/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.toLowerCase(),
        'otp': otp,
      }),
    );
    return await handleResponse(response, 'Verify OTP') as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> resendOTP(String email, String type) async {
    print('Resend OTP request: email: $email, type: $type');
    final response = await http.post(
      Uri.parse('${BaseApi.apiBaseUrl}/auth/resend-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.toLowerCase(),
        'type': type,
      }),
    );
    return await handleResponse(response, 'Resend OTP') as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> signin(String email, String password) async {
    print('Signin request: email: $email, password: [hidden]');
    final response = await http.post(
      Uri.parse('${BaseApi.apiBaseUrl}/auth/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.toLowerCase(),
        'password': password,
      }),
    );
    final data = await handleResponse(response, 'Signin') as Map<String, dynamic>;
    print('Signin response: $data');

    // Flatten _id in user object
    final userData = Map<String, dynamic>.from(data['user']);
    if (userData['_id'] is Map && userData['_id']['\$oid'] != null) {
      userData['_id'] = userData['_id']['\$oid'];
    }
    print('Processed user data: $userData');

    return {
      'user': userData,
      'token': data['token'],
    };
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    print('Request password reset: email: $email');
    final response = await http.post(
      Uri.parse('${BaseApi.apiBaseUrl}/auth/request-password-reset'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.toLowerCase(),
      }),
    );
    final data = await handleResponse(response, 'Request password reset') as Map<String, dynamic>;
    return {
      'status': data['status'] ?? 'success',
      'message': data['message'] ?? 'OTP sent successfully',
    };
  }

  Future<Map<String, dynamic>> verifyPasswordResetOTP(String email, String otp) async {
    print('Verify password reset OTP request: email: $email, otp: $otp');
    final response = await http.post(
      Uri.parse('${BaseApi.apiBaseUrl}/auth/verify-password-reset-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.toLowerCase(),
        'otp': otp,
      }),
    );
    final data = await handleResponse(response, 'Verify password reset OTP') as Map<String, dynamic>;
    return {
      'status': data['status'] ?? 'success',
      'resetToken': data['resetToken'],
      'message': data['message'] ?? 'OTP verified successfully',
    };
  }

  Future<Map<String, dynamic>> resetPassword(String resetToken, String newPassword, String confirmPassword) async {
    print('Reset password request: resetToken: [REDACTED], newPassword: [REDACTED], confirmPassword: [REDACTED]');
    final response = await http.post(
      Uri.parse('${BaseApi.apiBaseUrl}/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'resetToken': resetToken,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );
    final data = await handleResponse(response, 'Reset password') as Map<String, dynamic>;
    return {
      'status': data['status'] ?? 'success',
      'message': data['message'] ?? 'Password reset successfully',
    };
  }

  Future<Map<String, dynamic>> changePassword(String email, String currentPassword, String newPassword) async {
    print('Change password request: email: $email, currentPassword: [hidden], newPassword: [hidden]');
    final response = await protectedPost(
      '${BaseApi.apiBaseUrl}/auth/change-password',
      {
        'email': email.toLowerCase(),
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      'Change password',
    );
    return response;
  }

  Future<void> setSecurityQuestion(String email, String question, String answer) async {
    print('Set security question request: email: $email, question: $question');
    await protectedPost(
      '${BaseApi.apiBaseUrl}/auth/set-security-question',
      {
        'email': email.toLowerCase(),
        'question': question,
        'answer': answer,
      },
      'Set security question',
    );
  }

  Future<Map<String, dynamic>> verifySecurityAnswer(String email, String question, String answer) async {
    print('Verify security answer request: email: $email');
    final response = await http.post(
      Uri.parse('${BaseApi.apiBaseUrl}/auth/verify-security-answer'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.toLowerCase(),
        'question': question,
        'answer': answer,
      }),
    );
    return await handleResponse(response, 'Verify security answer') as Map<String, dynamic>;
  }

  Future<bool> refreshToken() async {
    print('Attempting to refresh token');
    final refreshToken = storageService.getRefreshToken();
    if (refreshToken == null) {
      print('No refresh token available');
      return false;
    }
    final response = await http.post(
      Uri.parse('${BaseApi.apiBaseUrl}/auth/refresh-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    print('Refresh token response: ${response.statusCode} ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newToken = data['accessToken'];
      final newRefreshToken = data['refreshToken'];
      await storageService.saveToken(newToken);
      if (newRefreshToken != null) {
        await storageService.saveRefreshToken(newRefreshToken);
      }
      print('Token refreshed successfully');
      return true;
    } else {
      await storageService.clear();
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> protectedPost(String url, Map<String, dynamic> data, String operation) async {
    print('protectedPost: url=$url, data=$data, operation=$operation');
    final token = storageService.getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(data),
    );
    return await handleResponse(response, operation) as Map<String, dynamic>;
  }
}