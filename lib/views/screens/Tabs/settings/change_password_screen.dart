import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Import math for clamp and max

// Import the AuthController if it's in a different path
import '../../../../controllers/auth/auth_controller.dart'; // Adjust the path as needed

// Import your CustomTextField widget
import '../../../widgets/custom_text_field.dart';


class ChangePasswordScreen extends GetView<AuthController> {
  const ChangePasswordScreen({super.key});

  // Static method to show the screen as a dialog
  static void show() {
    Get.dialog(
      const ChangePasswordScreen(),
      // Make the barrier interactive to dismiss on tap outside
      barrierDismissible: true,
      // Use a visually appealing transition
      transitionDuration: const Duration(milliseconds: 400), // Slightly longer duration
      transitionCurve: Curves.easeInOutCubic, // Smoother transition curve
      // Optional: Add a custom transition builder if needed
      // transitionBuilder: (context, animation, secondaryAnimation, child) {
      //   return ScaleTransition(scale: animation, child: child);
      // },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Clear fields and errors using addPostFrameCallback to ensure context is ready
    // This runs once after the build method completes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("ChangePasswordScreen built, resetting state.");
      controller.resetPasswordErrors(); // Reset validation errors
      controller.currentPasswordController.clear(); // Clear text fields
      controller.newPasswordController.clear();
      controller.confirmPasswordController.clear();
      controller.isPasswordChangeSuccess.value = false; // Reset success state in controller
    });


    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // --- Responsive Breakpoints (Consistent with previous examples) ---
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


    // --- Responsive Scale Factor (Consistent with previous examples) ---
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


    // --- Responsive Constraints ---
    // Max width for the dialog content box
    final double maxContentWidth = isDesktop
        ? 600
        : isLargeTablet
            ? 500
            : isCompactTablet
                ? 400
                : size.width * (isTinyPhone ? 0.95 : isVerySmallPhone ? 0.92 : 0.9);

    // Max height for the dialog content box (allowing scrolling if needed)
    // Adjusted height based on scale factor and screen size
     final double maxContentHeight = (size.height * 0.75 * scaleFactor).clamp(300.0, 550.0); // Increased max height and added clamping

    // --- Responsive Padding (for the dialog inset and card content) ---
    // Increased overall horizontal padding for the dialog inset
    final double dialogHorizontalPadding = (size.width * 0.05 * scaleFactor).clamp(16.0, 40.0); // Min 16, Max 40
    // Padding inside the card
    final double cardContentPadding = (16.0 * scaleFactor).clamp(12.0, 24.0); // Min 12, Max 24

    // --- Responsive Font Sizes (Consistent with previous examples) ---
    final double baseTitleFontSize = 20.0; // Dialog title
    final double baseFieldLabelFontSize = 12.0;
    final double baseFieldValueFontSize = 14.0;
    final double baseButtonFontSize = 16.0; // Button text

    final double titleFontSize = (baseTitleFontSize * scaleFactor).clamp(16.0, 24.0); // Clamped
    final double fieldLabelFontSize = (baseFieldLabelFontSize * scaleFactor).clamp(10.0, 14.0);
    final double fieldValueFontSize = (baseFieldValueFontSize * scaleFactor).clamp(12.0, 16.0);
    final double buttonFontSize = (baseButtonFontSize * scaleFactor).clamp(14.0, 18.0); // Clamped

    // --- Responsive Icon Sizes (Consistent) ---
    final double iconSize = (20.0 * scaleFactor).clamp(18.0, 24.0); // Standard icon size
    final double closeIconSize = (20.0 * scaleFactor).clamp(18.0, 24.0); // Close button icon size

    // --- Responsive Loader Size (Consistent) ---
    final double loaderSize = (24.0 * scaleFactor).clamp(20.0, 30.0); // Loader size


    // --- Responsive Spacing (Consistent) ---
    final double spacingExtraSmall = (4.0 * scaleFactor).clamp(4.0, 8.0);
    final double spacingSmall = (8.0 * scaleFactor).clamp(8.0, 12.0);
    final double spacingMedium = (12.0 * scaleFactor).clamp(12.0, 16.0);
    final double spacingLarge = (16.0 * scaleFactor).clamp(16.0, 24.0);
    final double spacingExtraLarge = (24.0 * scaleFactor).clamp(24.0, 32.0);


