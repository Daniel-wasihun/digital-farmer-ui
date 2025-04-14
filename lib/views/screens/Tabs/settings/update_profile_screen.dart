import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/update_profile_controller.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/glassmorphic_card.dart';
import '../../../../services/api_service.dart';

class UpdateProfileScreen extends GetView<UpdateProfileController> {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        title: Text(
          'update_profile'.tr,
          style: TextStyle(
            fontSize: 18 * scaleFactor,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            print('AppBar back button pressed');
            Get.back();
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isTablet ? 600 : size.width * 0.9,
          ),
          child: GlassmorphicCard(
            child: Padding(
              padding: EdgeInsets.all(16 * scaleFactor),
              child: Obx(
                () => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedOpacity(
                      opacity: controller.isLoading.value ? 0.5 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        'update_profile'.tr,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontSize: 22 * scaleFactor,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue.shade700,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50 * scaleFactor,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: controller.selectedImage.value != null
                                  ? FileImage(controller.selectedImage.value!)
                                  : controller.profilePictureUrl.value.isNotEmpty
                                      ? NetworkImage(
                                          '${ApiService.imageBaseUrl}/uploads/${controller.profilePictureUrl.value.replaceFirst(RegExp(r'[/\\]?[uU][pP][lL][oO][aA][dD][sS][/\\]?'), '')}',
                                        )
                                      : null,
                              onBackgroundImageError: controller.profilePictureUrl.value.isNotEmpty
                                  ? (error, stackTrace) {
                                      print('Image load error: $error, URL: ${controller.profilePictureUrl.value}');
                                      controller.profilePictureUrl.value = '';
                                    }
                                  : null,
                              child: controller.profilePictureUrl.value.isEmpty &&
                                      controller.selectedImage.value == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50 * scaleFactor,
                                      color: Colors.grey.shade600,
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: controller.isLoading.value
                                  ? null
                                  : () {
                                      print('Picking image from gallery');
                                      controller.pickImage();
                                    },
                              child: Container(
                                padding: EdgeInsets.all(4 * scaleFactor),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 20 * scaleFactor,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    AnimatedOpacity(
                      opacity: controller.isLoading.value ? 0.5 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: CustomTextField(
                        label: 'username'.tr,
                        controller: controller.usernameController,
                        prefixIcon: Icons.person,
                        errorText: controller.usernameError.value.isEmpty
                            ? null
                            : controller.usernameError.value,
                        enabled: !controller.isLoading.value,
                        onChanged: (value) {
                          controller.username.value = value;
                          controller.validateUsername(value);
                        },
                        scaleFactor: scaleFactor,
                      ),
                    ),
                    SizedBox(height: 10 * scaleFactor),
                    AnimatedOpacity(
                      opacity: controller.isLoading.value ? 0.5 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: CustomTextField(
                        label: 'bio'.tr,
                        controller: controller.bioController,
                        prefixIcon: Icons.info,
                        errorText: controller.bioError.value.isEmpty
                            ? null
                            : controller.bioError.value,
                        enabled: !controller.isLoading.value,
                        onChanged: (value) {
                          controller.bio.value = value;
                          controller.validateBio(value);
                        },
                        scaleFactor: scaleFactor,
                        keyboardType: TextInputType.multiline,
                        obscureText: false,
                      ),
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    AnimatedScale(
                      scale: controller.isLoading.value ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                print('Update profile button pressed');
                                controller.updateProfile();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12 * scaleFactor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                          ),
                          elevation: 4,
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 24 * scaleFactor,
                                height: 24 * scaleFactor,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2 * scaleFactor,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'update_profile'.tr,
                                style: TextStyle(
                                  fontSize: 14 * scaleFactor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}