import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'auth_controller_callbacks.dart';
import 'auth_otp_manager.dart';
import 'auth_password_manager.dart';
import 'auth_security_manager.dart';
import 'auth_validation_mixin.dart';

class AuthController extends GetxController with AuthValidationMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  late final AuthOtpManager _otpManager;
  late final AuthPasswordManager _passwordManager;
  late final AuthSecurityManager _securityManager;

  final isLoading = false.obs;
  final isPasswordChangeSuccess = false.obs;

  @override
  var usernameError = ''.obs;
  @override
  var emailError = ''.obs;
  @override
  var passwordError = ''.obs;
  @override
  var confirmPasswordError = ''.obs;
  @override
  var currentPasswordError = ''.obs;
  @override
  var newPasswordError = ''.obs;
  @override
  var bioError = ''.obs;
  @override
  var securityQuestionError = ''.obs;
  @override
  var securityAnswerError = ''.obs;

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final securityQuestionTextController = TextEditingController();
  final securityAnswerTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final callbacks = AuthControllerCallbacks(
      setIsLoading: (value) => isLoading.value = value,
      showSnackbar: (title, message, {backgroundColor, colorText, snackPosition, borderRadius, margin}) {
        Get.snackbar(
          title,
          message,
          backgroundColor: backgroundColor ?? Get.theme.colorScheme.surfaceContainerHighest,
          colorText: colorText ?? Get.theme.colorScheme.onSurfaceVariant,
          snackPosition: snackPosition ?? SnackPosition.TOP,
          borderRadius: borderRadius ?? 8,
          margin: margin ?? const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 1500),
          isDismissible: true,
          animationDuration: const Duration(milliseconds: 300),
        );
      },
      navigateTo: (pageName, {arguments, id, preventDuplicates = true, parameters}) =>
          Get.toNamed(pageName, arguments: arguments, id: id, preventDuplicates: preventDuplicates, parameters: parameters),
      navigateOffAll: (pageName, {arguments, id, parameters}) =>
          Get.offAllNamed(pageName, arguments: arguments, id: id, parameters: parameters),
      resetPasswordErrors: resetPasswordErrors,
      updatePasswordChangeSuccess: (value) => isPasswordChangeSuccess.value = value,
      setCurrentPasswordError: (value) => currentPasswordError.value = value,
      setSecurityAnswerError: (value) => securityAnswerError.value = value,
    );

    _otpManager = AuthOtpManager(_apiService, _storageService, callbacks);
    _passwordManager = AuthPasswordManager(_apiService, _storageService, callbacks);
    _securityManager = AuthSecurityManager(_apiService, _storageService, callbacks);
  }

  @override
  void onClose() {
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    securityQuestionTextController.dispose();
    securityAnswerTextController.dispose();
    super.onClose();
  }

  void resetAllFields() {
    emailController.clear();
    usernameController.clear();
    passwordController.clear();
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    securityQuestionTextController.clear();
    securityAnswerTextController.clear();
  }

  void resetErrors() {
    usernameError.value = '';
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
    currentPasswordError.value = '';
    newPasswordError.value = '';
    bioError.value = '';
    securityQuestionError.value = '';
    securityAnswerError.value = '';
  }

  void resetPasswordErrors() {
    currentPasswordError.value = '';
    newPasswordError.value = '';
    confirmPasswordError.value = '';
  }

  @override
  void validateSecurityAnswer(String value) {
    final sanitizedValue = value.replaceAll(RegExp(r'[<>]'), '');
    securityAnswerError.value = sanitizedValue.isEmpty ? 'please_enter_answer'.tr : '';
    if (sanitizedValue != value) {
      securityAnswerTextController.text = sanitizedValue;
      securityAnswerTextController.selection = TextSelection.fromPosition(
        TextPosition(offset: sanitizedValue.length),
      );
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
      await _apiService.auth.signup(
        UserModel(
          id: user.id,
          username: user.username,
          email: user.email.toLowerCase(),
          role: user.role,
        ),
        password,
      );

      Get.snackbar('success'.tr, 'otp_sent_to_email'.tr,
          backgroundColor: Get.theme.colorScheme.secondary, colorText: Get.theme.colorScheme.onSecondary);
      Get.toNamed(AppRoutes.getVerifyOTPPage(), arguments: {
        'email': user.email.toLowerCase(),
        'user': user,
        'password': password,
        'type': 'signup',
      });
    } catch (e) {
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signin(String email, String password) async {
    validateEmail(email);
    validatePassword(password);

    if (emailError.value.isNotEmpty || passwordError.value.isNotEmpty) {
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.auth.signin(email.toLowerCase(), password);
      await _storageService.saveUser(response['user']);
      await _storageService.saveToken(response['token']);

      Get.snackbar('success'.tr, 'logged_in_successfully'.tr,
          backgroundColor: Get.theme.colorScheme.secondary,
          colorText: Get.theme.colorScheme.onSecondary,
          duration: const Duration(milliseconds: 1500));

      resetAllFields();
      resetErrors();

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.getHomePage(), arguments: {'fromSignIn': true});
    } catch (e) {
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
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

  Future<void> verifyOTP(String email, String otp) async {
    await _otpManager.verifyOTP(email, otp);
  }

  Future<void> resendOTP(String email, String type) async {
    await _otpManager.resendOTP(email, type);
  }

  Future<void> requestPasswordReset(String email) async {
    validateEmail(email);
    if (emailError.value.isNotEmpty) {
      return;
    }
    await _passwordManager.requestPasswordReset(email);
  }

  Future<void> verifyPasswordResetOTP(String email, String otp) async {
    final resetToken = await _passwordManager.verifyPasswordResetOTP(email, otp);
    if (resetToken != null) {
      Get.toNamed(AppRoutes.getResetPasswordPage(), arguments: {
        'resetToken': resetToken,
        'email': email,
      });
    }
  }

  Future<void> resetPassword(String resetToken, String newPassword, String confirmPassword) async {
    resetPasswordErrors();
    validateNewPassword(newPassword);
    validateConfirmPassword(newPassword, confirmPassword);

    if (newPasswordError.value.isNotEmpty || confirmPasswordError.value.isNotEmpty) {
      return;
    }
    await _passwordManager.resetPassword(resetToken, newPassword, confirmPassword);
  }

  Future<void> changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmNewPassword = confirmPasswordController.text.trim();

    resetPasswordErrors();
    validateCurrentPassword(currentPassword);
    validateNewPassword(newPassword);
    validateConfirmPassword(newPassword, confirmNewPassword);

    if (newPassword.isNotEmpty && currentPassword == newPassword && newPasswordError.value.isEmpty) {
      newPasswordError.value = 'new_password_same_as_current'.tr;
    }

    if (currentPasswordError.value.isNotEmpty ||
        newPasswordError.value.isNotEmpty ||
        confirmPasswordError.value.isNotEmpty) {
      return;
    }

    try {
      final user = _storageService.getUser();
      if (user == null || user['email'] == null) {
        throw Exception('user_email_not_found');
      }
      final userEmail = user['email'].toString().trim();
      await _passwordManager.changePassword(currentPassword, newPassword, userEmail);

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    }
  }

  Future<void> setSecurityQuestion(String question, String answer) async {
    validateSecurityQuestion(question);
    validateSecurityAnswer(answer);

    if (securityQuestionError.value.isNotEmpty || securityAnswerError.value.isNotEmpty) {
      return;
    }

    try {
      final user = _storageService.getUser();
      if (user == null || user['email'] == null) {
        throw Exception('user_email_not_found'.tr);
      }
      final userEmail = user['email'];
      await _securityManager.setSecurityQuestion(userEmail, question, answer);
    } catch (e) {
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    }
  }

  Future<void> verifySecurityAnswer(String email, String question, String answer, Function(String) onSuccess) async {
    validateSecurityQuestion(question);
    validateSecurityAnswer(answer);

    if (securityQuestionError.value.isNotEmpty || securityAnswerError.value.isNotEmpty) {
      return;
    }

    final resetToken = await _securityManager.verifySecurityAnswer(email, question, answer);
    if (resetToken != null) {
      onSuccess(resetToken);
    }
  }
}