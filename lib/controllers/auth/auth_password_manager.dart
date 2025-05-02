import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_routes.dart';
import 'auth_controller_callbacks.dart';

/// Manages password-related authentication flows (reset, change).
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
      final response = await _apiService.auth.requestPasswordReset(email.toLowerCase());
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'password_reset_request_failed'.tr);
      }

      // Show success feedback and navigate to Verify OTP page
      _callbacks.showSnackbar(
        'success'.tr,
        'otp_sent_to_email'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      _callbacks.navigateTo(AppRoutes.getVerifyOTPPage(), arguments: {
        'email': email.toLowerCase(),
        'type': 'password_reset',
      });
    } catch (e) {
      print('Password reset request failed: $e');
      _callbacks.showSnackbar(
        'error'.tr,
        e.toString().replaceFirst('Exception: ', '').tr,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } finally {
      _callbacks.setIsLoading(false);
    }
  }

  /// Verifies the OTP for password reset and returns a reset token.
  Future<String?> verifyPasswordResetOTP(String email, String otp) async {
    try {
      _callbacks.setIsLoading(true);
      print('Verifying password reset OTP for: $email, OTP: $otp');

      // Call API service to verify password reset OTP
      final response = await _apiService.auth.verifyPasswordResetOTP(email.toLowerCase(), otp);
      final resetToken = response['resetToken'] as String?;
      if (resetToken == null) {
        throw Exception('reset_token_missing'.tr);
      }

      _callbacks.showSnackbar(
        'success'.tr,
        'otp_verified'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return resetToken;
    } catch (e) {
      print('Password reset OTP verification failed: $e');
      String errorMessage = e.toString().replaceFirst('Exception: ', '').tr;
      _callbacks.showSnackbar(
        'error'.tr,
        errorMessage,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      return null;
    } finally {
      _callbacks.setIsLoading(false);
    }
  }

  /// Resets the user's password using a reset token.
  Future<void> resetPassword(String resetToken, String newPassword, String confirmPassword) async {
    try {
      _callbacks.setIsLoading(true);
      print('Resetting password with resetToken: [REDACTED]');

      // Call API service to reset password
      final response = await _apiService.auth.resetPassword(resetToken, newPassword, confirmPassword);
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'password_reset_failed'.tr);
      }

      // Show success feedback and navigate to Sign In page
      _callbacks.showSnackbar(
        'success'.tr,
        'password_reset_success'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      await Future.delayed(const Duration(seconds: 1));
      _callbacks.navigateOffAll(AppRoutes.getSignInPage());
    } catch (e) {
      print('Password reset failed: $e');
      _callbacks.showSnackbar(
        'error'.tr,
        e.toString().replaceFirst('Exception: ', '').tr,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } finally {
      _callbacks.setIsLoading(false);
    }
  }

  /// Allows a logged-in user to change their password.
  Future<void> changePassword(String currentPassword, String newPassword, String userEmail) async {
    try {
      _callbacks.setIsLoading(true);
      print('Calling ApiService.changePassword for $userEmail');

      // Call API service to change password
      final response = await _apiService.auth.changePassword(userEmail.toLowerCase(), currentPassword, newPassword);
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'password_change_failed'.tr);
      }

      _callbacks.resetPasswordErrors();
      _callbacks.updatePasswordChangeSuccess(true);

      // Show success feedback
      _callbacks.showSnackbar(
        'success'.tr,
        'password_changed_successfully'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
      await Future.delayed(const Duration(seconds: 1));
      _callbacks.navigateOffAll(AppRoutes.getHomePage());
    } catch (e) {
      print('Change password error: $e');
      String rawError = e.toString().replaceFirst('Exception: ', '');
      String errorMessage = 'generic_error'.tr;

      if (rawError.contains('Current password is incorrect') || rawError.contains('401')) {
        _callbacks.updateCurrentPasswordError('current_password_incorrect'.tr);
      } else if (rawError.contains('User not found') || rawError.contains('user_email_not_found') || rawError.contains('404')) {
        errorMessage = 'user_not_found'.tr;
      } else if (rawError.contains('Server error') || rawError.contains('500')) {
        errorMessage = 'server_error'.tr;
      } else if (rawError.contains('Invalid request') || rawError.contains('400')) {
        errorMessage = 'invalid_request'.tr;
      } else if (rawError.contains('Network error')) {
        errorMessage = 'network_error'.tr;
      } else {
        errorMessage = rawError.tr.isNotEmpty ? rawError.tr : 'generic_error'.tr;
      }

      if (!_callbacks.setCurrentPasswordErrorCalled) {
        _callbacks.showSnackbar(
          'error'.tr,
          errorMessage,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
        );
      }
      rethrow;
    } finally {
      print('Setting isLoading to false');
      _callbacks.setIsLoading(false);
    }
  }
}