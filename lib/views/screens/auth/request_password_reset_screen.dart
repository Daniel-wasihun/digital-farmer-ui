import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../../routes/app_routes.dart';

class RequestPasswordResetScreen extends GetView<AuthController> {
  const RequestPasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final maxFormWidth = isTablet ? 500.0 : 380.0;

    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'request_password_reset'.tr,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 18 * scaleFactor,
                fontWeight: FontWeight.w600,
              ),
        ),
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
                                  'request_password_reset'.tr,
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
                                Text(
                                  'enter_email_for_reset'.tr,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 16 * scaleFactor,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 14 * scaleFactor),
                                Obx(() => CustomTextField(
                                      controller: emailController,
                                      label: 'email'.tr,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icons.email,
                                      errorText: controller.emailError.value,
                                      onChanged: (value) => controller.validateEmail(value),
                                      scaleFactor: scaleFactor,
                                    )),
                                SizedBox(height: 14 * scaleFactor),
                                ElevatedButton(
                                  onPressed: () {
                                    controller.requestPasswordReset(emailController.text);
                                  },
                                  style: Theme.of(context).elevatedButtonTheme.style,
                                  child: Text(
                                    'send_otp'.tr,
                                    style: Theme.of(context)
                                        .elevatedButtonTheme
                                        .style!
                                        .textStyle!
                                        .resolve({}),
                                  ),
                                ),
                                SizedBox(height: 8 * scaleFactor),
                                TextButton(
                                  onPressed: () {
                                    if (emailController.text.isEmpty) {
                                      controller.emailError.value = 'please_enter_email'.tr;
                                      return;
                                    }
                                    if (!GetUtils.isEmail(emailController.text)) {
                                      controller.emailError.value = 'invalid_email'.tr;
                                      return;
                                    }
                                    Get.toNamed(
                                      AppRoutes.getSecurityQuestionVerificationPage(),
                                      arguments: {'email': emailController.text},
                                    );
                                  },
                                  child: Text(
                                    'use_another_method'.tr,
                                    style: Theme.of(context)
                                        .textButtonTheme
                                        .style!
                                        .textStyle!
                                        .resolve({})
                                        ?.copyWith(
                                          color: Theme.of(context).colorScheme.secondary,
                                          fontSize: 14 * scaleFactor,
                                        ),
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