import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class UpdateProfileController extends GetxController {
  final ApiService _apiService = Get.put(ApiService()); // Changed to Get.find
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  var username = ''.obs;
  var bio = ''.obs;
  var profilePictureUrl = ''.obs;
  var selectedImage = Rx<File?>(null);

  var usernameError = ''.obs;
  var bioError = ''.obs;
  var isLoading = false.obs;

  late TextEditingController usernameController;
  late TextEditingController bioController;

  @override
  void onInit() {
    super.onInit();
    print('UpdateProfileController onInit');
    usernameController = TextEditingController();
    bioController = TextEditingController();
    loadUserData();
  }

  @override
  void onClose() {
    print('UpdateProfileController onClose');
    usernameController.dispose();
    bioController.dispose();
    super.onClose();
  }

  void loadUserData() {
    final user = _storageService.getUser();
    if (user != null) {
      print('Loading user data: ${user['email']}');
      username.value = user['username'] ?? '';
      bio.value = user['bio'] ?? '';
      profilePictureUrl.value = user['profilePicture'] ?? '';
      print('Profile picture from storage: ${profilePictureUrl.value}');
      usernameController.text = username.value;
      bioController.text = bio.value;
    } else {
      print('No user data found');
      Get.snackbar('error'.tr, 'user_not_found'.tr,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void validateUsername(String value) {
    print('Validating username: ${value.isEmpty ? "empty" : value}');
    if (value.isEmpty) {
      usernameError.value = 'username_required'.tr;
    } else if (value.length < 3) {
      usernameError.value = 'username_too_short'.tr;
    } else {
      usernameError.value = '';
    }
  }

  void validateBio(String value) {
    print('Validating bio: ${value.isEmpty ? "empty" : "non-empty"}');
    if (value.length > 200) {
      bioError.value = 'bio_too_long'.tr;
    } else {
      bioError.value = '';
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        print('Image picked: ${image.path}');
        selectedImage.value = File(image.path);
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Image picker error: $e');
      Get.snackbar('error'.tr, 'image_pick_failed'.tr,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateProfile() async {
    validateUsername(username.value);
    validateBio(bio.value);

    if (usernameError.value.isNotEmpty || bioError.value.isNotEmpty) {
      print('Validation failed: usernameError=${usernameError.value}, bioError=${bioError.value}');
      Get.snackbar('error'.tr, 'fix_form_errors'.tr,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      if (user == null) {
        print('No user found');
        throw Exception('user_not_found'.tr);
      }
      print('Updating profile for: ${user['email']}, username=${username.value}, bio=${bio.value}, image=${selectedImage.value?.path}');

      final updatedUser = await _apiService.updateProfile(
        user['email'],
        username.value,
        bio.value.isEmpty ? null : bio.value,
        selectedImage.value,
      );
      print('Backend response: $updatedUser');

      await _storageService.saveUser({
        'username': updatedUser['username'],
        'email': updatedUser['email'],
        'profilePicture': updatedUser['profilePicture'] ?? '',
        'bio': updatedUser['bio'] ?? '',
        'role': updatedUser['role'] ?? 'user',
      });

      profilePictureUrl.value = updatedUser['profilePicture'] ?? '';
      selectedImage.value = null;

      imageCache.clear();
      imageCache.clearLiveImages();
      print('Image cache cleared');

      print('Profile updated: profilePicture=${updatedUser['profilePicture']}');
      Get.snackbar('success'.tr, 'profile_updated_successfully'.tr,
          backgroundColor: Colors.green, colorText: Colors.white);

      await Future.delayed(Duration(milliseconds: 500));
      Get.back();
    } catch (e) {
      print('Update profile error: $e');
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      if (errorMessage.contains('Username is already in use')) {
        errorMessage = 'username_already_in_use'.tr;
      }
      Get.snackbar('error'.tr, errorMessage,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      print('isLoading reset to false');
    }
  }
}