import 'package:agri/controllers/auth/auth_validation_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

// Import mixin and managers
import 'auth_controller_callbacks.dart';
import 'auth_otp_manager.dart';
import 'auth_password_manager.dart';
import 'auth_security_manager.dart';

/// The main controller orchestrating authentication related logic and state.
/// It delegates specific workflows to dedicated managers.
class AuthController extends GetxController with AuthValidationMixin {
  // ==================== Dependencies ====================
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  // Feature Managers
  late final AuthOtpManager _otpManager;
  late final AuthPasswordManager _passwordManager;
  late final AuthSecurityManager _securityManager;

  // ==================== Observable States (Required by Mixin and other states) ====================
  @override
  final isLoading = false.obs;
  @override
  final isPasswordChangeSuccess = false.obs; // State for password change UI feedback

  // Error states (required by AuthValidationMixin)
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

  // ==================== TextEditingControllers ====================
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final securityQuestionTextController = TextEditingController();
  final securityAnswerTextController = TextEditingController();

   // ==================== Initialization ====================
  @override
  void onInit() {
    super.onInit();
    // Initialize feature managers, passing required dependencies and callbacks
    final callbacks = AuthControllerCallbacks(
      setIsLoading: (value) => isLoading.value = value,
      // Corrected signature and usage of Get.snackbar params
      showSnackbar: (title, message, {backgroundColor, colorText, snackPosition, borderRadius, margin}) {
        Get.snackbar(
          title,
          message,
          backgroundColor: backgroundColor ?? Get.theme.colorScheme.surfaceContainerHighest, // Default or passed color
          colorText: colorText ?? Get.theme.colorScheme.onSurfaceVariant, // Default or passed color
          snackPosition: snackPosition ?? SnackPosition.BOTTOM,
          // Removed duration and isDismissible here
          borderRadius: borderRadius ?? 8, // Use passed or default
          margin: margin ?? const EdgeInsets.all(16), // Use passed or default
        );
        // If you need duration control, you might need to use Get.showSnackbar
        // with a GetSnackBar widget which *does* accept a duration.
        // Example (less direct):
        /*
        Get.showSnackbar(
          GetSnackBar(
            title: title,
            message: message,
            backgroundColor: backgroundColor ?? Get.theme.colorScheme.surfaceVariant,
            colorText: colorText ?? Get.theme.colorScheme.onSurfaceVariant,
            snackPosition: snackPosition ?? SnackPosition.BOTTOM,
            borderRadius: borderRadius ?? 8,
            margin: margin ?? const EdgeInsets.all(16),
            duration: const Duration(seconds: 4), // Duration is a GetSnackBar param
            isDismissible: true, // isDismissible is a GetSnackBar param
          ),
        );
        */
      },
      navigateTo: (pageName, {arguments, id, preventDuplicates = true, parameters}) =>
          Get.toNamed(pageName, arguments: arguments, id: id, preventDuplicates: preventDuplicates, parameters: parameters),
      navigateOffAll: (pageName, {arguments, id, parameters}) =>
          Get.offAllNamed(pageName, arguments: arguments, id: id, parameters: parameters),
      resetPasswordErrors: resetPasswordErrors, // Pass the specific reset method
      updatePasswordChangeSuccess: (value) => isPasswordChangeSuccess.value = value, // Pass specific state update
      setCurrentPasswordError: (value) => currentPasswordError.value = value, // Pass specific error setter
      setSecurityAnswerError: (value) => securityAnswerError.value = value, // Pass specific error setter
    );

    _otpManager = AuthOtpManager(_apiService, _storageService, callbacks);
    _passwordManager = AuthPasswordManager(_apiService, _storageService, callbacks);
    _securityManager = AuthSecurityManager(_apiService, _storageService, callbacks);
  }


  // ==================== Lifecycle ====================
  @override
  void onClose() {
    // Dispose controllers to prevent memory leaks
    emailController.dispose();
    usernameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    securityQuestionTextController.dispose();
    securityAnswerTextController.dispose();
    super.onClose();
  }

  // ==================== Helper Methods ====================
  /// Resets all text editing fields.
  void resetAllFields() {
    emailController.clear();
    usernameController.clear();
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    securityQuestionTextController.clear();
    securityAnswerTextController.clear();
  }

