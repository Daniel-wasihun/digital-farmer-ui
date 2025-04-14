import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = Get.find<StorageService>();

  var isLoading = false.obs;
  var usernameError = ''.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs;
  var confirmPasswordError = ''.obs;
  var currentPasswordError = ''.obs;
  var newPasswordError = ''.obs;
  var bioError = ''.obs;
  var securityQuestionError = ''.obs;
  var securityAnswerError = ''.obs;

  void resetErrors() {
    print('Resetting all validation errors');
    usernameError.value = '';
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
    currentPasswordError.value = '';
    newPasswordError.value = '';
    bioError.value = '';
    securityQuestionError.value = '';
    securityAnswerError.value = '';
    isLoading.value = false;
  }

  void toggleLanguage() {
    if (Get.locale == const Locale('en', 'US')) {
      Get.updateLocale(const Locale('am', 'ET'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }

  void validateUsername(String value) {
    print('Validating username: $value');
    if (value.isEmpty) {
      usernameError.value = 'username_required'.tr;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      usernameError.value = 'username_invalid'.tr;
    } else {
      usernameError.value = '';
    }
  }

  void validateEmail(String value) {
    print('Validating email: $value');
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (value.isEmpty) {
      emailError.value = 'email_required'.tr;
    } else if (!emailRegex.hasMatch(value.toLowerCase())) {
      emailError.value = 'email_invalid'.tr;
    } else {
      emailError.value = '';
    }
  }

  void validatePassword(String value) {
    print('Validating password: ${value.isEmpty ? "empty" : "non-empty"}');
    if (value.isEmpty) {
      passwordError.value = 'password_required'.tr;
    } else if (value.length < 6) {
      passwordError.value = 'password_too_short'.tr;
    } else {
      passwordError.value = '';
    }
  }

  void validateConfirmPassword(String password, String confirmPassword) {
    print('Validating confirm password: ${confirmPassword.isEmpty ? "empty" : "non-empty"}');
    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = 'confirm_password_required'.tr;
    } else if (confirmPassword != password) {
      confirmPasswordError.value = 'passwords_do_not_match'.tr;
    } else {
      confirmPasswordError.value = '';
    }
  }

  void validateCurrentPassword(String value) {
    if (value.isEmpty) {
      currentPasswordError.value = 'current_password_required'.tr;
    } else {
      currentPasswordError.value = '';
    }
  }

  void validateNewPassword(String value) {
    if (value.isEmpty) {
      newPasswordError.value = 'new_password_required'.tr;
    } else if (value.length < 6) {
      newPasswordError.value = 'password_too_short'.tr;
    } else {
      newPasswordError.value = '';
    }
  }

  void validateBio(String value) {
    if (value.length > 150) {
      bioError.value = 'bio_too_long'.tr;
    } else {
      bioError.value = '';
    }
  }

  void validateSecurityQuestion(String value) {
    if (value.isEmpty) {
      securityQuestionError.value = 'security_question_required'.tr;
    } else {
      securityQuestionError.value = '';
    }
  }

  void validateSecurityAnswer(String value) {
    if (value.isEmpty) {
      securityAnswerError.value = 'security_answer_required'.tr;
    } else {
      securityAnswerError.value = '';
    }
  }

  Future<void> signup(UserModel user, String password, String confirmPassword) async {
    validateUsername(user.username);
    validateEmail(user.email);
    validatePassword(password);
    validateConfirmPassword(password, confirmPassword);

    if (usernameError.value.isNotEmpty ||
        emailError.value.isNotEmpty ||
        passwordError.value.isNotEmpty ||
        confirmPasswordError.value.isNotEmpty) {
      print('Signup validation failed: usernameError=${usernameError.value}, emailError=${emailError.value}, passwordError=${passwordError.value}, confirmPasswordError=${confirmPasswordError.value}');
      return;
    }

    try {
      isLoading.value = true;
      print('Attempting signup for: ${user.email}');
      final response = await _apiService.signup(
        UserModel(
          id: user.id,
          username: user.username,
          email: user.email.toLowerCase(),
          role: user.role,
        ),
        password,
      );
      await _storageService.saveUser(response['user']);
      await _storageService.saveToken(response['token']);
      Get.snackbar('success'.tr, 'account_created_successfully'.tr,
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offNamed(AppRoutes.getSignInPage());
    } catch (e) {
      print('Signup failed: $e');
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signin(String email, String password) async {
    validateEmail(email);
    validatePassword(password);
    if (emailError.value.isNotEmpty || passwordError.value.isNotEmpty) {
      print('Signin validation failed: emailError=${emailError.value}, passwordError=${passwordError.value}');
      return;
    }

    try {
      isLoading.value = true;
      print('Attempting signin for: $email');
      final response = await _apiService.signin(email.toLowerCase(), password);
      print('Signin response: $response');
      await _storageService.saveUser(response['user']);
      await _storageService.saveToken(response['token']);
      Get.snackbar('success'.tr, 'logged_in_successfully'.tr,
          backgroundColor: Colors.greenAccent, colorText: Colors.white);
      Get.offAllNamed(AppRoutes.getHomePage());
    } catch (e) {
      print('Signin failed: $e');
      Get.snackbar('error'.tr, e.toString().tr.replaceFirst('Exception: ', ''),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword, String confirmNewPassword) async {
    print('changePassword called with current: ${currentPassword.isEmpty ? "empty" : "non-empty"}, new: ${newPassword.isEmpty ? "empty" : "non-empty"}, confirm: ${confirmNewPassword.isEmpty ? "empty" : "non-empty"}');
    
    validateCurrentPassword(currentPassword);
    validateNewPassword(newPassword);
    validateConfirmPassword(newPassword, confirmNewPassword);

    if (currentPassword == newPassword && currentPassword.isNotEmpty) {
      print('Validation failed: New password is same as current password');
      newPasswordError.value = 'new_password_same_as_current'.tr;
    }

    if (currentPasswordError.value.isNotEmpty ||
        newPasswordError.value.isNotEmpty ||
        confirmPasswordError.value.isNotEmpty) {
      print('Validation failed: current=${currentPasswordError.value}, new=${newPasswordError.value}, confirm=${confirmPasswordError.value}');
      return;
    }

    try {
      isLoading.value = true;
      print('Fetching user from StorageService');
      final user = _storageService.getUser();
      if (user == null) {
        print('No user found in storage');
        throw Exception('user_not_found');
      }
      print('User found: ${user['email']}');
      print('Calling ApiService.changePassword');
      await _apiService.changePassword(user['email'], currentPassword, newPassword);
      print('Password change successful, showing snackbar');
      Get.snackbar(
        'success'.tr,
        'password_changed_successfully'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        isDismissible: true,
      );
      print('Waiting for snackbar to display');
      await Future.delayed(const Duration(seconds: 3));
      print('Navigating back to SettingsTab');
      Get.back();
    } catch (e) {
      print('Change password error: $e');
      String errorMessage = 'generic_error'.tr;
      String rawError = e.toString().replaceFirst('Exception: ', '');
      if (rawError.contains('Current password is incorrect')) {
        errorMessage = 'current_password_incorrect'.tr;
      } else if (rawError.contains('User not found')) {
        errorMessage = 'user_not_found'.tr;
      } else if (rawError.contains('Server error')) {
        errorMessage = 'server_error'.tr;
      }
      Get.snackbar(
        'error'.tr,
        errorMessage,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        isDismissible: true,
      );
    } finally {
      print('Setting isLoading to false');
      isLoading.value = false;
    }
  }

  Future<void> setSecurityQuestion(String question, String answer) async {
    validateSecurityQuestion(question);
    validateSecurityAnswer(answer);

    if (securityQuestionError.value.isNotEmpty || securityAnswerError.value.isNotEmpty) {
      return;
    }

    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      if (user == null) {
        throw Exception('user_not_found'.tr);
      }
      await _apiService.setSecurityQuestion(user['email'], question, answer);
      Get.snackbar('success'.tr, 'security_question_updated'.tr,
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.back();
    } catch (e) {
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _storageService.clear();
    Get.offAllNamed(AppRoutes.getSignInPage());
  }

  bool isLoggedIn() {
    return _storageService.getToken() != null;
  }
      void resetPasswordErrors() {
    print('Resetting password error states');
    currentPasswordError.value = '';
    newPasswordError.value = '';
    confirmPasswordError.value = '';
    isLoading.value = false;
  }
}