import 'package:agri/controllers/auth/auth_controller_callbacks.dart';
// Import for Colors or theme
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import '../../routes/app_routes.dart'; // Import AppRoutes

/// Manages security question related authentication flows.
class AuthSecurityManager {
  final ApiService _apiService;
  final StorageService _storageService;
  final AuthControllerCallbacks _callbacks;

  AuthSecurityManager(this._apiService, this._storageService, this._callbacks);

  /// Sets a security question and answer for the logged-in user.
  Future<void> setSecurityQuestion(String email, String question, String answer) async {
    // Validation is assumed to be done by the controller before calling this.
    try {
      _callbacks.setIsLoading(true); // Set loading state

      // Call API service to set security question
      await _apiService.auth.setSecurityQuestion(email, question, answer);

      // Show success feedback
          _callbacks.showSnackbar(
                'success'.tr,
                'security_question_updated'.tr,
                backgroundColor: Get.theme.colorScheme.secondary,
                colorText: Get.theme.colorScheme.onSecondary,
                snackPosition: SnackPosition.TOP,
              );

      // Navigate after success
      _callbacks.navigateOffAll(AppRoutes.getHomePage()); // Navigate to Home

    } catch (e) {
      // Handle API or other errors
      _callbacks.showSnackbar(
        'error'.tr,
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      _callbacks.setIsLoading(false); // Reset loading state
    }
  }

  /// Verifies a security answer for password recovery and returns a reset token.
  /// The controller will handle navigation after receiving the token.
  Future<String?> verifySecurityAnswer(String email, String question, String answer) async {
    // Validation is assumed to be done by the controller before calling this.
    try {
      _callbacks.setIsLoading(true); // Set loading state

      // Call API service to verify security answer
      final response = await _apiService.auth.verifySecurityAnswer(
        email, // Use the passed email
        question, // Use the passed question
        answer // Use the passed answer
      );

      final resetToken = response['resetToken'];
      if (resetToken == null) {
         throw Exception('reset_token_missing'.tr);
      }
       return resetToken; // Return the token on success

    } catch (e) {
      // Handle API or other errors
      print('Verify security answer error: $e');
      String errorMessage = e.toString().replaceFirst('Exception: ', '');

      // Map specific errors
      if (errorMessage.contains('FormatException')) {
        errorMessage = 'invalid_data_format'.tr;
      } else if (errorMessage.contains('Security answer incorrect')) {
        _callbacks.setSecurityAnswerError('security_answer_incorrect'.tr); // Set specific error on controller
        errorMessage = 'security_answer_incorrect'.tr; // Also show in snackbar
      }

      _callbacks.showSnackbar(
        'error'.tr,
        errorMessage,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
       return null; // Indicate failure

    } finally {
      _callbacks.setIsLoading(false); // Reset loading state
    }
  }
}