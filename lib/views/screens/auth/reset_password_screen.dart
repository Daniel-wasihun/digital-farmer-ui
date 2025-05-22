import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends GetView<AuthController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final String? resetToken = args != null ? args['resetToken'] as String? : null;
    final String? email = args != null ? args['email'] as String? : null;

    if (resetToken == null || email == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error'.tr,
          'Invalid navigation parameters. Please try resetting your password again.'.tr,
          backgroundColor: Theme.of(context).colorScheme.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offNamed('/request-password-reset');
      });
      return const SizedBox.shrink();
    }

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final maxFormWidth = isTablet ? 500.0 : 380.0;

    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    newPasswordController.addListener(() {
      print('New Password Controller: ${newPasswordController.text}');
    });
    confirmPasswordController.addListener(() {
      print('Confirm Password Controller: ${confirmPasswordController.text}');
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'reset_password'.tr,
          style: theme.textTheme.titleLarge!.copyWith(
            fontSize: 18 * scaleFactor,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back,
            color: theme.textTheme.titleLarge!.color,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [theme.colorScheme.surface, theme.colorScheme.surface]
                  : [theme.colorScheme.surface, theme.colorScheme.surface.withOpacity(0.95)],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [theme.colorScheme.surface, theme.colorScheme.surface]
                : [theme.colorScheme.surface, theme.colorScheme.surface.withOpacity(0.95)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * (isTablet ? 0.12 : 0.06),
                    vertical: size.height * 0.03,
                  ).add(EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom)),
                  child: Obx(
                    () => controller.isLoading.value
                        ? Center(
                            child: SpinKitFadingCube(
                              color: const Color(0xFF1A6B47), // Updated to lighter green
                              size: 32 * scaleFactor,
                            ),
                          )
                        : ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: (isTablet ? size.width * 0.75 : size.width * 0.85).clamp(280, maxFormWidth),
                            ),
                            child: Card(
                              elevation: isDarkMode ? 6.0 : 10.0,
                              color: theme.cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16 * scaleFactor),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding: EdgeInsets.all((16 * scaleFactor).clamp(12.0, 24.0)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'reset_password'.tr,
                                      style: theme.textTheme.titleLarge?.copyWith(
                                            fontSize: (22 * scaleFactor).clamp(18.0, 24.0),
                                            fontWeight: FontWeight.bold,
                                            color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1A6B47),
                                            shadows: isDarkMode
                                                ? null
                                                : [
                                                    Shadow(
                                                      blurRadius: 6.0,
                                                      color: Colors.black.withOpacity(0.2),
                                                      offset: Offset(2, 2),
                                                    ),
                                                  ],
                                          ) ??
                                          TextStyle(
                                            fontSize: (22 * scaleFactor).clamp(18.0, 24.0),
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                    AnimatedOpacity(
                                      opacity: controller.isLoading.value ? 0.5 : 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      child: SizedBox(
                                        width: (maxFormWidth - 32 * scaleFactor).clamp(240.0, 360.0),
                                        child: Obx(
                                          () => CustomTextField(
                                            controller: newPasswordController,
                                            label: 'new_password'.tr,
                                            obscureText: true,
                                            prefixIcon: Icons.lock,
                                            errorText: controller.newPasswordError.value.isEmpty
                                                ? null
                                                : controller.newPasswordError.value,
                                            onChanged: (value) {
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                controller.validateNewPassword(value);
                                              });
                                            },
                                            scaleFactor: scaleFactor,
                                            fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                            labelFontSize: (12 * scaleFactor).clamp(10.0, 14.0),
                                            iconSize: (20 * scaleFactor).clamp(18.0, 24.0),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: (6 * scaleFactor).clamp(6.0, 10.0),
                                              vertical: (12 * scaleFactor).clamp(10.0, 16.0),
                                            ),
                                            borderRadius: 8 * scaleFactor,
                                            filled: true,
                                            fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
                                            enabled: !controller.isLoading.value,
                                            textInputAction: TextInputAction.next,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9!@#\$%^&*(),.?":{}|<>]')),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                    AnimatedOpacity(
                                      opacity: controller.isLoading.value ? 0.5 : 1.0,
                                      duration: const Duration(milliseconds: 300),
                                      child: SizedBox(
                                        width: (maxFormWidth - 32 * scaleFactor).clamp(240.0, 360.0),
                                        child: Obx(
                                          () => CustomTextField(
                                            controller: confirmPasswordController,
                                            label: 'confirm_new_password'.tr,
                                            obscureText: true,
                                            prefixIcon: Icons.lock_outline,
                                            errorText: controller.confirmPasswordError.value.isEmpty
                                                ? null
                                                : controller.confirmPasswordError.value,
                                            onChanged: (value) {
                                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                                controller.validateConfirmPassword(
                                                  newPasswordController.text,
                                                  value,
                                                );
                                              });
                                            },
                                            scaleFactor: scaleFactor,
                                            fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                            labelFontSize: (12 * scaleFactor).clamp(10.0, 14.0),
                                            iconSize: (20 * scaleFactor).clamp(18.0, 24.0),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: (6 * scaleFactor).clamp(6.0, 10.0),
                                              vertical: (12 * scaleFactor).clamp(10.0, 16.0),
                                            ),
                                            borderRadius: 8 * scaleFactor,
                                            filled: true,
                                            fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
                                            enabled: !controller.isLoading.value,
                                            textInputAction: TextInputAction.done,
                                            onSubmitted: (_) {
                                              if (!controller.isLoading.value) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  controller.validateNewPassword(newPasswordController.text);
                                                  controller.validateConfirmPassword(
                                                    newPasswordController.text,
                                                    confirmPasswordController.text,
                                                  );
                                                  if (controller.newPasswordError.value.isEmpty &&
                                                      controller.confirmPasswordError.value.isEmpty) {
                                                    print('Submitting reset password');
                                                    controller.resetPassword(
                                                      resetToken,
                                                      newPasswordController.text,
                                                      confirmPasswordController.text,
                                                    );
                                                    newPasswordController.clear();
                                                    confirmPasswordController.clear();
                                                  } else {
                                                    print('Validation failed');
                                                    print('New Password Error: ${controller.newPasswordError.value}');
                                                    print('Confirm Password Error: ${controller.confirmPasswordError.value}');
                                                  }
                                                });
                                              }
                                            },
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9!@#\$%^&*(),.?":{}|<>]')),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                    AnimatedScale(
                                      scale: controller.isLoading.value ? 0.95 : 1.0,
                                      duration: const Duration(milliseconds: 200),
                                      child: ElevatedButton(
                                        onPressed: controller.isLoading.value
                                            ? null
                                            : () {
                                                print('Reset Password Button Clicked');
                                                print('New Password: ${newPasswordController.text}');
                                                print('Confirm Password: ${confirmPasswordController.text}');
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  controller.validateNewPassword(newPasswordController.text);
                                                  controller.validateConfirmPassword(
                                                    newPasswordController.text,
                                                    confirmPasswordController.text,
                                                  );
                                                  if (controller.newPasswordError.value.isEmpty &&
                                                      controller.confirmPasswordError.value.isEmpty) {
                                                    print('Submitting reset password');
                                                    controller.resetPassword(
                                                      resetToken,
                                                      newPasswordController.text,
                                                      confirmPasswordController.text,
                                                    );
                                                    newPasswordController.clear();
                                                    confirmPasswordController.clear();
                                                  } else {
                                                    print('Validation failed');
                                                    print('New Password Error: ${controller.newPasswordError.value}');
                                                    print('Confirm Password Error: ${controller.confirmPasswordError.value}');
                                                  }
                                                });
                                              },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1A6B47), // Updated to lighter green
                                          foregroundColor: Colors.white, // Updated for contrast
                                          padding: EdgeInsets.symmetric(
                                            vertical: (14 * scaleFactor).clamp(12.0, 18.0),
                                            horizontal: (24 * scaleFactor).clamp(20.0, 32.0),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8 * scaleFactor),
                                          ),
                                          textStyle: TextStyle(
                                            fontSize: (16 * scaleFactor).clamp(14.0, 18.0),
                                            fontWeight: FontWeight.w700,
                                          ),
                                          elevation: controller.isLoading.value ? 0 : 4.0,
                                        ),
                                        child: controller.isLoading.value
                                            ? SizedBox(
                                                width: (24 * scaleFactor).clamp(20.0, 30.0),
                                                height: (24 * scaleFactor).clamp(20.0, 30.0),
                                                child: CircularProgressIndicator(
                                                  strokeWidth: (2.0 * scaleFactor).clamp(1.5, 3.0),
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Updated for contrast
                                                ),
                                              )
                                            : Text(
                                                'reset_password'.tr.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: (16 * scaleFactor).clamp(14.0, 18.0),
                                                  fontWeight: FontWeight.w700,
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}