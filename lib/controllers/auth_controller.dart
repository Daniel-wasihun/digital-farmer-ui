import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = Get.find<StorageService>();

  var isLoading = false.obs;
  var usernameError = ''.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs;
  var confirmPasswordError = ''.obs;

  void toggleLanguage() {
    if (Get.locale == const Locale('en', 'US')) {
      Get.updateLocale(const Locale('am', 'ET'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }

  void validateUsername(String value) {
    if (value.isEmpty) {
      usernameError.value = 'username_required'.tr;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      usernameError.value = 'username_invalid'.tr;
    } else {
      usernameError.value = '';
    }
  }

  void validateEmail(String value) {
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
    if (value.isEmpty) {
      passwordError.value = 'password_required'.tr;
    } else if (value.length < 6) {
      passwordError.value = 'password_too_short'.tr;
    } else {
      passwordError.value = '';
    }
  }

  void validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = 'confirm_password_required'.tr;
    } else if (confirmPassword != password) {
      confirmPasswordError.value = 'passwords_do_not_match'.tr;
    } else {
      confirmPasswordError.value = '';
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
      Get.offNamed('/signin');
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
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed('/home');
    } catch (e) {
      print('Signin failed: $e');
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _storageService.clear();
    Get.offAllNamed('/signin');
  }

  bool isLoggedIn() {
    return _storageService.getToken() != null;
  }
}