    // --- Consistent Vertical Padding for Text Fields (Consistent) ---
    final double consistentVerticalPadding = (12.0 * scaleFactor).clamp(10.0, 16.0);


    // Use Dialog widget provided by Flutter for modals
    return Dialog(
      // Dialog shape and appearance
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scaleFactor)), // Increased radius
      backgroundColor: Colors.transparent, // Make dialog background transparent
      elevation: 0, // Rely on Card elevation
      // Padding around the dialog content
      insetPadding: EdgeInsets.symmetric(
          horizontal: dialogHorizontalPadding,
          vertical: spacingLarge // Vertical padding can be fixed or responsive
      ),
      // The main content constraints
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxContentWidth,
          maxHeight: maxContentHeight, // Apply responsive max height
        ),
        // Stack to position the close button over the Card
        child: Stack(
          clipBehavior: Clip.none, // Allows positioned elements outside the stack bounds
          children: [
            // The main content Card
            Card(
              // Enhanced Card styling
              elevation: isDarkMode ? 6.0 : 10.0, // Higher elevation for better shadow
              color: theme.cardColor, // Use theme.cardColor
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * scaleFactor)), // Match dialog shape
              clipBehavior: Clip.antiAlias, // Clip content to rounded corners
              // Padding inside the card
              child: Padding(
                padding: EdgeInsets.all(cardContentPadding), // Apply responsive padding
                // SingleChildScrollView to prevent overflow on smaller screens
                child: SingleChildScrollView(
                  // Wrap content in Obx to react to controller state changes
                  child: Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title Text
                        Padding(
                          padding: EdgeInsets.only(
                            top: spacingSmall, // Adjusted top padding
                            left: spacingExtraLarge, // Add padding for the close button area
                            right: spacingExtraLarge, // Add padding for the close button area
                            bottom: spacingLarge, // Increased bottom padding
                          ),
                          child: Text(
                            'change_password'.tr,
                            style: theme.textTheme.headlineSmall?.copyWith( // Use headlineSmall or titleLarge
                              fontSize: titleFontSize, // Apply responsive font size
                              fontWeight: FontWeight.bold, // Use bold for title
                              color: theme.colorScheme.primary, // Use primary color for title
                              shadows: isDarkMode ? null : [ // Subtle shadow for light mode
                                Shadow(
                                  blurRadius: 6.0,
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ) ?? // Fallback style
                             TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                             ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Current Password Field
                         AnimatedOpacity( // Fade effect based on loading
                           opacity: controller.isLoading.value ? 0.5 : 1.0,
                           duration: const Duration(milliseconds: 300),
                           child: CustomTextField(
                            label: 'current_password'.tr,
                            controller: controller.currentPasswordController,
                            obscureText: true,
                            prefixIcon: Icons.lock_outline, // Use a slightly different icon
                            errorText: controller.currentPasswordError.value.isEmpty ? null : controller.currentPasswordError.value,
                            onChanged: controller.validateCurrentPassword, // Call controller validation
                            scaleFactor: scaleFactor, // Pass scale factor
                            fontSize: fieldValueFontSize, // Apply responsive font size
                            labelFontSize: fieldLabelFontSize, // Apply responsive label size
                            iconSize: iconSize, // Apply responsive icon size
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: spacingSmall, // Responsive horizontal padding
                                vertical: consistentVerticalPadding), // Apply consistent vertical padding
                            borderRadius: 8 * scaleFactor, // Increased border radius
                            filled: true,
                            fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05), // Subtle fill color
                             enabled: !controller.isLoading.value, // Disable when loading
                          ),
                         ),
                        SizedBox(height: spacingMedium), // Responsive spacing

                        // New Password Field
                         AnimatedOpacity( // Fade effect based on loading
                           opacity: controller.isLoading.value ? 0.5 : 1.0,
                           duration: const Duration(milliseconds: 300),
                           child: CustomTextField(
                            label: 'new_password'.tr,
                            controller: controller.newPasswordController,
                            obscureText: true,
                            prefixIcon: Icons.lock,
                            errorText: controller.newPasswordError.value.isEmpty ? null : controller.newPasswordError.value,
                            onChanged: controller.validateNewPassword, // Call controller validation
                            scaleFactor: scaleFactor,
                            fontSize: fieldValueFontSize,
                            labelFontSize: fieldLabelFontSize,
                            iconSize: iconSize,
                            contentPadding: EdgeInsets.symmetric(horizontal: spacingSmall, vertical: consistentVerticalPadding),
                            borderRadius: 8 * scaleFactor,
                            filled: true,
                            fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
                             enabled: !controller.isLoading.value, // Disable when loading
                          ),
                         ),
                        SizedBox(height: spacingMedium), // Responsive spacing

                        // Confirm Password Field
                         AnimatedOpacity( // Fade effect based on loading
                           opacity: controller.isLoading.value ? 0.5 : 1.0,
                           duration: const Duration(milliseconds: 300),
                           child: CustomTextField(
                            label: 'confirm_password'.tr,
                            controller: controller.confirmPasswordController,
                            obscureText: true,
                            prefixIcon: Icons.lock_outline, // Use a slightly different icon
                            errorText: controller.confirmPasswordError.value.isEmpty ? null : controller.confirmPasswordError.value,
                            onChanged: (value) => controller.validateConfirmPassword(controller.newPasswordController.text, value), // Call controller validation
                            scaleFactor: scaleFactor,
                            fontSize: fieldValueFontSize,
                            labelFontSize: fieldLabelFontSize,
                            iconSize: iconSize,
                            contentPadding: EdgeInsets.symmetric(horizontal: spacingSmall, vertical: consistentVerticalPadding),
                            borderRadius: 8 * scaleFactor,
                            filled: true,
                            fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
                             enabled: !controller.isLoading.value, // Disable when loading
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (!controller.isLoading.value) {
                                controller.changePassword(); // Trigger change password on done
                              }
                            },
                          ),
                         ),
                        SizedBox(height: spacingLarge), // Increased spacing before button

                        // Update Password Button
                        AnimatedScale( // Scale effect based on loading
                           scale: controller.isLoading.value ? 0.95 : 1.0,
                           duration: const Duration(milliseconds: 200),
                           child: ElevatedButton(
                             // Disable button when loading
                             onPressed: controller.isLoading.value ? null : controller.changePassword, // Call controller method
                             style: ElevatedButton.styleFrom(
                               // Use theme button style or define custom style
                               // Primary button appearance
                                 backgroundColor: theme.elevatedButtonTheme.style?.backgroundColor?.resolve({WidgetState.pressed}) ?? theme.colorScheme.primary,
                                 foregroundColor: theme.elevatedButtonTheme.style?.foregroundColor?.resolve({WidgetState.pressed}) ?? theme.colorScheme.onPrimary, // Text color
                                //  disabledBackgroundColor: theme.elevatedButtonTheme.style?.disabledBackgroundColor?.resolve({}) ?? theme.colorScheme.primary.withOpacity(0.4), // Disabled background
                                //  disabledForegroundColor: theme.elevatedButtonTheme.style?.disabledForegroundColor?.resolve({}) ?? theme.colorScheme.onPrimary.withOpacity(0.4), // Disabled text color
                                 padding: EdgeInsets.symmetric(vertical: (14 * scaleFactor).clamp(12.0, 18.0), horizontal: (24 * scaleFactor).clamp(20.0, 32.0)), // Responsive padding
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8 * scaleFactor)), // Match text field border radius
                                 textStyle: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.w700), // Apply responsive font size and bold weight
                                 elevation: controller.isLoading.value ? 0 : 4.0, // Reduce elevation when loading
                             ),
                             child: controller.isLoading.value
                                 ? SizedBox(
                                     width: loaderSize,
                                     height: loaderSize,
                                     child: CircularProgressIndicator(
                                       strokeWidth: (2.0 * scaleFactor).clamp(1.5, 3.0), // Responsive stroke width
                                       valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary), // Loader color matching text color
                                     ),
                                   )
                                 : Text('update_password'.tr.toUpperCase()), // Uppercase text
                           ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Close Button (positioned outside the Card for better visual separation)
            Positioned(
              top: -spacingMedium * 0,
              right: -spacingMedium * 0,
              child: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(spacingMedium / 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: closeIconSize,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}