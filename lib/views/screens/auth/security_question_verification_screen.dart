import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../controllers/auth/auth_controller.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../../routes/app_routes.dart';

class SecurityQuestionVerificationScreen extends GetView<AuthController> {
  const SecurityQuestionVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Get.arguments['email'] as String;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final scaleFactor = isTablet
        ? (size.width / 720).clamp(1.0, 1.2)
        : (size.width / 360).clamp(0.8, 1.0) * (size.height / 640).clamp(0.85, 1.0);
    final maxFormWidth = isTablet ? 500.0 : 380.0;

    // List of security questions (translation keys)
    final List<Map<String, String>> securityQuestions = [
      {'key': 'first_pet_name', 'value': 'first_pet_name'.tr},
      {'key': 'mothers_maiden_name', 'value': 'mothers_maiden_name'.tr},
      {'key': 'first_school_name', 'value': 'first_school_name'.tr},
      {'key': 'favorite_book', 'value': 'favorite_book'.tr},
      {'key': 'birth_city', 'value': 'birth_city'.tr},
    ];

    final RxString selectedQuestionKey = RxString('');
    final answerController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'verify_security_question'.tr,
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
                                  'verify_security_question'.tr,
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
                                  'answer_security_question'.tr,
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        fontSize: 16 * scaleFactor,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 14 * scaleFactor),
                                DropdownButtonFormField<String>(
                                  value: selectedQuestionKey.value.isNotEmpty
                                      ? selectedQuestionKey.value
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: 'question'.tr,
                                    labelStyle: TextStyle(fontSize: 12 * scaleFactor),
                                    prefixIcon: Icon(
                                      Icons.help,
                                      size: 18 * scaleFactor,
                                      color: Colors.green[700],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10 * scaleFactor),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12 * scaleFactor,
                                      vertical: 10 * scaleFactor,
                                    ),
                                    errorText:
                                        controller.securityQuestionError.value.isNotEmpty
                                            ? controller.securityQuestionError.value
                                            : null,
                                  ),
                                  hint: Text(
                                    'select_your_question'.tr,
                                    style: TextStyle(
                                      fontSize: 12 * scaleFactor,
                                      fontFamily: 'NotoSansEthiopic',
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  items: securityQuestions.map((question) {
                                    return DropdownMenuItem<String>(
                                      value: question['key'],
                                      child: Text(
                                        question['value']!,
                                        style: TextStyle(
                                          fontSize: 12 * scaleFactor,
                                          fontFamily: 'NotoSansEthiopic',
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value != null) {
                                      selectedQuestionKey.value = value;
                                      controller.validateSecurityQuestion(value);
                                    }
                                  },
                                ),
                                SizedBox(height: 10 * scaleFactor),
                                Obx(() => CustomTextField(
                                      controller: answerController,
                                      label: 'answer'.tr,
                                      prefixIcon: Icons.lock,
                                      errorText: controller.securityAnswerError.value,
                                      onChanged: (value) {
                                        // Sanitize the input to prevent invalid characters
                                        final sanitizedValue =
                                            value.replaceAll(RegExp(r'[<>]'), '');
                                        answerController.text = sanitizedValue;
                                        answerController.selection = TextSelection.fromPosition(
                                            TextPosition(offset: sanitizedValue.length));
                                        controller.validateSecurityAnswer(sanitizedValue);
                                      },
                                      scaleFactor: scaleFactor,
                                    )),
                                SizedBox(height: 14 * scaleFactor),
                                ElevatedButton(
                                  onPressed: () {
                                    if (selectedQuestionKey.value.isEmpty) {
                                      controller.securityQuestionError.value =
                                          'please_select_question'.tr;
                                      return;
                                    }
                                    final selectedQuestion = securityQuestions
                                        .firstWhere((q) => q['key'] == selectedQuestionKey.value)[
                                            'value']!;
                                    print('Submitting: email=$email, question=$selectedQuestion, answer=${answerController.text}');
                                    controller.verifySecurityAnswer(
                                      email,
                                      selectedQuestion,
                                      answerController.text,
                                      (resetToken) {
                                        print('Success: resetToken=$resetToken');
                                        Get.offNamed(
                                          AppRoutes.getResetPasswordPage(),
                                          arguments: {
                                            'resetToken': resetToken,
                                            'email': email,
                                          },
                                        );
                                      },
                                    );
                                  },
                                  style: Theme.of(context).elevatedButtonTheme.style,
                                  child: Text(
                                    'verify_answer'.tr,
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