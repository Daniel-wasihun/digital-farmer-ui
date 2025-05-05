import 'dart:io';
import 'dart:typed_data';
import 'package:agri/routes/app_routes.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class UpdateProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final ImagePicker _picker = ImagePicker();

  var username = ''.obs;
  var bio = ''.obs;
  var profilePictureUrl = ''.obs;
  var selectedImageBytes = Rx<Uint8List?>(null); // Store bytes for web
  var selectedImageFile = Rx<File?>(null); // Store File for mobile
  var selectedImageName = ''.obs; // Store image name for web

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
      Get.snackbar('Error', 'User not found.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void validateUsername(String value) {
    print('Validating username: ${value.isEmpty ? "empty" : value}');
    if (value.isEmpty) {
      usernameError.value = 'Username is required.';
    } else if (value.length < 3) {
      usernameError.value = 'Username must be at least 3 characters.';
    } else {
      usernameError.value = '';
    }
  }

  void validateBio(String value) {
    print('Validating bio: ${value.isEmpty ? "empty" : "non-empty"}');
    if (value.length > 200) {
      bioError.value = 'Bio must not exceed 200 characters.';
    } else {
      bioError.value = '';
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          selectedImageBytes.value = await pickedFile.readAsBytes();
          selectedImageName.value = pickedFile.name;
          selectedImageFile.value = null;
          print('Web image picked: ${pickedFile.name}, size: ${selectedImageBytes.value?.length}');
        } else {
          final file = File(pickedFile.path);
          final fileSize = await file.length();
          if (fileSize > 5 * 1024 * 1024) {
            Get.snackbar('Error', 'Image size must not exceed 5MB.',
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            return;
          }
          selectedImageFile.value = file;
          selectedImageBytes.value = null;
          selectedImageName.value = pickedFile.name;
          print('Mobile image picked: ${pickedFile.path}, size: $fileSize');
        }
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Image picker error: $e');
      Get.snackbar('Error', 'Failed to pick image. Please try again.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  Future<void> updateProfile() async {
    validateUsername(username.value);
    validateBio(bio.value);

    if (usernameError.value.isNotEmpty || bioError.value.isNotEmpty) {
      print('Validation failed: usernameError=${usernameError.value}, bioError=${bioError.value}');
      Get.snackbar('Error', 'Please fix the errors in the form.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      final user = _storageService.getUser();
      if (user == null) {
        print('No user found');
        throw Exception('User not found');
      }

      dynamic imageToUpload;
      String? imageNameToSend;

      if (kIsWeb && selectedImageBytes.value != null) {
        imageToUpload = selectedImageBytes.value;
        imageNameToSend = selectedImageName.value;
        print('Preparing web image for upload: $imageNameToSend, size: ${imageToUpload.length}');
      } else if (selectedImageFile.value != null) {
        imageToUpload = selectedImageFile.value;
        imageNameToSend = selectedImageFile.value?.path.split('/').last;
        print('Preparing mobile image for upload: ${imageToUpload.path}, name: $imageNameToSend');
      } else {
        imageToUpload = null;
        imageNameToSend = null;
        print('No image selected for upload.');
      }

      print('Updating profile for: ${user['email']}, username=${username.value}, bio=${bio.value}, image=${imageToUpload.runtimeType}, name=$imageNameToSend');

      final updatedUser = await _apiService.user.updateProfile(
        user['email'],
        username.value,
        bio.value.isEmpty ? null : bio.value,
        imageToUpload,
        imageNameToSend,
      );
      print('Backend response: $updatedUser');

      await _storageService.saveUser({
        'username': updatedUser['username'],
        'email': updatedUser['email'],
        'profilePicture': updatedUser['profilePicture'] ?? '',
        'bio': updatedUser['bio'] ?? '',
        'role': updatedUser['role'] ?? 'user',
        '_id': user['_id'],
      });

      profilePictureUrl.value = updatedUser['profilePicture'] ?? '';
      selectedImageBytes.value = null;
      selectedImageFile.value = null;
      selectedImageName.value = '';

      imageCache.clear();
      imageCache.clearLiveImages();
      print('Image cache cleared');

      print('Profile updated: profilePicture=${updatedUser['profilePicture']}');
      Get.snackbar('Success', 'Profile updated successfully.',
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
          colorText: Colors.white);
      Get.offAllNamed(AppRoutes.getHomePage());
    } catch (e) {
      print('Update profile error: $e');
      Get.snackbar('Error', 'Failed to update profile. Please try again.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      print('isLoading reset to false');
    }
  }
}