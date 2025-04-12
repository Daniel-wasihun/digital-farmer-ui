import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_background/animated_background.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('signin'.tr, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () => authController.toggleLanguage(),
            tooltip: 'toggle_language'.tr,
          ),
        ],
      ),
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: const ParticleOptions(
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
                    ? const Center(
                        child: SpinKitWave(
                          color: Colors.white,
                          size: 50.0,
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              'signin'.tr,
                              style: const TextStyle(
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
                            const SizedBox(height: 30),
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
                                      label: 'email'.tr,
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      prefixIcon: Icons.email,
                                      errorText: authController.emailError.value,
                                      onChanged: (value) =>
                                          authController.validateEmail(value),
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      label: 'password'.tr,
                                      controller: passwordController,
                                      obscureText: true,
                                      prefixIcon: Icons.lock,
                                      errorText: authController.passwordError.value,
                                      onChanged: (value) =>
                                          authController.validatePassword(value),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        authController.signin(
                                          emailController.text,
                                          passwordController.text,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.tealAccent,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 8,
                                        shadowColor: Colors.black45,
                                      ),
                                      child: Text(
                                        'login'.tr,
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black87),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: () => Get.toNamed('signup'),
                                      child: Text(
                                        'dont_have_account'.tr,
                                        style: const TextStyle(
                                            color: Colors.teal, fontSize: 16),
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