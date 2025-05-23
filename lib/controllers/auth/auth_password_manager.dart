import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_routes.dart';
import 'auth_controller_callbacks.dart';

class AuthPasswordManager {
  final ApiService _apiService;
  final StorageService _storageService;
  final AuthControllerCallbacks _callbacks;

  AuthPasswordManager(this._apiService, this._storageService, this._callbacks);

  Future<void> requestPasswordReset(String email) async {
    try {
      _callbacks.setIsLoading(true);
      print('Requesting password reset for: $email');

      final response = await _apiService.auth.requestPasswordReset(email.toLowerCase());
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'password_reset_request_failed'.tr);
      }

      _callbacks.showSnackbar(
        'success'.tr,
        'otp_sent_to_email'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 3000),
      );
      _callbacks.navigateTo(AppRoutes.getVerifyOTPPage(), arguments: {
        'email': email.toLowerCase(),
        'type': 'password_reset',
      });
    } catch (e) {
      print('Password reset request failed: $e');
      _callbacks.showSnackbar(
        'error'.tr,
        'password_reset_request_failed'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 3000),
      );
    } finally {
      _callbacks.setIsLoading(false);
    }
  }

  Future<String?> verifyPasswordResetOTP(String email, String otp) async {
    try {
      _callbacks.setIsLoading(true);
      print('Verifying password reset OTP for: $email, OTP: $otp');

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
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 3000),
      );
      return resetToken;
    } catch (e) {
      print('Password reset OTP verification failed: $e');
      _callbacks.showSnackbar(
        'error'.tr,
        'otp_verification_failed'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 3000),
      );
      return null;
    } finally {
      _callbacks.setIsLoading(false);
    }
  }

  Future<void> resetPassword(String resetToken, String newPassword, String confirmPassword) async {
    try {
      _callbacks.setIsLoading(true);
      print('Resetting password with resetToken: [REDACTED]');

      final response = await _apiService.auth.resetPassword(resetToken, newPassword, confirmPassword);
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'password_reset_failed'.tr);
      }

      _callbacks.showSnackbar(
        'success'.tr,
        'password_reset_success'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 3000),
      );
      await Future.delayed(const Duration(seconds: 1));
      _callbacks.navigateOffAll(AppRoutes.getSignInPage());
    } catch (e) {
      print('Password reset failed: $e');
      _callbacks.showSnackbar(
        'error'.tr,
        'password_reset_failed'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 3000),
      );
    } finally {
      _callbacks.setIsLoading(false);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword, String userEmail) async {
    try {
      _callbacks.setIsLoading(true);
      print('Calling ApiService.changePassword for $userEmail');

      final response = await _apiService.auth.changePassword(userEmail.toLowerCase(), currentPassword, newPassword);
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'password_change_failed'.tr);
      }

      _callbacks.resetPasswordErrors();
      _callbacks.updatePasswordChangeSuccess(true);

      _callbacks.showSnackbar(
        'success'.tr,
        'password_changed_successfully'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 3000),
      );
    } catch (e) {
      print('Change password error: $e');
      String errorMessage = 'password_change_failed'.tr;

      if (e.toString().contains('Current password is incorrect') || e.toString().contains('401')) {
        _callbacks.setCurrentPasswordError('current_password_incorrect'.tr);
      } else if (e.toString().contains('User not found') || e.toString().contains('user_email_not_found') || e.toString().contains('404')) {
        errorMessage = 'user_not_found'.tr;
      } else if (e.toString().contains('Server error') || e.toString().contains('500')) {
        errorMessage = 'server_error'.tr;
      } else if (e.toString().contains('Invalid request') || e.toString().contains('400')) {
        errorMessage = 'invalid_request'.tr;
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'network_error'.tr;
      }

      if (!_callbacks.setCurrentPasswordErrorCalled) {
        _callbacks.showSnackbar(
          'error'.tr,
          errorMessage,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(milliseconds: 3000),
        );
      }
      rethrow;
    } finally {
      _callbacks.setIsLoading(false);
    }
  }
}