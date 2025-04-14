import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import 'auth_controller.dart';

class SignUpController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  // Reactive inputs
  var username = ''.obs;
  var email = ''.obs;
  var password = ''.obs;
  var confirmPassword = ''.obs;

  @override
  void onInit() {
    super.onInit();
    reset();
    print('SignUpController initialized, errors reset');
  }

  void reset() {
    username.value = '';
    email.value = '';
    password.value = '';
    confirmPassword.value = '';
    authController.resetErrors();
  }

  void onUsernameChanged(String value) {
    username.value = value;
    authController.validateUsername(value);
  }

  void onEmailChanged(String value) {
    email.value = value;
    authController.validateEmail(value);
  }

  void onPasswordChanged(String value) {
    password.value = value;
    authController.validatePassword(value);
  }

  void onConfirmPasswordChanged(String value) {
    confirmPassword.value = value;
    authController.validateConfirmPassword(password.value, value);
  }

  void signUp() {
    final user = UserModel(
      id: '',
      username: username.value,
      email: email.value,
      role: 'user',
    );
    authController.signup(user, password.value, confirmPassword.value);
  }
}