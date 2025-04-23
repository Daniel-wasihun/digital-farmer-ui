import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/auth/auth_controller.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/glassmorphic_card.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    print('ChangePasswordScreen initState, creating controllers');
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Resetting errors in post-frame callback');
      authController.resetPasswordErrors();
    });
  }

  @override
  void dispose() {
    print('ChangePasswordScreen dispose, disposing controllers');
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet ? 1.1 : 0.9; // Reduced base scaleFactor

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text(
          'change_password'.tr,
          style: TextStyle(
                fontSize: 16 * scaleFactor, // Smaller app bar title
                fontWeight: FontWeight.w600,
              ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.foregroundColor),
          onPressed: () {
            print('AppBar back button pressed, navigating back');
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
                    Text(
                      'change_password'.tr,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 18 * scaleFactor, // Smaller title
                            fontWeight: FontWeight.w700,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12 * scaleFactor), // Reduced spacing
                    CustomTextField(
                      label: 'current_password'.tr,
                      controller: currentPasswordController,
                      obscureText: true,
                      prefixIcon: Icons.lock,
                      errorText: authController.currentPasswordError.value.isEmpty
                          ? null
                          : authController.currentPasswordError.value,
                      onChanged: (value) => authController.validateCurrentPassword(value),
                      scaleFactor: scaleFactor,
                    ),
                    SizedBox(height: 6 * scaleFactor), // Reduced spacing
                    CustomTextField(
                      label: 'new_password'.tr,
                      controller: newPasswordController,
                      obscureText: true,
                      prefixIcon: Icons.lock,
                      errorText: authController.newPasswordError.value.isEmpty
                          ? null
                          : authController.newPasswordError.value,
                      onChanged: (value) => authController.validateNewPassword(value),
                      scaleFactor: scaleFactor,
                    ),
                    SizedBox(height: 6 * scaleFactor), // Reduced spacing
                    CustomTextField(
                      label: 'confirm_password'.tr,
                      controller: confirmPasswordController,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                      errorText: authController.confirmPasswordError.value.isEmpty
                          ? null
                          : authController.confirmPasswordError.value,
                      onChanged: (value) => authController.validateConfirmPassword(
                          newPasswordController.text, value),
                      scaleFactor: scaleFactor,
                    ),
                    SizedBox(height: 12 * scaleFactor), // Reduced spacing
                    ElevatedButton(
                      onPressed: authController.isLoading.value
                          ? null
                          : () {
                              print('Change password button pressed');
                              authController.changePassword(
                                currentPasswordController.text,
                                newPasswordController.text,
                                confirmPasswordController.text,
                              );
                              print('After changePassword call');
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
                      child: authController.isLoading.value
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
                              'update_password'.tr,
                              style: Theme.of(context)
                                  .elevatedButtonTheme
                                  .style!
                                  .textStyle!
                                  .resolve({})
                                  // .copyWith(fontSize: 12 * scaleFactor), // Smaller text
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