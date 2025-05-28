import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_routes.dart';
import 'auth_controller_callbacks.dart';

/// Manages OTP-related authentication flows.
class AuthOtpManager {
  final ApiService _apiService;
  final StorageService _storageService;
  final AuthControllerCallbacks _callbacks;

  AuthOtpManager(this._apiService, this._storageService, this._callbacks);

  /// Verifies the provided OTP for a given email.
  Future<void> verifyOTP(String email, String otp) async {
    try {
      _callbacks.setIsLoading(true);
      print('Verifying OTP for: $email');

      // Call API service to verify OTP
      final response = await _apiService.auth.verifyOTP(email.toLowerCase(), otp);

      // Save user and token on successful verification
      await _storageService.saveUser(response['user']);
      await _storageService.saveToken(response['token']);

      // Show success feedback and navigate to home
      _callbacks.showSnackbar(
        'success'.tr,
        'account_created_successfully'.tr, // Fixed typo in translation key
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 3000)
      );
      await Future.delayed(const Duration(seconds: 1));
      _callbacks.navigateOffAll(AppRoutes.getHomePage());
    } catch (e) {
      print('OTP verification failed: $e');
      _callbacks.showSnackbar(
        'error'.tr,
        e.toString().replaceFirst('Exception: ', '').tr,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 3000)
      );
    } finally {
      _callbacks.setIsLoading(false);
    }
  }

  /// Requests a new OTP be sent to the user's email.
  Future<void> resendOTP(String email, String type) async {
    try {
      _callbacks.setIsLoading(true);
      print('Resending OTP for: $email, type: $type');

      // Call API service to resend OTP
      final response = await _apiService.auth.resendOTP(email.toLowerCase(), type);
      if (response['status'] != 'success') {
        throw Exception(response['message'] ?? 'otp_resend_failed'.tr);
      }

      // Show success feedback
      _callbacks.showSnackbar(
        'success'.tr,
        'otp_sent_to_email'.tr,
        backgroundColor: Colors.green,
        colorText: Get.theme.colorScheme.onSecondary,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 3000)
      );
    } catch (e) {
      print('Resend OTP failed: $e');
      _callbacks.showSnackbar(
        'error'.tr,
        e.toString().replaceFirst('Exception: ', '').tr,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 3000)
        
      );
    } finally {
      _callbacks.setIsLoading(false);
    }
  }
}