  /// Resets all validation error states.
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
    // isLoading is often reset after an operation, not just errors
    // isLoading.value = false;
  }

  /// Resets only the password-related error states.
  void resetPasswordErrors() {
    print('Resetting password error states');
    currentPasswordError.value = '';
    newPasswordError.value = '';
    confirmPasswordError.value = '';
  }

  // ==================== Core Authentication Flows (Handled by AuthController) ====================

  /// Handles user signup. Validates input, calls API, navigates to OTP verification.
  Future<void> signup(UserModel user, String password, String confirmPassword) async {
    // Validate input using methods from AuthValidationMixin
    validateUsername(user.username);
    validateEmail(user.email);
    validatePassword(password);
    validateConfirmPassword(password, confirmPassword);

    // Check if any validation failed
    if (usernameError.value.isNotEmpty ||
        emailError.value.isNotEmpty ||
        passwordError.value.isNotEmpty ||
        confirmPasswordError.value.isNotEmpty) {
      print('Signup validation failed');
      return; // Stop if validation fails
    }

    try {
      isLoading.value = true; // Set loading state
      print('Attempting signup for: ${user.email}');

      // Call API service for signup
      await _apiService.auth.signup( // Assuming signup API doesn't return user/token directly now
        UserModel(
          id: user.id,
          username: user.username,
          email: user.email.toLowerCase(),
          role: user.role,
        ),
        password,
      );

      // Show success feedback and navigate
      // Corrected Get.snackbar call - Removed duration, isDismissible
      Get.snackbar('success'.tr, 'otp_sent_to_email'.tr,
          backgroundColor: Get.theme.colorScheme.secondary, colorText: Get.theme.colorScheme.onSecondary);
      Get.toNamed(AppRoutes.getVerifyOTPPage(), arguments: {
        'email': user.email.toLowerCase(),
        'user': user, // Pass user data if needed on OTP page
        'password': password, // Pass password if needed (e.g., for re-signup attempt)
        'type': 'signup', // Indicate signup flow
      });
    } catch (e) {
      // Handle API or other errors
      print('Signup failed: $e');
      // Corrected Get.snackbar call - Removed duration, isDismissible
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    } finally {
      isLoading.value = false; // Reset loading state
    }
  }

  /// Handles user sign-in. Validates input, calls API, saves user/token, navigates to home.
  Future<void> signin(String email, String password) async {
    // Validate input using methods from AuthValidationMixin
    validateEmail(email);
    validatePassword(password);

    // Check if any validation failed
    if (emailError.value.isNotEmpty || passwordError.value.isNotEmpty) {
      print('Signin validation failed');
      return; // Stop if validation fails
    }

    try {
      isLoading.value = true; // Set loading state
      print('Attempting signin for: $email');

      // Call API service for signin
      final response = await _apiService.auth.signin(email.toLowerCase(), password);
      print('Signin response: $response');

      // Save user and token on successful signin
      await _storageService.saveUser(response['user']);
      await _storageService.saveToken(response['token']);

      // Show success feedback and navigate to home
      // Corrected Get.snackbar call - Removed duration, isDismissible
      Get.snackbar('success'.tr, 'logged_in_successfully'.tr,
          backgroundColor: Get.theme.colorScheme.secondary, colorText: Get.theme.colorScheme.onSecondary); // Use theme colors
      Get.offAllNamed(AppRoutes.getHomePage()); // Navigate and remove previous routes
    } catch (e) {
      // Handle API or other errors (e.g., incorrect credentials)
      print('Signin failed: $e');
      // Corrected Get.snackbar call - Removed duration, isDismissible
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError); // Use red for errors
    } finally {
      isLoading.value = false; // Reset loading state
    }
  }

  /// Logs the user out by clearing local storage and navigating to the sign-in page.
  Future<void> logout() async {
    await _storageService.clear(); // Clear user data and token
    Get.offAllNamed(AppRoutes.getSignInPage()); // Navigate to sign-in and clear stack
  }

  /// Checks if a user is currently logged in by checking for a token in storage.
  bool isLoggedIn() {
    return _storageService.getToken() != null; // True if token exists
  }


  // ==================== Delegated Flows (Calls to Feature Managers) ====================

  /// Delegates OTP verification to AuthOtpManager.
  Future<void> verifyOTP(String email, String otp) async {
     await _otpManager.verifyOTP(email, otp);
     // Note: Manager handles isLoading, snackbars, and navigation.
  }

  /// Delegates OTP resending to AuthOtpManager.
  Future<void> resendOTP(String email, String type) async {
    await _otpManager.resendOTP(email, type);
    // Note: Manager handles isLoading and snackbars.
  }

  /// Delegates password reset request to AuthPasswordManager.
   Future<void> requestPasswordReset(String email) async {
    // Validate email using method from AuthValidationMixin first
    validateEmail(email);
    if (emailError.value.isNotEmpty) {
      print('Password reset request validation failed');
      return;
    }
     await _passwordManager.requestPasswordReset(email);
     // Note: Manager handles isLoading, snackbars, and navigation.
   }

  /// Delegates password reset OTP verification to AuthPasswordManager
  /// and handles subsequent navigation if successful.
   Future<void> verifyPasswordResetOTP(String email, String otp) async {
      // Validation for OTP verification is usually handled by the API.
     final resetToken = await _passwordManager.verifyPasswordResetOTP(email, otp);
     // Manager handles isLoading and snackbars.
     if (resetToken != null) {
        // If verification is successful (token received), navigate.
        Get.toNamed(AppRoutes.getResetPasswordPage(), arguments: {
          'resetToken': resetToken,
          'email': email,
        });
     }
   }

  /// Delegates password reset using token to AuthPasswordManager.
   Future<void> resetPassword(String resetToken, String newPassword, String confirmPassword) async {
     // Reset password errors first
     resetPasswordErrors();

     // Validate new and confirm passwords using methods from AuthValidationMixin
     validateNewPassword(newPassword);
     validateConfirmPassword(newPassword, confirmPassword);

     // Check if any validation failed
     if (newPasswordError.value.isNotEmpty || confirmPasswordError.value.isNotEmpty) {
       return; // Stop if validation fails
     }
     await _passwordManager.resetPassword(resetToken, newPassword, confirmPassword);
      // Note: Manager handles isLoading, snackbars, and navigation.
   }


  /// Delegates change password to AuthPasswordManager.
  Future<void> changePassword() async {
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmNewPassword = confirmPasswordController.text.trim();

     // Reset password errors first
     resetPasswordErrors();

     // Validate passwords using methods from AuthValidationMixin
     validateCurrentPassword(currentPassword);
     validateNewPassword(newPassword);
     validateConfirmPassword(newPassword, confirmNewPassword);

     // Additional check specific to change password flow: new password must be different
     if (newPassword.isNotEmpty && currentPassword == newPassword && newPasswordError.value.isEmpty) {
       print('Validation failed: New password is same as current password');
       newPasswordError.value = 'new_password_same_as_current'.tr;
     }

     // Check if any validation failed
     if (currentPasswordError.value.isNotEmpty ||
         newPasswordError.value.isNotEmpty ||
         confirmPasswordError.value.isNotEmpty) {
       print('Validation failed: current=${currentPasswordError.value}, '
           'new=${newPasswordError.value}, confirm=${confirmPasswordError.value}');
       return; // Stop if validation fails
     }

    try {
       // Get the current user's email from storage before calling the manager
       final user = _storageService.getUser();
       if (user == null || user['email'] == null) {
         print('No user or email found in storage for change password');
         throw Exception('user_email_not_found');
       }
       final userEmail = user['email'].toString().trim();
       print('User email found for change password: $userEmail');

       // Delegate to the password manager
       await _passwordManager.changePassword(currentPassword, newPassword, userEmail);

       // Clear fields after successful change (manager asks controller to reset errors)
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

       // Manager handles isLoading, snackbars, success state, and navigation.

    } catch (e) {
       // Catch specific errors re-thrown by the manager if needed, or handle generic errors
       print('AuthController caught change password error after manager: $e');
       // The manager already handled specific field errors and potentially showed a snackbar.
       // If a generic snackbar wasn't shown by the manager (because a field error was set),
       // the controller could potentially show one here based on the caught error,
       // but the manager's logic seems sufficient for this example.
       // Re-showing a generic snackbar here might be redundant.
    } finally {
       // isLoading is reset by the manager
    }
  }

   /// Delegates setting security question to AuthSecurityManager.
  Future<void> setSecurityQuestion(String question, String answer) async {
     // Validate input using methods from AuthValidationMixin first
     validateSecurityQuestion(question);
     validateSecurityAnswer(answer);

     // Check if any validation failed
     if (securityQuestionError.value.isNotEmpty || securityAnswerError.value.isNotEmpty) {
       return; // Stop if validation fails
     }

    try {
       // Get the current user's email from storage before calling the manager
       final user = _storageService.getUser();
       if (user == null || user['email'] == null) {
         print('No user or email found in storage for setting security question');
         throw Exception('user_email_not_found'.tr);
       }
       final userEmail = user['email'];

       // Delegate to the security manager
       await _securityManager.setSecurityQuestion(userEmail, question, answer);
        // Note: Manager handles isLoading, snackbars, and navigation.

    } catch (e) {
       // Handle any unexpected errors not caught by the manager (less likely with this structure)
        print('AuthController caught setSecurityQuestion error after manager: $e');
       Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
           backgroundColor: Get.theme.colorScheme.error, colorText: Get.theme.colorScheme.onError);
    } finally {
       // isLoading is reset by the manager
    }
  }


  /// Delegates verifying security answer to AuthSecurityManager
  /// and handles subsequent actions (e.g., navigating to reset password) if successful.
  Future<void> verifySecurityAnswer(String email, String question, String answer, Function(String) onSuccess) async {
    // Validate input using methods from AuthValidationMixin first
    validateSecurityQuestion(question); // Use the passed question for validation
    validateSecurityAnswer(answer);   // Use the passed answer for validation

    if (securityQuestionError.value.isNotEmpty || securityAnswerError.value.isNotEmpty) {
      return;
    }

     final resetToken = await _securityManager.verifySecurityAnswer(email, question, answer);
     // Manager handles isLoading and snackbars, including specific answer error.

     if (resetToken != null) {
        // If verification is successful (token received), execute the success callback.
        onSuccess(resetToken);
     }
     // If resetToken is null, the manager already handled the error and showed a snackbar.
  }

}