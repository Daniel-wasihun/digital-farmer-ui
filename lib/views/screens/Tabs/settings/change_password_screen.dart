import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
// Import the comprehensive AuthController
import '../../../../controllers/auth/auth_controller.dart';
import '../../../widgets/custom_text_field.dart';

// Use GetView with AuthController as it's the controller for this screen's logic
class ChangePasswordScreen extends GetView<AuthController> {
   // Using Key is optional but good practice
   const ChangePasswordScreen({super.key});


  @override
  Widget build(BuildContext context) {
    // Access the controller using 'controller' property provided by GetView
    // The controller is Get.find<AuthController>() because we specified GetView<AuthController>
    // Use the controller property directly: controller.myVariable

    // --- FIX for persistent errors ---
    // Call resetPasswordErrors when the screen is built (e.g., on navigation entry)
    // Using addPostFrameCallback ensures it happens after the widget is rendered
    // but before the user interacts.
    // Also clear the text field controllers manually as resetPasswordErrors
    // only resets the error *states*.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetPasswordErrors(); // Use the specific password error reset
      controller.currentPasswordController.clear(); // Clear the fields
      controller.newPasswordController.clear();
      controller.confirmPasswordController.clear();
    });


    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // --- Responsive Breakpoints ---
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

    // --- Responsive Scale Factor ---
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
    final double maxFormWidth = isDesktop
        ? 600
        : isLargeTablet
            ? 500
            : isCompactTablet
                ? 400
                : size.width * (isTinyPhone ? 0.95 : isVerySmallPhone ? 0.92 : 0.9);
    final double maxFormHeight = size.height * (isTinyPhone ? 0.9 : isVerySmallPhone ? 0.85 : isSmallPhone ? 0.8 : 0.7);

    // --- Responsive Padding ---
    final double cardPadding = math.max(8.0, 12.0 * scaleFactor).clamp(10.0, 24.0);

    // --- Responsive Font Sizes ---
    final double baseTitleFontSize = 18.0;
    final double baseAppBarFontSize = 16.0;
    final double baseFieldLabelFontSize = 12.0;
    final double baseFieldValueFontSize = 14.0;
    final double baseButtonFontSize = 14.0;
    final double iconSize = (20.0 * scaleFactor).clamp(16.0, 22.0);
    // final double errorFontSize = (10.0 * scaleFactor).clamp(8.0, 12.0); // Not directly used in CustomTextField, handled internally
    final double loaderSize = (20.0 * scaleFactor).clamp(18.0, 24.0);

    final double titleFontSize = (baseTitleFontSize * scaleFactor).clamp(16.0, 20.0);
    final double appBarFontSize = (baseAppBarFontSize * scaleFactor).clamp(14.0, 18.0);
    final double fieldLabelFontSize = (baseFieldLabelFontSize * scaleFactor).clamp(10.0, 14.0);
    final double fieldValueFontSize = (baseFieldValueFontSize * scaleFactor).clamp(12.0, 16.0);
    final double buttonFontSize = (baseButtonFontSize * scaleFactor).clamp(12.0, 16.0);

    // --- Responsive Spacing ---
    // --- Adjusted spacing values ---
    final double spacingSmall = math.max(6.0, 8 * scaleFactor);
    final double spacingMedium = math.max(8.0, 12 * scaleFactor); // Using the reduced base value
    final double spacingLarge = math.max(18.0, 24 * scaleFactor);

    // --- Consistent Vertical Padding for Text Fields ---
    // --- Adjusted padding value ---
    final double consistentVerticalPadding = math.max(10.0, 12 * scaleFactor); // Using the reduced base value


    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text(
          'change_password'.tr,
          style: theme.appBarTheme.titleTextStyle?.copyWith(
                fontSize: appBarFontSize,
                fontWeight: FontWeight.w600,
              ) ??
              TextStyle(
                fontSize: appBarFontSize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary, // Assuming onPrimary is the default app bar text color
              ),
        ),
        toolbarHeight: (isTinyPhone || isVerySmallPhone || isSmallPhone) ? 45 : 56,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxFormWidth.clamp(240, 600),
            maxHeight: maxFormHeight.clamp(300, 600),
          ),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: size.width * (isTinyPhone ? 0.03 : 0.04)),
            child: Card(
              elevation: isDarkMode ? 2.0 : 4.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(math.max(8.0, 12 * scaleFactor))),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'change_password'.tr,
                        style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ) ??
                            TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacingLarge),
                      Obx(
                        () => CustomTextField(
                          label: 'current_password'.tr,
                          controller: controller.currentPasswordController, // Use AuthController
                          obscureText: true,
                          prefixIcon: Icons.lock,
                          errorText: controller.currentPasswordError.value.isEmpty // Use AuthController error
                              ? null
                              : controller.currentPasswordError.value,
                          onChanged: controller.validateCurrentPassword, // Use AuthController method
                          scaleFactor: scaleFactor,
                          fontSize: fieldValueFontSize,
                          labelFontSize: fieldLabelFontSize,
                          iconSize: iconSize,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: math.max(8.0, 10 * scaleFactor), vertical: consistentVerticalPadding),
                          borderRadius: math.max(5.0, 7 * scaleFactor),
                          filled: true,
                          fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                        ),
                      ),
                      SizedBox(height: spacingMedium), // Use adjusted spacingMedium
                      Obx(
                        () => CustomTextField(
                          label: 'new_password'.tr,
                          controller: controller.newPasswordController, // Use AuthController
                          obscureText: true,
                          prefixIcon: Icons.lock,
                          errorText: controller.newPasswordError.value.isEmpty // Use AuthController error
                              ? null
                              : controller.newPasswordError.value,
                          onChanged: controller.validateNewPassword, // Use AuthController method
                          scaleFactor: scaleFactor,
                          fontSize: fieldValueFontSize,
                          labelFontSize: fieldLabelFontSize,
                          iconSize: iconSize,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: math.max(8.0, 10 * scaleFactor), vertical: consistentVerticalPadding),
                          borderRadius: math.max(5.0, 7 * scaleFactor),
                          filled: true,
                          fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                        ),
                      ),
                      SizedBox(height: spacingMedium), // Use adjusted spacingMedium
                      Obx(
                        () => CustomTextField(
                          label: 'confirm_password'.tr,
                          controller: controller.confirmPasswordController, // Use AuthController
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                          errorText: controller.confirmPasswordError.value.isEmpty // Use AuthController error
                              ? null
                              : controller.confirmPasswordError.value,
                          onChanged: (value) => controller.validateConfirmPassword( // Use AuthController method
                              controller.newPasswordController.text, value),
                          scaleFactor: scaleFactor,
                          fontSize: fieldValueFontSize,
                          labelFontSize: fieldLabelFontSize,
                          iconSize: iconSize,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: math.max(8.0, 10 * scaleFactor), vertical: consistentVerticalPadding),
                          borderRadius: math.max(5.0, 7 * scaleFactor),
                          filled: true,
                          fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (!controller.isLoading.value) { // Use AuthController isLoading
                              controller.changePassword(); // Call AuthController method
                            }
                          },
                        ),
                      ),
                      SizedBox(height: spacingLarge),
                      Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: math.max(10.0, 12 * scaleFactor),
                                horizontal: math.max(16.0, 20 * scaleFactor)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(math.max(5.0, 7 * scaleFactor)),
                            ),
                            textStyle: TextStyle(
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 2.0,
                          ),
                          onPressed: controller.isLoading.value // Use AuthController isLoading
                              ? null
                              : () {
                                  controller.changePassword(); // Call AuthController method
                                },
                          child: controller.isLoading.value // Use AuthController isLoading
                              ? SizedBox(
                                  width: loaderSize,
                                  height: loaderSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth: math.max(1.5, 2.0 * scaleFactor),
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                                  ),
                                )
                              : Text('update_password'.tr.toUpperCase()),
                        ),
                      ),
                      SizedBox(height: spacingSmall),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ),
    ));
  }
}