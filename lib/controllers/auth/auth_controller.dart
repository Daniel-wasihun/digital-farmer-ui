import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../weather_controller.dart';
import 'auth_controller_callbacks.dart';
import 'auth_otp_manager.dart';
import 'auth_password_manager.dart';
import 'auth_security_manager.dart';
import 'auth_validation_mixin.dart';
import 'package:logger/logger.dart';

class AuthController extends GetxController with AuthValidationMixin {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final WeatherController _weatherController = Get.put(WeatherController());
  final logger = Logger();

  late final AuthOtpManager _otpManager;
  late final AuthPasswordManager _passwordManager;
  late final AuthSecurityManager _securityManager;

  final isLoading = false.obs;
  final isPasswordChangeSuccess = false.obs;
  final userName = ''.obs;
  final selectedQuestionKey = ''.obs; // Added to manage selected question state

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
      showSnackbar: (title, message, {backgroundColor, colorText, snackPosition, borderRadius, margin, duration}) {
        Get.snackbar(
          title,
          message,
          backgroundColor: backgroundColor ?? Get.theme.colorScheme.surfaceContainerHighest,
          colorText: colorText ?? Get.theme.colorScheme.onSurfaceVariant,
          snackPosition: snackPosition ?? SnackPosition.TOP,
          borderRadius: borderRadius ?? 8,
          margin: margin ?? const EdgeInsets.all(16),
          duration: duration ?? const Duration(milliseconds: 1500),
          isDismissible: true,
          animationDuration: const Duration(milliseconds: 300),
        );
      },
      navigateTo: (pageName, {arguments, id, preventDuplicates = true, parameters}) {
        logger.i('Navigating to: $pageName, arguments: $arguments');
        Get.toNamed(pageName, arguments: arguments, id: id, preventDuplicates: preventDuplicates, parameters: parameters);
        return null;
      },
      navigateOffAll: (pageName, {arguments, id, parameters}) {
        logger.i('Navigating off all to: $pageName, arguments: $arguments');
        Get.offAllNamed(pageName, arguments: arguments, id: id, parameters: parameters);
        return null;
      },
      resetPasswordErrors: resetPasswordErrors,
      updatePasswordChangeSuccess: (value) => isPasswordChangeSuccess.value = value,
      setCurrentPasswordError: (value) => currentPasswordError.value = value,
      setSecurityAnswerError: (value) => securityAnswerError.value = value,
    );

    _otpManager = AuthOtpManager(_apiService, _storageService, callbacks);
    _passwordManager = AuthPasswordManager(_apiService, _storageService, callbacks);
    _securityManager = AuthSecurityManager(_apiService, _storageService, callbacks);

    _loadUserName();
    clearSecurityFields(); // Initialize security fields
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

  void _loadUserName() {
    final user = _storageService.getUser();
    if (user != null && user['username'] != null) {
      userName.value = user['username'].toString();
      logger.i('AuthController: Loaded username: ${userName.value}');
    }
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
    selectedQuestionKey.value = ''; // Clear selected question
  }

  void clearSecurityFields() {
    selectedQuestionKey.value = '';
    securityQuestionError.value = '';
    securityAnswerTextController.clear();
    securityAnswerError.value = '';
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
  void validateSecurityQuestion(String? value) {
    securityQuestionError.value = value == null || value.isEmpty ? 'please_select_question'.tr : '';
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

      await _weatherController.storeUserLocation();

      Get.snackbar('success'.tr, 'otp_sent_to_email'.tr,
          backgroundColor: Get.theme.colorScheme.secondary,
          colorText: Get.theme.colorScheme.onSecondary,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(milliseconds: 1500));
      Get.toNamed(AppRoutes.getVerifyOTPPage(), arguments: {
        'email': user.email.toLowerCase(),
        'user': user,
        'password': password,
        'type': 'signup',
      });
    } catch (e) {
      logger.e('AuthController: Signup failed: $e');
      Get.snackbar('error'.tr, 'signup_failed'.tr,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(milliseconds: 1500));
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
      final userData = Map<String, dynamic>.from(response['user']);
      logger.i('AuthController: Signin userData: $userData');

      // Check admin status from role field
      final isAdmin = userData['role'] == 'admin';
      logger.i('AuthController: isAdmin: $isAdmin (role: ${userData['role']})');
      await _storageService.saveIsAdmin(isAdmin);

      // Save user data including role
      final userToSave = <String, dynamic>{
        ...userData,
        'role': userData['role'] ?? 'user', // Ensure role is included
      };
      await _storageService.saveUser(userToSave);
      logger.i('AuthController: Saved user: $userToSave');

      await _storageService.saveToken(response['token']);
      logger.i('AuthController: Saved token');

      userName.value = userData['username'] ?? '';
      logger.i('AuthController: Set userName: ${userName.value}');

      resetAllFields();
      resetErrors();

      // Navigate all users to home page, bypass middleware checks
      logger.i('AuthController: Navigating to home page for user: ${userName.value}, isAdmin: $isAdmin');
      Get.offAllNamed(
        AppRoutes.getHomePage(),
        arguments: {
          'fromSignIn': true,
          'bypassMiddleware': true, // Flag to skip admin checks
        },
      );

      _weatherController.storeUserLocation();
    } catch (e) {
      logger.e('AuthController: Signin failed: $e');
      Get.snackbar('error'.tr, 'signin_failed'.tr,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(milliseconds: 1500));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      // Reset controller state
      userName.value = '';
      resetAllFields();
      resetErrors();
      logger.i('AuthController: Reset controller state (userName, fields, errors)');

      // Clear all storage data
      await _storageService.clear();
      logger.i('AuthController: Cleared all storage data');

      // Verify storage is empty
      if (_storageService.getUser() == null && _storageService.getToken() == null && !_storageService.getIsAdmin()) {
        logger.i('AuthController: Verified storage is empty (user, token, isAdmin)');
      } else {
        logger.w('AuthController: Storage not fully cleared: user=${_storageService.getUser()}, token=${_storageService.getToken()}, isAdmin=${_storageService.getIsAdmin()}');
      }

      // Navigate to sign-in page
      logger.i('AuthController: Navigating to sign-in page');
      Get.offAllNamed(AppRoutes.getSignInPage());
    } catch (e) {
      logger.e('AuthController: Logout failed: $e');
      Get.snackbar('error'.tr, 'logout_failed'.tr,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(milliseconds: 1500));
    }
  }

  bool isLoggedIn() {
    final isLoggedIn = _storageService.getToken() != null;
    logger.i('AuthController: isLoggedIn: $isLoggedIn');
    return isLoggedIn;
  }

  Future<void> verifyOTP(String email, String otp) async {
    try {
      await _otpManager.verifyOTP(email, otp);
      logger.i('AuthController: OTP verified for email: $email');
    } catch (e) {
      logger.e('AuthController: OTP verification failed: $e');
      rethrow;
    }
  }

  Future<void> resendOTP(String email, String type) async {
    try {
      await _otpManager.resendOTP(email, type);
      logger.i('AuthController: OTP resent for email: $email, type: $type');
    } catch (e) {
      logger.e('AuthController: Resend OTP failed: $e');
      rethrow;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    validateEmail(email);
    if (emailError.value.isNotEmpty) {
      return;
    }
    try {
      await _passwordManager.requestPasswordReset(email);
      logger.i('AuthController: Password reset requested for email: $email');
    } catch (e) {
      logger.e('AuthController: Password reset request failed: $e');
      rethrow;
    }
  }

  Future<void> verifyPasswordResetOTP(String email, String otp) async {
    try {
      final resetToken = await _passwordManager.verifyPasswordResetOTP(email, otp);
      if (resetToken != null) {
        logger.i('AuthController: Password reset OTP verified for email: $email');
        Get.toNamed(AppRoutes.getResetPasswordPage(), arguments: {
          'resetToken': resetToken,
          'email': email,
        });
      }
    } catch (e) {
      logger.e('AuthController: Password reset OTP verification failed: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String resetToken, String newPassword, String confirmPassword) async {
    resetPasswordErrors();
    validateNewPassword(newPassword);
    validateConfirmPassword(newPassword, confirmPassword);

    if (newPasswordError.value.isNotEmpty || confirmPasswordError.value.isNotEmpty) {
      return;
    }
    try {
      await _passwordManager.resetPassword(resetToken, newPassword, confirmPassword);
      logger.i('AuthController: Password reset successfully');
    } catch (e) {
      logger.e('AuthController: Password reset failed: $e');
      rethrow;
    }
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
      logger.i('AuthController: Password changed successfully for email: $userEmail');

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } catch (e) {
      logger.e('AuthController: Password change failed: $e');
      Get.snackbar('error'.tr, 'password_change_failed'.tr,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(milliseconds: 1500));
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
      logger.i('AuthController: Security question set for email: $userEmail');
    } catch (e) {
      logger.e('AuthController: Security question set failed: $e');
      Get.snackbar('error'.tr, 'security_question_failed'.tr,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(milliseconds: 1500));
    }
  }

  Future<void> verifySecurityAnswer(String email, String question, String answer, Function(String) onSuccess) async {
    validateSecurityQuestion(question);
    validateSecurityAnswer(answer);

    if (securityQuestionError.value.isNotEmpty || securityAnswerError.value.isNotEmpty) {
      return;
    }

    try {
      final resetToken = await _securityManager.verifySecurityAnswer(email, question, answer);
      if (resetToken != null) {
        logger.i('AuthController: Security answer verified for email: $email');
        onSuccess(resetToken);
        clearSecurityFields(); // Clear fields after successful verification
      }
    } catch (e) {
      logger.e('AuthController: Security answer verification failed: $e');
      rethrow;
    }
  }
}