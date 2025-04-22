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
            Get.snackbar('error'.tr, 'image_too_large'.tr,
                backgroundColor: Colors.redAccent, colorText: Colors.white);
            return;
          }
          selectedImageFile.value = file;
          selectedImageBytes.value = null;
          selectedImageName.value = pickedFile.name; // May not be the full path
          print('Mobile image picked: ${pickedFile.path}, size: $fileSize');
        }
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Image picker error: $e');
      String errorMessage = 'image_pick_failed'.tr;
      if (e.toString().contains('permission')) {
        errorMessage = 'image_permission_denied'.tr;
      } else if (e.toString().contains('Unsupported operation')) {
        errorMessage = 'image_pick_platform_unsupported'.tr;
      }
      Get.snackbar('error'.tr, errorMessage,
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }


 Future<void> updateProfile() async {
   // Assuming validateUsername and validateBio methods are available (e.g., from a mixin)
   validateUsername(username.value);
   validateBio(bio.value);

   if (usernameError.value.isNotEmpty || bioError.value.isNotEmpty) {
     print(
         'Validation failed: usernameError=${usernameError.value}, bioError=${bioError.value}');
     Get.snackbar('error'.tr, 'fix_form_errors'.tr,
         backgroundColor: Colors.redAccent, colorText: Colors.white);
     return;
   }

   try {
     isLoading.value = true;
     final user = _storageService.getUser(); // Assuming _storageService is available
     if (user == null) {
       print('No user found');
       throw Exception('user_not_found'.tr);
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

     print(
         'Updating profile for: ${user['email']}, username=${username.value}, bio=${bio.value}, image=${imageToUpload.runtimeType}, name=$imageNameToSend');

     // Assuming _apiService is available and has a user.updateProfile method matching the signature
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

     // Update observable states in the controller
     profilePictureUrl.value = updatedUser['profilePicture'] ?? '';
     selectedImageBytes.value = null;
     selectedImageFile.value = null;
     selectedImageName.value = '';

     // Clear image cache
     imageCache.clear();
     imageCache.clearLiveImages();
     print('Image cache cleared');

     print('Profile updated: profilePicture=${updatedUser['profilePicture']}');
     Get.snackbar('success'.tr, 'profile_updated_successfully'.tr,
         duration: const Duration(seconds: 2), // Using const Duration is good practice
         backgroundColor: Colors.green,
         colorText: Colors.white);
     Get.offAllNamed(AppRoutes.getHomePage()); // Assuming AppRoutes is available
   } catch (e) {
     print('Update profile error: $e');
     String errorMessage = e.toString().replaceFirst('Exception: ', '');

     // --- UPDATED ERROR HANDLING ---
     if (errorMessage.contains('EPERM: operation not permitted')) {
         // Check specifically for the file permission error message from the backend
         errorMessage = 'file_permission_error'.tr; // Use a new translation key for this specific error
     } else if (errorMessage.contains('Username is already in use')) {
       errorMessage = 'username_already_in_use'.tr;
     } else if (errorMessage.contains('Unsupported file type')) {
       errorMessage = 'unsupported_image_format'.tr;
     } else if (errorMessage.contains('Failed to process image')) {
        // This general check remains, but it will only be reached if the error
        // contains "Failed to process image" but *doesn't* contain the EPERM part,
        // or if "Failed to process image" is a more generic error from the backend.
       errorMessage = 'image_processing_failed'.tr;
     } else if (errorMessage.contains('Image file too large')) {
       errorMessage = 'image_too_large'.tr;
     } else if (errorMessage.contains('image_name_required_for_web')) {
       errorMessage = 'image_name_required_for_web'.tr;
     } else if (errorMessage.contains('unsupported_image_type')) {
       errorMessage = 'unsupported_image_type'.tr;
     } else {
        // Fallback for any other unexpected errors not explicitly handled above
        // This helps during debugging by showing the original error message.
       errorMessage = 'An unexpected error occurred: $errorMessage';
     }
     // --- END UPDATED ERROR HANDLING ---

     Get.snackbar('error'.tr, errorMessage,
         backgroundColor: Colors.redAccent, colorText: Colors.white);
   } finally {
     isLoading.value = false;
     print('isLoading reset to false');
   }
 
 }
 }