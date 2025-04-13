import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_background/animated_background.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../models/user_model.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glassmorphic_card.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final maxFormWidth = isTablet ? 500.0 : 380.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'app_title'.tr,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontSize: 18 * scaleFactor,
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          // Combine theme toggle and language indicator in a single Obx to avoid stacking
          Obx(() => Row(
                children: [
                  IconButton(
                    icon: Icon(
                      themeController.isDarkMode.value
                          ? Icons.light_mode
                          : Icons.dark_mode,
                      size: 20 * scaleFactor,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => themeController.toggleTheme(),
                    tooltip: themeController.isDarkMode.value
                        ? 'switch_to_light_mode'.tr
                        : 'switch_to_dark_mode'.tr,
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8 * scaleFactor),
                    child: Text(
                      Get.locale?.languageCode == 'am' ? 'አማ' : 'En',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontSize: 16 * scaleFactor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.language,
                      size: 20 * scaleFactor,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () => authController.toggleLanguage(),
                    tooltip: 'toggle_language'.tr,
                  ),
                  SizedBox(width: 8 * scaleFactor),
                ],
              )),
        ],
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.blue.shade700
                : Colors.blue.shade100,
            spawnMinSpeed: 6.0,
            spawnMaxSpeed: 30.0,
            particleCount: 50,
            spawnOpacity: 0.15,
            maxOpacity: 0.3,
          ),
        ),
        vsync: this,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      Colors.blueGrey.shade800.withOpacity(0.9),
                      Colors.grey.shade900.withOpacity(0.95),
                    ]
                  : [
                      Colors.blue.shade50.withOpacity(0.9),
                      Colors.white.withOpacity(0.95),
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
                      () => authController.isLoading.value
                          ? Center(
                              child: SpinKitFadingCube(
                                color: Theme.of(context).primaryColor,
                                size: 32 * scaleFactor,
                              ),
                            )
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: (isTablet
                                        ? size.width * 0.75
                                        : size.width * 0.85)
                                    .clamp(280, maxFormWidth),
                              ),
                              child: GlassmorphicCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'signup'.tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(
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
                                    CustomTextField(
                                      label: 'username'.tr,
                                      controller: usernameController,
                                      prefixIcon: Icons.person,
                                      errorText: authController.usernameError.value,
                                      onChanged: (value) =>
                                          authController.validateUsername(value),
                                      scaleFactor: scaleFactor,
                                    ),
                                    SizedBox(height: 10 * scaleFactor),
                                    CustomTextField(
                                      label: 'email'.tr,
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icons.email,
                                      errorText: authController.emailError.value,
                                      onChanged: (value) =>
                                          authController.validateEmail(value),
                                      scaleFactor: scaleFactor,
                                    ),
                                    SizedBox(height: 10 * scaleFactor),
                                    CustomTextField(
                                      label: 'password'.tr,
                                      controller: passwordController,
                                      obscureText: true,
                                      prefixIcon: Icons.lock,
                                      errorText: authController.passwordError.value,
                                      onChanged: (value) =>
                                          authController.validatePassword(value),
                                      scaleFactor: scaleFactor,
                                    ),
                                    SizedBox(height: 10 * scaleFactor),
                                    CustomTextField(
                                      label: 'confirm_password'.tr,
                                      controller: confirmPasswordController,
                                      obscureText: true,
                                      prefixIcon: Icons.lock_outline,
                                      errorText:
                                          authController.confirmPasswordError.value,
                                      onChanged: (value) =>
                                          authController.validateConfirmPassword(
                                              passwordController.text, value),
                                      scaleFactor: scaleFactor,
                                    ),
                                    SizedBox(height: 14 * scaleFactor),
                                    ElevatedButton(
                                      onPressed: () {
                                        final user = UserModel(
                                          id: '',
                                          username: usernameController.text,
                                          email: emailController.text,
                                          role: 'user',
                                        );
                                        authController.signup(
                                          user,
                                          passwordController.text,
                                          confirmPasswordController.text,
                                        );
                                      },
                                      style: Theme.of(context).elevatedButtonTheme.style,
                                      child: Text(
                                        'create_account'.tr,
                                        style: TextStyle(
                                          fontSize: 14 * scaleFactor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8 * scaleFactor),
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: Text(
                                        'already_have_account'.tr,
                                        style: TextStyle(
                                          fontSize: 12 * scaleFactor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
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