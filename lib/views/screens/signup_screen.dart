import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_background/animated_background.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../widgets/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('signup'.tr, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.language, color: Colors.white),
            onPressed: () => authController.toggleLanguage(),
            tooltip: 'toggle_language'.tr,
          ),
        ],
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            baseColor: Colors.teal,
            spawnMinSpeed: 10.0,
            spawnMaxSpeed: 50.0,
            particleCount: 50,
            spawnOpacity: 0.3,
          ),
        ),
        vsync: this,
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [Colors.blueAccent.withOpacity(0.7), Colors.teal.withOpacity(0.9)],
              center: Alignment.center,
              radius: 1.5,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Obx(
                () => authController.isLoading.value
                    ? Center(
                        child: SpinKitWave(
                          color: Colors.white,
                          size: 50.0,
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 20),
                            Text(
                              'signup'.tr,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10.0,
                                    color: Colors.black45,
                                    offset: Offset(2.0, 2.0),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 30),
                            Card(
                              elevation: 12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              color: Colors.white.withOpacity(0.95),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      label: 'username'.tr,
                                      controller: usernameController,
                                      prefixIcon: Icons.person,
                                      errorText: authController.usernameError.value,
                                      onChanged: (value) =>
                                          authController.validateUsername(value),
                                    ),
                                    SizedBox(height: 16),
                                    CustomTextField(
                                      label: 'email'.tr,
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icons.email,
                                      errorText: authController.emailError.value,
                                      onChanged: (value) =>
                                          authController.validateEmail(value),
                                    ),
                                    SizedBox(height: 16),
                                    CustomTextField(
                                      label: 'password'.tr,
                                      controller: passwordController,
                                      obscureText: true,
                                      prefixIcon: Icons.lock,
                                      errorText: authController.passwordError.value,
                                      onChanged: (value) =>
                                          authController.validatePassword(value),
                                    ),
                                    SizedBox(height: 16),
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
                                    ),
                                    SizedBox(height: 20),
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
                                        backgroundColor: Colors.tealAccent,
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 8,
                                        shadowColor: Colors.black45,
                                      ),
                                      child: Text(
                                        'create_account'.tr,
                                        style: TextStyle(
                                            fontSize: 18, color: Colors.black87),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: Text(
                                        'already_have_account'.tr,
                                        style: TextStyle(
                                            color: Colors.teal[800], fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}