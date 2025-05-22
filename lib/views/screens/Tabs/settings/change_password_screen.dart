import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../widgets/custom_text_field.dart';

class ChangePasswordScreen extends GetView<AuthController> {
  const ChangePasswordScreen({super.key});

  static void show() {
    Get.dialog(
      const ChangePasswordScreen(),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 400),
      transitionCurve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("ChangePasswordScreen built, resetting state.");
      controller.resetPasswordErrors();
      controller.currentPasswordController.clear();
      controller.newPasswordController.clear();
      controller.confirmPasswordController.clear();
      controller.isPasswordChangeSuccess.value = false;
    });

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1A252F) : Colors.white;

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

    final double maxContentWidth = isDesktop
        ? 600
        : isLargeTablet
            ? 500
            : isCompactTablet
                ? 400
                : size.width * (isTinyPhone ? 0.95 : isVerySmallPhone ? 0.92 : 0.9);

    final double maxContentHeight = (size.height * 0.75 * scaleFactor).clamp(300.0, 550.0);

    final double dialogHorizontalPadding = (size.width * 0.05 * scaleFactor).clamp(16.0, 40.0);
    final double cardContentPadding = (16.0 * scaleFactor).clamp(12.0, 24.0);

    final double baseTitleFontSize = 20.0;
    final double baseFieldLabelFontSize = 12.0;
    final double baseFieldValueFontSize = 14.0;
    final double baseButtonFontSize = 16.0;

    final double titleFontSize = (baseTitleFontSize * scaleFactor).clamp(16.0, 24.0);
    final double fieldLabelFontSize = (baseFieldLabelFontSize * scaleFactor).clamp(10.0, 14.0);
    final double fieldValueFontSize = (baseFieldValueFontSize * scaleFactor).clamp(12.0, 16.0);
    final double buttonFontSize = (baseButtonFontSize * scaleFactor).clamp(14.0, 18.0);

    final double iconSize = (20.0 * scaleFactor).clamp(18.0, 24.0);
    final double closeIconSize = (20.0 * scaleFactor).clamp(18.0, 24.0);

    final double loaderSize = (24.0 * scaleFactor).clamp(20.0, 30.0);

    final double spacingExtraSmall = (4.0 * scaleFactor).clamp(4.0, 8.0);
    final double spacingSmall = (8.0 * scaleFactor).clamp(8.0, 12.0);
    final double spacingMedium = (12.0 * scaleFactor).clamp(12.0, 16.0);
    final double spacingLarge = (16.0 * scaleFactor).clamp(16.0, 24.0);
    final double spacingExtraLarge = (24.0 * scaleFactor).clamp(24.0, 32.0);

    final double consistentVerticalPadding = (12.0 * scaleFactor).clamp(10.0, 16.0);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scaleFactor)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
          horizontal: dialogHorizontalPadding,
          vertical: spacingLarge
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxContentWidth,
          maxHeight: maxContentHeight,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: isDarkMode ? 6.0 : 10.0,
              color: cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * scaleFactor)),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(cardContentPadding),
                child: SingleChildScrollView(
                  child: Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: spacingSmall,
                            left: spacingExtraLarge,
                            right: spacingExtraLarge,
                            bottom: spacingLarge,
                          ),
                          child: Text(
                            'change_password'.tr,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              shadows: isDarkMode ? null : [
                                Shadow(
                                  blurRadius: 6.0,
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ) ??
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
                        AnimatedOpacity(
                           opacity: controller.isLoading.value ? 0.5 : 1.0,
                           duration: const Duration(milliseconds: 300),
                           child: CustomTextField(
                            label: 'current_password'.tr,
                            controller: controller.currentPasswordController,
                            obscureText: true,
                            prefixIcon: Icons.lock_outline,
                            errorText: controller.currentPasswordError.value.isEmpty ? null : controller.currentPasswordError.value,
                            onChanged: controller.validateCurrentPassword,
                            scaleFactor: scaleFactor,
                            fontSize: fieldValueFontSize,
                            labelFontSize: fieldLabelFontSize,
                            iconSize: iconSize,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: spacingSmall,
                                vertical: consistentVerticalPadding),
                            borderRadius: 8 * scaleFactor,
                            filled: true,
                            fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
                            enabled: !controller.isLoading.value,
                          ),
                        ),
                        SizedBox(height: spacingMedium),
                        AnimatedOpacity(
                           opacity: controller.isLoading.value ? 0.5 : 1.0,
                           duration: const Duration(milliseconds: 300),
                           child: CustomTextField(
                            label: 'new_password'.tr,
                            controller: controller.newPasswordController,
                            obscureText: true,
                            prefixIcon: Icons.lock,
                            errorText: controller.newPasswordError.value.isEmpty ? null : controller.newPasswordError.value,
                            onChanged: controller.validateNewPassword,
                            scaleFactor: scaleFactor,
                            fontSize: fieldValueFontSize,
                            labelFontSize: fieldLabelFontSize,
                            iconSize: iconSize,
                            contentPadding: EdgeInsets.symmetric(horizontal: spacingSmall, vertical: consistentVerticalPadding),
                            borderRadius: 8 * scaleFactor,
                            filled: true,
                            fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
                            enabled: !controller.isLoading.value,
                          ),
                        ),
                        SizedBox(height: spacingMedium),
                        AnimatedOpacity(
                           opacity: controller.isLoading.value ? 0.5 : 1.0,
                           duration: const Duration(milliseconds: 300),
                           child: CustomTextField(
                            label: 'confirm_password'.tr,
                            controller: controller.confirmPasswordController,
                            obscureText: true,
                            prefixIcon: Icons.lock_outline,
                            errorText: controller.confirmPasswordError.value.isEmpty ? null : controller.confirmPasswordError.value,
                            onChanged: (value) => controller.validateConfirmPassword(controller.newPasswordController.text, value),
                            scaleFactor: scaleFactor,
                            fontSize: fieldValueFontSize,
                            labelFontSize: fieldLabelFontSize,
                            iconSize: iconSize,
                            contentPadding: EdgeInsets.symmetric(horizontal: spacingSmall, vertical: consistentVerticalPadding),
                            borderRadius: 8 * scaleFactor,
                            filled: true,
                            fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
                            enabled: !controller.isLoading.value,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) {
                              if (!controller.isLoading.value) {
                                controller.changePassword();
                              }
                            },
                          ),
                        ),
                        SizedBox(height: spacingLarge),
                        AnimatedScale(
                           scale: controller.isLoading.value ? 0.95 : 1.0,
                           duration: const Duration(milliseconds: 200),
                           child: ElevatedButton(
                             onPressed: controller.isLoading.value ? null : controller.changePassword,
                             style: ElevatedButton.styleFrom(
                                 backgroundColor: const Color(0xFF1A6B47), // Updated to lighter green
                                 foregroundColor: Colors.white, // Updated for text contrast
                                 padding: EdgeInsets.symmetric(vertical: (14 * scaleFactor).clamp(12.0, 18.0), horizontal: (24 * scaleFactor).clamp(20.0, 32.0)),
                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8 * scaleFactor)),
                                 textStyle: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.w700),
                                 elevation: controller.isLoading.value ? 0 : 4.0,
                             ),
                             child: controller.isLoading.value
                                 ? SizedBox(
                                     width: loaderSize,
                                     height: loaderSize,
                                     child: CircularProgressIndicator(
                                       strokeWidth: (2.0 * scaleFactor).clamp(1.5, 3.0),
                                       valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Updated for contrast
                                     ),
                                   )
                                 : Text('update_password'.tr.toUpperCase()),
                           ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -spacingMedium * 0,
              right: -spacingMedium * 0,
              child: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(spacingMedium / 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6B47), // Updated to lighter green
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