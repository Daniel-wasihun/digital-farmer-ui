import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:animated_background/animated_background.dart';
import '../../../controllers/app_controller.dart';
import '../../../controllers/auth/signin_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AppController());
    final ThemeController themeController = Get.find<ThemeController>();
    final AppController appController = Get.find<AppController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.put(SignInController());
      controller.reset();
      controller.authController.emailController.clear();
      controller.authController.passwordController.clear();
      controller.authController.emailError.value = '';
      controller.authController.passwordError.value = '';
    });

    controller.authController.emailController.addListener(() {
      controller.email.value = controller.authController.emailController.text;
      controller.authController.validateEmail(controller.email.value);
    });
    controller.authController.passwordController.addListener(() {
      controller.password.value = controller.authController.passwordController.text;
      controller.authController.validatePassword(controller.password.value);
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
          baseColor: const Color(0xFF1A6B47).withOpacity(0.3), // Updated to lighter green
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
            'app_title'.tr,
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
                      () => AnimatedOpacity(
                        opacity: controller.authController.isLoading.value ? 0.7 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: ConstrainedBox(
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
                                    'signin'.tr,
                                    style: theme.textTheme.headlineSmall?.copyWith(
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
                                  CustomTextField(
                                    label: 'email'.tr,
                                    controller: controller.authController.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email,
                                    errorText: controller.authController.emailError.value.isEmpty
                                        ? null
                                        : controller.authController.emailError.value,
                                    onChanged: controller.onEmailChanged,
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
                                    enabled: !controller.authController.isLoading.value,
                                  ),
                                  SizedBox(height: (10 * scaleFactor).clamp(8.0, 12.0)),
                                  CustomTextField(
                                    label: 'password'.tr,
                                    controller: controller.authController.passwordController,
                                    obscureText: true,
                                    prefixIcon: Icons.lock,
                                    errorText: controller.authController.passwordError.value.isEmpty
                                        ? null
                                        : controller.authController.passwordError.value,
                                    onChanged: controller.onPasswordChanged,
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
                                    enabled: !controller.authController.isLoading.value,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) {
                                      if (!controller.authController.isLoading.value) {
                                        controller.signIn();
                                      }
                                    },
                                  ),
                                  SizedBox(height: (14 * scaleFactor).clamp(12.0, 16.0)),
                                  AnimatedScale(
                                    scale: controller.authController.isLoading.value ? 0.95 : 1.0,
                                    duration: const Duration(milliseconds: 200),
                                    child: ElevatedButton(
                                      onPressed: controller.authController.isLoading.value ? null : controller.signIn,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF1A6B47), // Updated to lighter green
                                        foregroundColor: Colors.white, // Updated for text contrast
                                        padding: EdgeInsets.symmetric(
                                          vertical: (14 * scaleFactor).clamp(12.0, 18.0),
                                          horizontal: (24 * scaleFactor).clamp(20.0, 32.0),
                                        ),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8 * scaleFactor)),
                                        textStyle: TextStyle(
                                          fontSize: (16 * scaleFactor).clamp(14.0, 18.0),
                                          fontWeight: FontWeight.w700,
                                        ),
                                        elevation: controller.authController.isLoading.value ? 0 : 4.0,
                                      ),
                                      child: controller.authController.isLoading.value
                                          ? SizedBox(
                                              width: (24 * scaleFactor).clamp(20.0, 30.0),
                                              height: (24 * scaleFactor).clamp(20.0, 30.0),
                                              child: CircularProgressIndicator(
                                                strokeWidth: (2.0 * scaleFactor).clamp(1.5, 3.0),
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Updated for contrast
                                              ),
                                            )
                                          : Text('login'.tr.toUpperCase()),
                                    ),
                                  ),
                                  SizedBox(height: (8 * scaleFactor).clamp(8.0, 12.0)),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: controller.authController.isLoading.value
                                            ? null
                                            : () {
                                                controller.reset();
                                                Get.offNamed(AppRoutes.getSignUpPage());
                                              },
                                        child: Text(
                                          'dont_have_account'.tr,
                                           style: TextStyle( fontSize: (14 * scaleFactor ).clamp(12.0, 16.0),
                                                color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1A6B47)),
                                        ),
                                      ),
                                      SizedBox(height: (2 * scaleFactor).clamp(2.0, 3.0)),
                                      TextButton(
                                        onPressed: controller.authController.isLoading.value
                                            ? null
                                            : () {
                                                controller.reset();
                                                Get.toNamed(AppRoutes.getRequestPasswordResetPage());
                                              },
                                        child: Text(
                                          'forgot_password'.tr,
                                          style: TextStyle(
                                            fontSize: (14 * scaleFactor ).clamp(12.0, 16.0),
                                                color: theme.brightness == Brightness.dark ? Colors.white : const Color(0xFF1A6B47)),
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