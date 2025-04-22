import 'package:agri/controllers/auth/auth_controller_callbacks.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_routes.dart'; // Import AppRoutes

/// Manages OTP related authentication flows.
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
      final response = await _apiService.auth.verifyOTP(email, otp);

      // Save user and token on successful verification
      await _storageService.saveUser(response['user']);
      await _storageService.saveToken(response['token']);

      // Show success feedback and navigate to home
      _callbacks.showSnackbar(
        'success'.tr,
        'account_created_successfully'.tr,
        backgroundColor: Get.theme.colorScheme.secondary, // Using theme colors
        colorText: Get.theme.colorScheme.onSecondary,
      );
      _callbacks.navigateOffAll(AppRoutes.getHomePage()); // Navigate and remove previous routes

    } catch (e) {
      // Handle API or other errors (e.g., invalid OTP)
      print('OTP verification failed: $e');
      _callbacks.showSnackbar(
        'error'.tr,
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Get.theme.colorScheme.error, // Using theme colors
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _callbacks.setIsLoading(false); // Reset loading state
    }
  }

  /// Requests a new OTP be sent to the user's email.
  Future<void> resendOTP(String email, String type) async {
    try {
      _callbacks.setIsLoading(true);
      print('Resending OTP for: $email, type: $type');

      // Call API service to resend OTP
      await _apiService.auth.resendOTP(email, type);

      // Show success feedback
      _callbacks.showSnackbar(
        'success'.tr,
        'otp_sent_to_email'.tr,
        backgroundColor: Get.theme.colorScheme.secondary,
        colorText: Get.theme.colorScheme.onSecondary,
      );

    } catch (e) {
      // Handle API or other errors
      print('Resend OTP failed: $e');
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
}