import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:animated_background/animated_background.dart';
import '../../../controllers/app_controller.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';

class RequestPasswordResetScreen extends GetView<AuthController> {
  const RequestPasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controllers are initialized
    final ThemeController themeController = Get.find<ThemeController>();
    final AppController appController = Get.find<AppController>();

    // Clear field and error after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.emailController.clear();
      controller.emailError.value = '';
    });

    // Sync TextEditingController with validation
    controller.emailController.addListener(() {
      controller.validateEmail(controller.emailController.text);
    });

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final maxFormWidth = isTablet ? 500.0 : 380.0;

    return AnimatedBackground(
      behaviour: RandomParticleBehaviour(
        options: ParticleOptions(
          baseColor: theme.colorScheme.secondary.withOpacity(0.3),
          spawnMinSpeed: 6.0,
          spawnMaxSpeed: 30.0,
          particleCount: 50,
          spawnOpacity: 0.15,
          maxOpacity: 0.3,
        ),
      ),
      vsync: const _VSyncProvider(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'request_password_reset'.tr,
            style: theme.textTheme.titleLarge!.copyWith(
              fontSize: 18 * scaleFactor,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 8 * scaleFactor),
                  child: Text(
                    Get.locale?.languageCode == 'am' ? 'አማ' : 'En',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontSize: 16 * scaleFactor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.language,
                    size: 20 * scaleFactor,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () => appController.toggleLanguage(),
                  tooltip: 'toggle_language'.tr,
                ),
                IconButton(
                  icon: Icon(
                    themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
                    size: 20 * scaleFactor,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () => themeController.toggleTheme(),
                  tooltip: themeController.isDarkMode.value ? 'switch_to_light_mode'.tr : 'switch_to_dark_mode'.tr,
                ),
                SizedBox(width: 8 * scaleFactor),
              ],
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface,
                    ]
                  : [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withOpacity(0.95),
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
                    child: Obx(
                      () => controller.isLoading.value
                          ? Center(
                              child: CircularProgressIndicator(
                                strokeWidth: (2.0 * scaleFactor).clamp(1.5, 3.0),
                                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
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
                                        'request_password_reset'.tr,
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                              fontSize: (22 * scaleFactor).clamp(18.0, 24.0),
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
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
                                      Text(
                                        'enter_email_for_reset'.tr,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                              fontSize: (16 * scaleFactor).clamp(14.0, 18.0),
                                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            ) ??
                                            TextStyle(
                                              fontSize: (16 * scaleFactor).clamp(14.0, 18.0),
                                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                      AnimatedOpacity(
                                        opacity: controller.isLoading.value ? 0.5 : 1.0,
                                        duration: const Duration(milliseconds: 300),
                                        child: CustomTextField(
                                          controller: controller.emailController,
                                          label: 'email'.tr,
                                          keyboardType: TextInputType.emailAddress,
                                          prefixIcon: Icons.email,
                                          errorText: controller.emailError.value.isEmpty ? null : controller.emailError.value,
                                          onChanged: (value) => controller.validateEmail(value),
                                          scaleFactor: scaleFactor,
                                          fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                          labelFontSize: (12 * scaleFactor).clamp(10.0, 14.0),
                                          iconSize: (20 * scaleFactor).clamp(18.0, 24.0),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: (8 * scaleFactor).clamp(8.0, 12.0),
                                            vertical: (12 * scaleFactor).clamp(10.0, 16.0),
                                          ),
                                          borderRadius: 8 * scaleFactor,
                                          filled: true,
                                          fillColor: theme.colorScheme.onSurface.withOpacity(isDarkMode ? 0.1 : 0.05),
                                          enabled: !controller.isLoading.value,
                                          textInputAction: TextInputAction.done,
                                          onSubmitted: (_) {
                                            if (!controller.isLoading.value) {
                                              controller.requestPasswordReset(controller.emailController.text);
                                            }
                                          },
                                        ),
                                      ),
                                      SizedBox(height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                      AnimatedScale(
                                        scale: controller.isLoading.value ? 0.95 : 1.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: ElevatedButton(
                                          onPressed: controller.isLoading.value
                                              ? null
                                              : () => controller.requestPasswordReset(controller.emailController.text),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.colorScheme.primary,
                                            foregroundColor: theme.colorScheme.onPrimary,
                                            padding: EdgeInsets.symmetric(
                                              vertical: (14 * scaleFactor).clamp(12.0, 18.0),
                                              horizontal: (24 * scaleFactor).clamp(20.0, 32.0),
                                            ),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8 * scaleFactor)),
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
                                                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                                                  ),
                                                )
                                              : Text('send_otp'.tr.toUpperCase()),
                                        ),
                                      ),
                                      SizedBox(height: (8 * scaleFactor).clamp(8.0, 12.0)),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          TextButton(
                                            onPressed: controller.isLoading.value
                                                ? null
                                                : () {
                                                    final email = controller.emailController.text;
                                                    controller.validateEmail(email);
                                                    if (controller.emailError.value.isEmpty) {
                                                      Get.toNamed(
                                                        AppRoutes.getSecurityQuestionVerificationPage(),
                                                        arguments: {'email': email},
                                                      );
                                                    }
                                                  },
                                            child: Text(
                                              'use_another_method'.tr,
                                              style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                                                        color: theme.colorScheme.secondary,
                                                        fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                                      ) ??
                                                  TextStyle(
                                                    color: theme.colorScheme.secondary,
                                                    fontSize: (14 * scaleFactor).clamp(12.0, 16.0),
                                                  ),
                                            ),
                                          ),
                                        ],
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
      ),
    );
  }
}

class _VSyncProvider implements TickerProvider {
  const _VSyncProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}