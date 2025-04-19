import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

// This controller now handles all authentication-related logic,
// including signup, signin, password reset, and change password.
class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>(); // Ensure ApiService is bound
  final StorageService _storageService = Get.find<StorageService>(); // Ensure StorageService is bound

  // Observable states for UI (Includes all errors)
  var isLoading = false.obs; // Global loading state for auth actions
  var usernameError = ''.obs;
  var emailError = ''.obs;
  var passwordError = ''.obs; // For signup/signin initial password
  var confirmPasswordError = ''.obs; // For signup and reset password confirm
  var currentPasswordError = ''.obs; // For change password
  var newPasswordError = ''.obs; // For change password and reset password
  var bioError = ''.obs; // Assuming bio is part of the auth profile
  var securityQuestionError = ''.obs; // For security question setup/verification
  var securityAnswerError = ''.obs;

  // TextEditingControllers (Includes all auth-related inputs)
  final emailController = TextEditingController(); // For signin/reset flows
  final usernameController = TextEditingController(); // For signup
  final currentPasswordController = TextEditingController(); // For change password
  final newPasswordController = TextEditingController(); // For change password and reset password fields
  final confirmPasswordController = TextEditingController(); // For change password and reset password fields
  final securityQuestionTextController = TextEditingController(); // For security question
  final securityAnswerTextController = TextEditingController(); // For security answer


  @override
  void onInit() {
     super.onInit();
     // Optional: You could reset all fields/errors here if the controller's
     // lifecycle matches a full auth flow (e.g., bound to an AuthWrapper).
     // resetAllFields(); // You would need to create this method
     // resetErrors();
  }

  @override
  void onClose() {
    // Dispose ALL controllers managed by THIS controller
    emailController.dispose();
    usernameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    securityQuestionTextController.dispose();
    securityAnswerTextController.dispose();
    super.onClose();
  }

  // Helper to reset all text field values
  void resetAllFields() {
    emailController.clear();
    usernameController.clear();
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    securityQuestionTextController.clear();
    securityAnswerTextController.clear();
  }


  // Reset all general auth errors and loading state
  void resetErrors() {
    print('Resetting all validation errors');
    usernameError.value = '';
    emailError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
    currentPasswordError.value = ''; // Included all password errors
    newPasswordError.value = '';
    bioError.value = '';
    securityQuestionError.value = '';
    securityAnswerError.value = '';
    isLoading.value = false; // Reset loading if it's a global auth loading state
  }

  // Reset specific password errors (useful for change password/reset flows)
  void resetPasswordErrors() {
    print('Resetting password error states');
    currentPasswordError.value = '';
    newPasswordError.value = '';
    confirmPasswordError.value = '';
    // isLoading.value = false; // Uncomment if you want to reset loading here too
  }


  // --- Validation Methods (All included here) ---

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

  void validatePassword(String value) { // Used for signup/signin
    print('Validating password: ${value.isEmpty ? "empty" : "non-empty"}');
    if (value.isEmpty) {
      passwordError.value = 'password_required'.tr;
    } else if (value.length < 6) {
      passwordError.value = 'password_too_short'.tr;
    } else {
      passwordError.value = '';
    }
  }

  void validateConfirmPassword(String password, String confirmPassword) { // Used for signup, reset, change
    print('Validating confirm password: ${confirmPassword.isEmpty ? "empty" : "non-empty"}');
    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = 'confirm_password_required'.tr;
    } else if (confirmPassword != password) {
      confirmPasswordError.value = 'passwords_do_not_match'.tr;
    } else {
      confirmPasswordError.value = '';
    }
  }

  void validateCurrentPassword(String value) { // Used for change password
    if (value.isEmpty) {
      currentPasswordError.value = 'current_password_required'.tr;
    } else {
      currentPasswordError.value = '';
    }
  }

  void validateNewPassword(String value) { // Used for change password and reset password
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

 
  void validateSecurityQuestion(String question) {
    if (question.trim().isEmpty) {
      securityQuestionError.value = 'question_required'.tr;
    } else {
      securityQuestionError.value = '';
    }
  }

  void validateSecurityAnswer(String answer) {
    if (answer.trim().isEmpty) {
      securityAnswerError.value = 'answer_required'.tr;
    } else if (answer.trim().length < 3) {
      securityAnswerError.value = 'answer_too_short'.tr;
    } else {
      securityAnswerError.value = '';
    }
  }


  // --- Authentication Action Methods ---

  Future<void> signup(UserModel user, String password, String confirmPassword) async {
    // Existing signup logic using validation methods in this controller
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
      final response = await _apiService.auth.signup(
        UserModel(
          id: user.id,
          username: user.username,
          email: emailController.text.toLowerCase(), // Use controller
          role: user.role, // Make sure role is handled or remove if not applicable
        ),
        password, // Password comes from input field, not user model
      );
      Get.snackbar('success'.tr, 'otp_sent_to_email'.tr,
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.toNamed(AppRoutes.getVerifyOTPPage(), arguments: {
        'email': emailController.text.toLowerCase(), // Use controller
        'user': user, // Pass the user model if needed in the next screen
        'password': password, // Pass password if needed
      });
    } catch (e) {
      print('Signup failed: $e');
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP(String email, String otp) async {
    // Existing verifyOTP logic
    try {
      isLoading.value = true;
      print('Verifying OTP for: $email');
      final response = await _apiService.auth.verifyOTP(email, otp);
      await _storageService.saveUser(response['user']); // Assuming response['user'] is the user map
      await _storageService.saveToken(response['token']); // Assuming response['token'] is the token string
      Get.snackbar('success'.tr, 'account_created_successfully'.tr,
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed(AppRoutes.getHomePage()); // Redirect to home after successful verification and login
    } catch (e) {
      print('OTP verification failed: $e');
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOTP(String email, String type) async {
    // Existing resendOTP logic
    try {
      isLoading.value = true;
      print('Resending OTP for: $email, type: $type');
      await _apiService.auth.resendOTP(email, type);
      Get.snackbar('success'.tr, 'otp_sent_to_email'.tr,
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      print('Resend OTP failed: $e');
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signin(String email, String password) async {
    // Existing signin logic
    validateEmail(email);
    validatePassword(password);
    if (emailError.value.isNotEmpty || passwordError.value.isNotEmpty) {
      print('Signin validation failed: emailError=${emailError.value}, passwordError=${passwordError.value}');
      return;
    }

    try {
      isLoading.value = true;
      print('Attempting signin for: $email');
      final response = await _apiService.auth.signin(emailController.text.toLowerCase(), password); // Use controller
      print('Signin response: $response');
      await _storageService.saveUser(response['user']); // Assuming response['user'] is the user map
      await _storageService.saveToken(response['token']); // Assuming response['token'] is the token string
      Get.snackbar('success'.tr, 'logged_in_successfully'.tr,
          backgroundColor: Colors.greenAccent, colorText: Colors.white);
      Get.offAllNamed(AppRoutes.getHomePage()); // Redirect to home after signin
    } catch (e) {
      print('Signin failed: $e');
      // Note: Added .tr here again as it was in the original code
      Get.snackbar('error'.tr, e.toString().tr.replaceFirst('Exception: ', ''),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    // Existing requestPasswordReset logic
    validateEmail(email);

    if (emailError.value.isNotEmpty) {
      print('Password reset request validation failed: emailError=${emailError.value}');
      return;
    }

    try {
      isLoading.value = true;
      print('Requesting password reset for: $email');
      final response = await _apiService.auth.requestPasswordReset(emailController.text.toLowerCase()); // Use controller
      Get.snackbar('success'.tr, 'otp_sent_to_email'.tr,
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.toNamed(AppRoutes.getVerifyOTPPage(), arguments: {
        'email': emailController.text.toLowerCase(), // Use controller
        'type': 'password_reset',
      });
    } catch (e) {
      print('Password reset request failed: $e');
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyPasswordResetOTP(String email, String otp) async {
    // Existing verifyPasswordResetOTP logic
    try {
      isLoading.value = true;
      print('Verifying password reset OTP for: $email');
      final response = await _apiService.auth.verifyPasswordResetOTP(email, otp);
      Get.snackbar('success'.tr, 'otp_verified'.tr,
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.toNamed(AppRoutes.getResetPasswordPage(), arguments: {
        'resetToken': response['resetToken'],
        'email': email, // Pass email as it might be needed for context in ResetPasswordPage
      });
    } catch (e) {
      print('Password reset OTP verification failed: $e');
      Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

// This method uses validation methods and error states within THIS controller
Future<void> resetPassword(String resetToken, String newPassword, String confirmPassword) async {
 // Clear relevant errors before validating
 newPasswordError.value = '';
 confirmPasswordError.value = '';

 validateNewPassword(newPassword); // Use validation methods in this controller
 validateConfirmPassword(newPassword, confirmPassword); // Use validation methods in this controller

 // Check error states in this controller
 if (newPasswordError.value.isNotEmpty || confirmPasswordError.value.isNotEmpty) {
   return;
 }

  try {
    isLoading.value = true;
    await _apiService.auth.resetPassword(resetToken, newPassword, confirmPassword);
    Get.snackbar('success'.tr, 'password_reset_success'.tr,
        backgroundColor: Colors.green, colorText: Colors.white);
    Get.offAllNamed(AppRoutes.getSignInPage()); // Go back to sign in after reset
  } catch (e) {
    Get.snackbar('error'.tr, e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.redAccent, colorText: Colors.white);
  } finally {
    isLoading.value = false;
  }
}

 // --- Change Password Method (Moved back here) ---
  Future<void> changePassword() async {
    // Get text directly from controllers managed by THIS controller
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmNewPassword = confirmPasswordController.text;

    print('changePassword called with current: ${currentPassword.isEmpty ? "empty" : "non-empty"}, new: ${newPassword.isEmpty ? "empty" : "non-empty"}, confirm: ${confirmNewPassword.isEmpty ? "empty" : "non-empty"}');

    // Reset password errors at the beginning of the submission process
    resetPasswordErrors(); // Uses the specific password error reset

    validateCurrentPassword(currentPassword); // Use validation method in this controller
    validateNewPassword(newPassword); // Use validation method in this controller
    validateConfirmPassword(newPassword, confirmNewPassword); // Use validation method in this controller

    // Add check for same password only after basic validation
    if (newPassword.isNotEmpty && currentPassword == newPassword && newPasswordError.value.isEmpty) {
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
      if (user == null || user['email'] == null) { // Check for null user or missing email
        print('No user or email found in storage');
        throw Exception('user_email_not_found'); // More specific error key
      }
      final userEmail = user['email'];
      print('User found: $userEmail');
      print('Calling ApiService.changePassword');
      await _apiService.auth.changePassword(userEmail, currentPassword, newPassword);
      print('Password change successful, showing snackbar');

      // Clear fields and errors on success using resetErrors or specific method
      resetPasswordErrors(); // Clear password errors
       currentPasswordController.clear(); // Clear the fields manually
       newPasswordController.clear();
       confirmPasswordController.clear();


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
      print('Navigating back');
      Get.back(); // Navigate back after success

    } catch (e) {
      print('Change password error: $e');
      String errorMessage = 'generic_error'.tr;
      String rawError = e.toString().replaceFirst('Exception: ', '');

      // Map specific error strings to translated keys and potentially set field errors
      if (rawError.contains('Current password is incorrect')) {
        currentPasswordError.value = 'current_password_incorrect'.tr; // Set error on the specific field
        // Optionally also show in snackbar
        // errorMessage = 'current_password_incorrect'.tr;
      } else if (rawError.contains('User not found') || rawError.contains('user_email_not_found')) {
        errorMessage = 'user_not_found'.tr;
      } else if (rawError.contains('Server error')) {
        errorMessage = 'server_error'.tr;
      } else {
        // For unknown errors, just show the generic message or the raw error
        errorMessage = rawError.tr; // Use .tr in case the raw error is a translation key
      }

      // Only show snackbar for general errors or feedback not tied to a specific field
      // This condition prevents showing a duplicate snackbar if a field error is already set
      if (!['current_password_incorrect'.tr].contains(errorMessage)) {
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
      }

    } finally {
      print('Setting isLoading to false');
      isLoading.value = false;
    }
  }


  Future<void> setSecurityQuestion(String question, String answer) async {
    // Existing setSecurityQuestion logic
    validateSecurityQuestion(question);
    validateSecurityAnswer(answer);

    if (securityQuestionError.value.isNotEmpty || securityAnswerError.value.isNotEmpty) {
      return;
    }

    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      if (user == null || user['email'] == null) { // Check for null user or missing email
        throw Exception('user_email_not_found'.tr);
      }
      final userEmail = user['email'];
      await _apiService.auth.setSecurityQuestion(userEmail, securityQuestionTextController.text, securityAnswerTextController.text); // Use controllers
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



  Future<void> verifySecurityAnswer(
      String email, String question, String answer, Function(String) onSuccess) async {
    // Existing verifySecurityAnswer logic
    validateSecurityQuestion(question);
    validateSecurityAnswer(answer);

    if (securityQuestionError.value.isNotEmpty || securityAnswerError.value.isNotEmpty) {
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.auth.verifySecurityAnswer(emailController.text, securityQuestionTextController.text, securityAnswerTextController.text); // Use controllers
      final resetToken = response['resetToken'];
      if (resetToken == null) {
        throw Exception('reset_token_missing'.tr);
      }
      onSuccess(resetToken); // Pass resetToken to the success callback
    } catch (e) {
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (errorMessage.contains('FormatException')) {
        errorMessage = 'invalid_data_format'.tr;
      } else if (errorMessage.contains('Security answer incorrect')) {
          securityAnswerError.value = 'security_answer_incorrect'.tr; // Set field error
          errorMessage = 'security_answer_incorrect'.tr; // Optionally show snackbar
      }
      Get.snackbar('error'.tr, errorMessage,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> logout() async {
    // Existing logout logic
    await _storageService.clear();
    Get.offAllNamed(AppRoutes.getSignInPage()); // Redirect to sign in after logout
  }

  bool isLoggedIn() {
    // Existing isLoggedIn logic
    return _storageService.getToken() != null;
  }

}