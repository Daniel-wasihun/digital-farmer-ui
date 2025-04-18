import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glassmorphic_card.dart';

class ResetPasswordScreen extends GetView<AuthController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String resetToken = args['resetToken'];
    final String email = args['email'];
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final maxFormWidth = isTablet ? 500.0 : 380.0;

    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'reset_password'.tr,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 18 * scaleFactor,
                fontWeight: FontWeight.w600,
              ),
        ),
        // No leading or actions needed, but can be added if required
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Get.back(),
        // ),
        // actions: [
        //   // Add action widgets here if needed
        // ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface,
                  ]
                : [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface.withOpacity(0.95),
                  ],
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
                  ),
                  child: Obx(() => controller.isLoading.value
                      ? Center(
                          child: SpinKitFadingCube(
                            color: Theme.of(context).colorScheme.secondary,
                            size: 32 * scaleFactor,
                          ),
                        )
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: (isTablet ? size.width * 0.75 : size.width * 0.85)
                                .clamp(280, maxFormWidth),
                          ),
                          child: GlassmorphicCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'reset_password'.tr,
                                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                        fontSize: 22 * scaleFactor,
                                        fontWeight: FontWeight.w700,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 6.0,
                                            color: Colors.black12,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 14 * scaleFactor),
                                Obx(() => CustomTextField(
                                      controller: newPasswordController,
                                      label: 'new_password'.tr,
                                      obscureText: true,
                                      prefixIcon: Icons.lock,
                                      errorText: controller.newPasswordError.value,
                                      onChanged: (value) => controller.validateNewPassword(value),
                                      scaleFactor: scaleFactor,
                                    )),
                                SizedBox(height: 10 * scaleFactor),
                                Obx(() => CustomTextField(
                                      controller: confirmPasswordController,
                                      label: 'confirm_new_password'.tr,
                                      obscureText: true,
                                      prefixIcon: Icons.lock_outline,
                                      errorText: controller.confirmPasswordError.value,
                                      onChanged: (value) => controller.validateConfirmPassword(
                                          newPasswordController.text, value),
                                      scaleFactor: scaleFactor,
                                    )),
                                SizedBox(height: 14 * scaleFactor),
                                ElevatedButton(
                                  onPressed: () {
                                    controller.resetPassword(
                                      resetToken,
                                      newPasswordController.text,
                                      confirmPasswordController.text,
                                    );
                                  },
                                  style: Theme.of(context).elevatedButtonTheme.style,
                                  child: Text(
                                    'reset_password'.tr,
                                    style: Theme.of(context)
                                        .elevatedButtonTheme
                                        .style!
                                        .textStyle!
                                        .resolve({}),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}