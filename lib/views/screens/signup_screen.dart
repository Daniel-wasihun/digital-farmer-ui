import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_background/animated_background.dart';
import '../../controllers/auth_controller.dart';
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
    // Responsive scaleFactor based on width and height
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final formWidth = isTablet ? size.width * 0.75 : size.width * 0.85;
    final maxFormWidth = isTablet ? 500.0 : 380.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'signup'.tr,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 18 * scaleFactor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.grey.shade800, size: 20 * scaleFactor),
            onPressed: () => authController.toggleLanguage(),
            tooltip: 'toggle_language'.tr,
          ),
        ],
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Colors.blue.shade100,
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
              colors: [
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
                                color: Colors.blue.shade300,
                                size: 32 * scaleFactor,
                              ),
                            )
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: formWidth.clamp(280, maxFormWidth),
                              ),
                              child: GlassmorphicCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'signup'.tr,
                                      style: TextStyle(
                                        fontSize: 22 * scaleFactor,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey.shade800,
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade200,
                                        foregroundColor: Colors.grey.shade800,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10 * scaleFactor,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 3,
                                        shadowColor: Colors.black12,
                                      ),
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
                                          color: Colors.blue.shade300,
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