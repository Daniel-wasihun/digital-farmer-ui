import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:animated_background/animated_background.dart';
import '../../controllers/auth/signin_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../routes/app_routes.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glassmorphic_card.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SignInController()); // Fresh controller per screen
    final ThemeController themeController = Get.find<ThemeController>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final maxFormWidth = isTablet ? 500.0 : 380.0;

    return Obx(() => AnimatedBackground(
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
          vsync: const _VSyncProvider(),
          child: Scaffold(
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
                Row(
                  children: [
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
                      onPressed: () => controller.authController.toggleLanguage(),
                      tooltip: 'toggle_language'.tr,
                    ),
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
                        child: controller.authController.isLoading.value
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
                                        'signin'.tr,
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
                                      Obx(() => CustomTextField(
                                            label: 'email'.tr,
                                            keyboardType: TextInputType.emailAddress,
                                            prefixIcon: Icons.email,
                                            errorText: controller.authController.emailError.value,
                                            onChanged: controller.onEmailChanged,
                                            scaleFactor: scaleFactor,
                                          )),
                                      SizedBox(height: 10 * scaleFactor),
                                      Obx(() => CustomTextField(
                                            label: 'password'.tr,
                                            obscureText: true,
                                            prefixIcon: Icons.lock,
                                            errorText: controller.authController.passwordError.value,
                                            onChanged: controller.onPasswordChanged,
                                            scaleFactor: scaleFactor,
                                          )),
                                      SizedBox(height: 14 * scaleFactor),
                                      ElevatedButton(
                                        onPressed: controller.signIn,
                                        style: Theme.of(context).elevatedButtonTheme.style,
                                        child: Text(
                                          'login'.tr,
                                          style: TextStyle(
                                            fontSize: 14 * scaleFactor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8 * scaleFactor),
                                      TextButton(
                                        onPressed: () {
                                          controller.reset();
                                          Get.offNamed(AppRoutes.getSignUpPage());
                                        },
                                        child: Text(
                                          'dont_have_account'.tr,
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
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
  }
}

// VSync workaround
class _VSyncProvider implements TickerProvider {
  const _VSyncProvider();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}