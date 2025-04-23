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
    final scaleFactor = isTablet ? 1.1 : 0.9; // Reduced base scaleFactor

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text(
          'update_profile'.tr,
          style: TextStyle(
                fontSize: 16 * scaleFactor, // Smaller app bar title
                fontWeight: FontWeight.w600,
              ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
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
              padding: EdgeInsets.all(12 * scaleFactor), // Reduced padding
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
                              fontSize: 18 * scaleFactor, // Smaller title
                              fontWeight: FontWeight.w700,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 12 * scaleFactor), // Reduced spacing
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                                  blurRadius: 6, // Slightly smaller shadow
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 40 * scaleFactor, // Smaller avatar
                              backgroundColor: Theme.of(context).colorScheme.surface,
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
                                      size: 40 * scaleFactor, // Match avatar
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                                padding: EdgeInsets.all(3 * scaleFactor), // Smaller edit button
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Theme.of(context).colorScheme.onSecondary, width: 1.5),
                                ),
                                child: Icon(
                                  Icons.edit,
                                  size: 16 * scaleFactor, // Smaller icon
                                  color: Theme.of(context).colorScheme.onSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8 * scaleFactor), // Reduced spacing
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
                        keyboardType: TextInputType.text,
                        obscureText: false,
                      ),
                    ),
                    SizedBox(height: 6 * scaleFactor), // Reduced spacing
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
                    SizedBox(height: 12 * scaleFactor), // Reduced spacing
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
                        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                              padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(vertical: 8 * scaleFactor)), // Smaller button
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6 * scaleFactor),
                                ),
                              ),
                              elevation: WidgetStateProperty.all(3),
                            ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 20 * scaleFactor,
                                height: 20 * scaleFactor,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5 * scaleFactor,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).colorScheme.onPrimary),
                                ),
                              )
                            : Text(
                                'update_profile'.tr,
                                style: Theme.of(context)
                                    .elevatedButtonTheme
                                    .style!
                                    .textStyle!
                                    .resolve({})
                                    // .copyWith(fontSize: 12 * scaleFactor), // Smaller text
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