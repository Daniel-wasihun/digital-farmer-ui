import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// Controller for Feedback Screen logic and state
class FeedbackController extends GetxController {
  // Dependencies
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final TextEditingController feedbackTextController = TextEditingController();

  // Observable states
  var isLoading = false.obs;
  var feedbackError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    resetState();
  }

  @override
  void onClose() {
    feedbackTextController.dispose();
    super.onClose();
  }

  // Reset form state
  void resetState() {
    feedbackTextController.clear();
    feedbackError.value = '';
    isLoading.value = false;
  }

  // Validate feedback input
  void validateFeedback(String value) {
    feedbackError.value = value.trim().isEmpty ? 'Feedback cannot be empty' : '';
  }

  // Submit feedback
  Future<void> submitFeedback() async {
    validateFeedback(feedbackTextController.text);
    if (feedbackError.value.isNotEmpty) {
      _showError(feedbackError.value);
      return;
    }

    final token = _storageService.getToken();
    if (token == null) {
      _showError('Please log in to submit feedback');
      return;
    }

    try {
      isLoading.value = true;
      await _apiService.feedback.submitFeedback(feedbackTextController.text);

      // Show success snackbar and delay navigation
      Get.rawSnackbar(
        title: 'Success',
        message: 'Feedback submitted successfully',
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );

      resetState();
      // Delay navigation to ensure snackbar is visible
      Get.offAllNamed(AppRoutes.getHomePage());
    } catch (e) {
      _showError('Failed to submit feedback. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to show error snackbar
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }
}