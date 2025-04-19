import '../../../../services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math; // Import math for max and clamp
import '../../../../controllers/update_profile_controller.dart'; // Keep your controller import
import '../../../widgets/custom_text_field.dart';

class UpdateProfileScreen extends GetView<UpdateProfileController> {
  const UpdateProfileScreen({super.key}); // Use const constructor

  @override
  Widget build(BuildContext context) {
    // Access the controller using 'controller' property provided by GetView
    // final UpdateProfileController controller = Get.find<UpdateProfileController>();

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // --- Responsive Breakpoints (Copied from ChangePasswordScreen style) ---
    const double tinyPhoneMaxWidth = 300;
    const double verySmallPhoneMaxWidth = 360;
    const double smallPhoneMaxWidth = 480;
    const double compactTabletMinWidth = 600;
    const double largeTabletMinWidth = 800;
    const double desktopMinWidth = 1000;

    final bool isTinyPhone = size.width < tinyPhoneMaxWidth;
    final bool isVerySmallPhone = size.width >= tinyPhoneMaxWidth && size.width < verySmallPhoneMaxWidth;
    final bool isSmallPhone = size.width >= verySmallPhoneMaxWidth && size.width < smallPhoneMaxWidth;
    final bool isCompactTablet = size.width >= compactTabletMinWidth && size.width < largeTabletMinWidth;
    final bool isLargeTablet = size.width >= largeTabletMinWidth && size.width < desktopMinWidth;
    final bool isDesktop = size.width >= desktopMinWidth;

    // --- Responsive Scale Factor (Copied from ChangePasswordScreen style) ---
    final double scaleFactor = isDesktop
        ? 1.2
        : isLargeTablet
            ? 1.1
            : isCompactTablet
                ? 1.0
                : isSmallPhone
                    ? 0.9
                    : isVerySmallPhone
                        ? 0.75
                        : isTinyPhone
                            ? 0.6
                            : 1.0;

    // --- Responsive Constraints (Copied from ChangePasswordScreen style) ---
    final double maxFormWidth = isDesktop
        ? 600
        : isLargeTablet
            ? 500
            : isCompactTablet
                ? 400
                : size.width * (isTinyPhone ? 0.95 : isVerySmallPhone ? 0.92 : 0.9);
    // Note: maxFormHeight is less critical here if content is scrollable, removed the height constraint

    // --- Responsive Padding (Copied from ChangePasswordScreen style) ---
    final double cardPadding = math.max(8.0, 16.0 * scaleFactor).clamp(16.0, 32.0); // Adjusted range for potentially larger card

    // --- Responsive Font Sizes (Adjusted slightly for profile screen context) ---
    final double baseTitleFontSize = 20.0; // Page title
    final double baseAppBarFontSize = 18.0; // App bar title
    final double baseFieldLabelFontSize = 12.0;
    final double baseFieldValueFontSize = 14.0;
    final double baseButtonFontSize = 16.0; // Button text

    final double titleFontSize = (baseTitleFontSize * scaleFactor).clamp(18.0, 24.0); // Clamped
    final double appBarFontSize = (baseAppBarFontSize * scaleFactor).clamp(16.0, 20.0); // Clamped
    final double fieldLabelFontSize = (baseFieldLabelFontSize * scaleFactor).clamp(10.0, 14.0);
    final double fieldValueFontSize = (baseFieldValueFontSize * scaleFactor).clamp(12.0, 16.0);
    final double buttonFontSize = (baseButtonFontSize * scaleFactor).clamp(14.0, 18.0); // Clamped

    // --- Responsive Icon Sizes ---
    final double iconSize = (20.0 * scaleFactor).clamp(18.0, 24.0); // Standard icon size
    final double avatarIconSize = (40.0 * scaleFactor).clamp(35.0, 50.0); // For person icon in avatar
    final double editIconSize = (16.0 * scaleFactor).clamp(14.0, 20.0); // For edit icon on avatar

    // --- Responsive Loader Size ---
    final double loaderSize = (24.0 * scaleFactor).clamp(20.0, 30.0); // Loader size

    // --- Responsive Spacing (Copied from ChangePasswordScreen style) ---
    // final double spacingExtraSmall = math.max(4.0, 6 * scaleFactor); // Added smaller spacing
    // final double spacingSmall = math.max(8.0, 10 * scaleFactor);
    final double spacingMedium = math.max(12.0, 16 * scaleFactor);
    final double spacingLarge = math.max(18.0, 24 * scaleFactor);
    // final double spacingExtraLarge = math.max(24.0, 32 * scaleFactor); // Added larger spacing


    // --- Consistent Vertical Padding for Text Fields (Copied) ---
    final double consistentVerticalPadding = math.max(12.0, 14 * scaleFactor); // Adjusted base


    return Scaffold(
      appBar: AppBar(
        elevation: 4, // Kept elevation
        title: Text(
          'update_profile'.tr,
          style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                fontSize: appBarFontSize, // Use responsive size
                fontWeight: FontWeight.w600,
              ) ??
              TextStyle( // Fallback style
                fontSize: appBarFontSize, // Use responsive size
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary, // Assuming onPrimary
              ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary, // Use foregroundColor or onPrimary fallback
              size: iconSize, // Use responsive size
            ),
          onPressed: () {
            print('AppBar back button pressed');
            // You might want to dispose of controllers/clear state here if their lifecycle isn't tied to the route binding
            // controller.resetState(); // Example if you had resetState in UpdateProfileController
            Get.back();
          },
        ),
      ),
      // Using Builder to ensure context is available if needed later (optional here)
      body: Builder(
        builder: (context) {
          return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxFormWidth.clamp(300, 700), // Adjusted clamp range
            // Removed maxHeight constraint for better scrolling
          ),
          child: AnimatedPadding( // Using AnimatedPadding from ChangePasswordScreen example
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: size.width * (isTinyPhone ? 0.03 : 0.04)), // Apply horizontal padding based on screen size
            // Replaced GlassmorphicCard with standard Card
            child: Card(
              elevation: isDarkMode ? 2.0 : 4.0, // Responsive elevation
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(math.max(8.0, 12 * scaleFactor))), // Responsive border radius
              clipBehavior: Clip.antiAlias, // Needed for rounded corners
              child: Padding(
                padding: EdgeInsets.all(cardPadding), // Use responsive card padding
                child: SingleChildScrollView( // Allows content to scroll
                  child: Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        AnimatedOpacity( // Keep animation for loading state
                          opacity: controller.isLoading.value ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            'update_profile'.tr,
                            style: theme.textTheme.headlineSmall?.copyWith( // Using headlineSmall as it's common for titles
                                  fontSize: titleFontSize, // Use responsive size
                                  fontWeight: FontWeight.w600, // Adjusted weight
                                  color: theme.colorScheme.primary, // Example primary color
                              ) ?? // Fallback style
                            TextStyle(
                                  fontSize: titleFontSize, // Use responsive size
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: spacingLarge), // Use responsive spacing
                        // Avatar Section
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [ // Use theme colors for shadow
                                    BoxShadow(
                                      color: theme.colorScheme.shadow.withOpacity(isDarkMode ? 0.5 : 0.2), // Adjust shadow color/opacity based on theme/mode
                                      blurRadius: 8 * scaleFactor, // Responsive blur
                                      spreadRadius: 2 * scaleFactor, // Responsive spread
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 48 * scaleFactor, // Use responsive size
                                  backgroundColor: theme.colorScheme.surface, // Use theme color
                                  // Logic for displaying selected image or profile URL
                                backgroundImage: controller.selectedImage.value != null
                                    ? FileImage(controller.selectedImage.value!)
                                    : controller.profilePictureUrl.value.isNotEmpty
                                        ? NetworkImage(
                                             // Ensure the URL is correctly formed
                                            '${BaseApi.imageBaseUrl}/uploads/${controller.profilePictureUrl.value.split('/').last.split('\\').last}',
                                          ) as ImageProvider<Object>? // Cast to ImageProvider
                                        : null,
                                  onBackgroundImageError: (error, stackTrace) {
                                     print('Image load error: $error, URL: ${controller.profilePictureUrl.value}');
                                      // Clear the URL on error so the default icon shows
                                     controller.profilePictureUrl.value = '';
                                   },
                                  child: controller.profilePictureUrl.value.isEmpty &&
                                        controller.selectedImage.value == null
                                      ? Icon(
                                          Icons.person,
                                          size: avatarIconSize, // Use responsive size
                                          color: theme.colorScheme.onSurface.withOpacity(0.6), // Use theme color
                                        )
                                      : null,
                                ),
                              ),
                              // Edit icon on avatar
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: controller.isLoading.value // Disable tap when loading
                                      ? null
                                      : () {
                                          print('Picking image from gallery');
                                          controller.pickImage();
                                        },
                                  child: Container(
                                    padding: EdgeInsets.all(4 * scaleFactor), // Use responsive padding
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondary, // Use theme color
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: theme.colorScheme.onSecondary, width: 2), // Use theme color, Adjusted border width
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: editIconSize, // Use responsive size
                                      color: theme.colorScheme.onSecondary, // Use theme color
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: spacingMedium), // Use responsive spacing
                        // Username Field
                        AnimatedOpacity( // Keep animation for loading state
                          opacity: controller.isLoading.value ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: CustomTextField(
                            label: 'username'.tr,
                            controller: controller.usernameController, // Assuming controller has this
                            prefixIcon: Icons.person,
                            errorText: controller.usernameError.value.isEmpty // Assuming controller has this error
                                ? null
                                : controller.usernameError.value,
                            enabled: !controller.isLoading.value, // Disable when loading
                            onChanged: (value) {
                                // Update observable and validate
                              controller.username.value = value; // Assuming controller has this observable
                              controller.validateUsername(value); // Assuming controller has this method
                            },
                            scaleFactor: scaleFactor, // Apply scale factor
                            fontSize: fieldValueFontSize, // Apply responsive font size
                            labelFontSize: fieldLabelFontSize, // Apply responsive label size
                            iconSize: iconSize, // Apply responsive icon size
                            contentPadding: EdgeInsets.symmetric(
                                 horizontal: math.max(10.0, 12 * scaleFactor), // Adjusted horizontal padding
                                 vertical: consistentVerticalPadding, // Apply responsive vertical padding
                              ),
                            borderRadius: math.max(6.0, 8 * scaleFactor), // Responsive border radius
                            filled: true, // Example filled property
                            fillColor: theme.colorScheme.onSurface.withOpacity(0.05), // Example fill color

                            keyboardType: TextInputType.text,
                            obscureText: false, // Not a password field
                          ),
                        ),
                        // Bio Field
                        AnimatedOpacity( // Keep animation for loading state
                          opacity: controller.isLoading.value ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: CustomTextField(
                            label: 'bio'.tr,
                            controller: controller.bioController, // Assuming controller has this
                            prefixIcon: Icons.info,
                            errorText: controller.bioError.value.isEmpty // Assuming controller has this error
                                ? null
                                : controller.bioError.value,
                            enabled: !controller.isLoading.value, // Disable when loading
                            onChanged: (value) {
                                // Update observable and validate
                              controller.bio.value = value; // Assuming controller has this observable
                              controller.validateBio(value); // Assuming controller has this method
                            },
                            scaleFactor: scaleFactor, // Apply scale factor
                            fontSize: fieldValueFontSize, // Apply responsive font size
                            labelFontSize: fieldLabelFontSize, // Apply responsive label size
                            iconSize: iconSize, // Apply responsive icon size
                            contentPadding: EdgeInsets.symmetric(
                                 horizontal: math.max(10.0, 12 * scaleFactor), // Adjusted horizontal padding
                                 vertical: consistentVerticalPadding, // Apply responsive vertical padding
                              ),
                            borderRadius: math.max(6.0, 8 * scaleFactor), // Responsive border radius
                            filled: true, // Example filled property
                            fillColor: theme.colorScheme.onSurface.withOpacity(0.05), // Example fill color
                            keyboardType: TextInputType.multiline,
                            obscureText: false,
                          ),
                        ),
                        AnimatedScale( // Keep animation for loading state
                          scale: controller.isLoading.value ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value // Disable when loading
                                ? null
                                : () {
                                      print('Update profile button pressed');
                                      controller.updateProfile(); // Call the controller method
                                    },
                            style: ElevatedButton.styleFrom( // Use ElevatedButton.styleFrom for consistency
                                  padding: EdgeInsets.symmetric(vertical: math.max(10.0, 14 * scaleFactor)), // Responsive padding
                                  shape: RoundedRectangleBorder( // Use RoundedRectangleBorder directly
                                      borderRadius: BorderRadius.circular(math.max(6.0, 8 * scaleFactor)), // Responsive border radius
                                  ),
                                  elevation: 3, // Kept elevation
                                textStyle: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.w600), // Apply responsive size and weight
                            ),
                        child: controller.isLoading.value // Show loader when loading
                            ? SizedBox(
                                width: loaderSize, // Use responsive size
                                height: loaderSize, // Use responsive size
                                child: CircularProgressIndicator(
                                  strokeWidth: math.max(1.5, 2.0 * scaleFactor), // Responsive stroke width
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onPrimary), // Use theme color
                                ),
                              )
                            : Text(
                                'update_profile'.tr.toUpperCase(), // Uppercase button text
                                style: TextStyle(fontSize: buttonFontSize), // Apply responsive font size
                              ),
                      ),
                        
                    ),],
                  ),
                )
              ),
            ),
          ),
        )));
        }
      ),
    );
  }
}