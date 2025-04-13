import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/glassmorphic_card.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.2 : 1.0;
    final usernameController = TextEditingController();
    final bioController = TextEditingController();
    // Profile picture handling (simplified, no actual upload for now)
    final profilePictureController = TextEditingController();

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
                    Text(
                      'update_profile'.tr,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 22 * scaleFactor,
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    CustomTextField(
                      label: 'username'.tr,
                      controller: usernameController,
                      prefixIcon: Icons.person,
                      errorText: authController.usernameError.value,
                      onChanged: (value) => authController.validateUsername(value),
                      scaleFactor: scaleFactor,
                    ),
                    SizedBox(height: 10 * scaleFactor),
                    CustomTextField(
                      label: 'bio'.tr,
                      controller: bioController,
                      prefixIcon: Icons.info,
                      errorText: authController.bioError.value,
                      onChanged: (value) => authController.validateBio(value),
                      scaleFactor: scaleFactor,
                      
                      // maxLines: 3,
                    ),
                    SizedBox(height: 10 * scaleFactor),
                    CustomTextField(
                      label: 'profile_picture_url'.tr,
                      controller: profilePictureController,
                      prefixIcon: Icons.image,
                      scaleFactor: scaleFactor,
                    ),
                    SizedBox(height: 16 * scaleFactor),
                    ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              authController.updateProfile(
                                usernameController.text,
                                bioController.text,
                                profilePictureController.text.isEmpty
                                    ? null
                                    : profilePictureController.text,
                              );
                            },
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: authController.isLoading.value
                          ? SizedBox(
                              width: 24 * scaleFactor,
                              height: 24 * scaleFactor,
                              child: CircularProgressIndicator(
                                strokeWidth: 2 * scaleFactor,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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