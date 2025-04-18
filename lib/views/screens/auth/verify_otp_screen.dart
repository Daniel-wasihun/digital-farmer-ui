import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glassmorphic_card.dart';

class VerifyOTPScreen extends GetView<AuthController> {
  const VerifyOTPScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final String email = args['email'];
    final String type = args['type'] ?? 'signup'; // 'signup' or 'password_reset'
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final maxFormWidth = isTablet ? 500.0 : 380.0;

    final otpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'verify_otp'.tr,
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
                                  'verify_otp'.tr,
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
                                  'enter_otp_sent_to'.tr + ' $email',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 16 * scaleFactor,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 14 * scaleFactor),
                                CustomTextField(
                                  controller: otpController,
                                  label: 'otp'.tr,
                                  prefixIcon: Icons.lock,
                                  keyboardType: TextInputType.number,
                                  scaleFactor: scaleFactor,
                                ),
                                SizedBox(height: 14 * scaleFactor),
                                ElevatedButton(
                                  onPressed: () {
                                    if (type == 'password_reset') {
                                      controller.verifyPasswordResetOTP(email, otpController.text);
                                    } else {
                                      controller.verifyOTP(email, otpController.text);
                                    }
                                  },
                                  style: Theme.of(context).elevatedButtonTheme.style,
                                  child: Text(
                                    'verify'.tr,
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
                                    controller.resendOTP(email, type);
                                  },
                                  child: Text(
                                    'resend_otp'.tr,
                                    style: Theme.of(context)
                                        .textButtonTheme
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