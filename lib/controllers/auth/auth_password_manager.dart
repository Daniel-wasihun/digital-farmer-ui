import 'package:agri/controllers/auth/auth_controller_callbacks.dart';
import 'package:flutter/material.dart'; // Import for Colors or theme
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_routes.dart'; // Import AppRoutes

/// Manages password related authentication flows (reset, change).
class AuthPasswordManager {
  final ApiService _apiService;
  final StorageService _storageService;
  final AuthControllerCallbacks _callbacks;

  AuthPasswordManager(this._apiService, this._storageService, this._callbacks);

  /// Requests an OTP for password reset to the user's email.
  Future<void> requestPasswordReset(String email) async {
    try {
      _callbacks.setIsLoading(true);
      print('Requesting password reset for: $email');

      // Call API service to request reset
      await _apiService.auth.requestPasswordReset(email.toLowerCase());

      // Show success feedback and navigate to Verify OTP page
      _callbacks.showSnackbar(
        'success'.tr,
        'otp_sent_to_email'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );
      _callbacks.navigateTo(AppRoutes.getVerifyOTPPage(), arguments: {
        'email': email.toLowerCase(),
        'type': 'password_reset', // Indicate password reset flow
      });

    } catch (e) {
      // Handle API or other errors
      print('Password reset request failed: $e');
      _callbacks.showSnackbar(
        'error'.tr,
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _callbacks.setIsLoading(false);
    }
  }

  /// Verifies the OTP for password reset and returns a reset token.
  /// The controller will handle navigation after receiving the token.
  Future<String?> verifyPasswordResetOTP(String email, String otp) async {
     // OTP validation is typically handled by the API.
    try {
      _callbacks.setIsLoading(true);
      print('Verifying password reset OTP for: $email');

      // Call API service to verify password reset OTP
      final response = await _apiService.auth.verifyPasswordResetOTP(email, otp);

      _callbacks.showSnackbar(
        'success'.tr,
        'otp_verified'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );

      final resetToken = response['resetToken'];
       if (resetToken == null) {
         // This case should theoretically be handled by the API throwing an error,
         // but adding a local check can be defensive.
         throw Exception('reset_token_missing'.tr);
       }
       return resetToken;

    } catch (e) {
      // Handle API or other errors
      print('Password reset OTP verification failed: $e');
       String errorMessage = e.toString().replaceFirst('Exception: ', '');
       // Specific error handling might be needed here based on API response
        _callbacks.showSnackbar(
         'error'.tr,
         errorMessage,
         backgroundColor: Get.theme.colorScheme.error,
         colorText: Get.theme.colorScheme.onError,
       );
       return null; // Indicate failure
    } finally {
      _callbacks.setIsLoading(false);
    }
  }

  /// Resets the user's password using a reset token.
  Future<void> resetPassword(String resetToken, String newPassword, String confirmPassword) async {
    // Validation is assumed to be done by the controller before calling this.
    try {
      _callbacks.setIsLoading(true);
      // Call API service to reset password
      await _apiService.auth.resetPassword(resetToken, newPassword, confirmPassword);

      // Show success feedback and navigate to Sign In page
      _callbacks.showSnackbar(
        'success'.tr,
        'password_reset_success'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );
      _callbacks.navigateOffAll(AppRoutes.getSignInPage()); // Go back to sign-in

    } catch (e) {
      // Handle API or other errors
      _callbacks.showSnackbar(
        'error'.tr,
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _callbacks.setIsLoading(false);
    }
  }

  /// Allows a logged-in user to change their password.
  Future<void> changePassword(String currentPassword, String newPassword, String userEmail) async {
    // Validation is assumed to be done by the controller before calling this.
    try {
      _callbacks.setIsLoading(true);
      print('Calling ApiService.changePassword for $userEmail');
      // Call API service to change password
      await _apiService.auth.changePassword(userEmail, currentPassword, newPassword);

      // Clear fields and errors on success - Controller handles clearing controllers,
      // but manager can signal success states or clear its own relevant errors if any.
       _callbacks.resetPasswordErrors(); // Ask controller to clear relevant errors
       _callbacks.updatePasswordChangeSuccess(true); // Signal success state

      // Show success feedback
      print('Showing success snackbar');
      _callbacks.showSnackbar(
        'success'.tr,
        'password_changed_successfully'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );

      // Navigate after successful password change
      _callbacks.navigateOffAll(AppRoutes.getHomePage()); // Navigate to Home and clear stack

    } catch (e) {
      // Handle API or other errors during password change
      print('Change password error: $e');
      String rawError = e.toString().replaceFirst('Exception: ', '');
       String errorMessage = 'generic_error'.tr; // Default error

      // Map specific API errors to specific controller errors or generic messages
      if (rawError.contains('Current password is incorrect') || rawError.contains('401')) {
        _callbacks.setCurrentPasswordError('current_password_incorrect'.tr); // Set specific error on controller
      } else if (rawError.contains('User not found') || rawError.contains('user_email_not_found') || rawError.contains('404')) {
        errorMessage = 'user_not_found'.tr; // Use generic snackbar
      } else if (rawError.contains('Server error') || rawError.contains('500')) {
        errorMessage = 'server_error'.tr;
      } else if (rawError.contains('Invalid request') || rawError.contains('400')) {
        errorMessage = 'invalid_request'.tr;
      } else if (rawError.contains('Network error')) {
        errorMessage = 'network_error'.tr;
      } else {
        // Fallback
        errorMessage = rawError.tr.isNotEmpty ? rawError.tr : 'generic_error'.tr;
      }

      // Only show a generic snackbar if the error wasn't specifically assigned
      // to a password field error. (This check needs to be in the controller
      // or the manager needs access to the controller's specific error states
      // which is why passing callbacks is better)
       // The controller will decide whether to show the snackbar based on
       // whether setCurrentPasswordError was called.

        // Re-throw the error or indicate failure if the controller needs to know
        // for further handling (e.g., deciding *not* to show a generic snackbar
        // if a specific field error was set). Let's re-throw so the controller
        // can catch and decide on the snackbar.
        rethrow;


    } finally {
      print('Setting isLoading to false');
      _callbacks.setIsLoading(false); // Reset loading state
    }
  }
}