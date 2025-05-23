import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;
import '../../../../controllers/auth/auth_controller.dart';
import '../../../widgets/custom_text_field.dart';

class SecurityQuestionScreenController extends GetxController {
  final RxString selectedQuestionKey = ''.obs;
  final answerController = TextEditingController();

  @override
  void onClose() {
    answerController.dispose();
    super.onClose();
  }
}

class SecurityQuestionScreen extends GetView<AuthController> {
  const SecurityQuestionScreen({super.key});

  static void show() {
    Get.dialog(
      const SecurityQuestionScreen(),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 400),
      transitionCurve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final securityController = Get.put(SecurityQuestionScreenController());
    final answerController = securityController.answerController;
    final selectedQuestionKey = securityController.selectedQuestionKey;
    final logger = Logger();

    final List<Map<String, String>> securityQuestions = [
      {'key': 'first_pet_name', 'value': 'first_pet_name'.tr},
      {'key': 'mothers_maiden_name', 'value': 'mothers_maiden_name'.tr},
      {'key': 'first_school_name', 'value': 'first_school_name'.tr},
      {'key': 'favorite_book', 'value': 'favorite_book'.tr},
      {'key': 'birth_city', 'value': 'birth_city'.tr},
    ];

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1A252F) : Colors.white;

    const double tinyPhoneMaxWidth = 300;
    const double verySmallPhoneMaxWidth = 360;
    const double smallPhoneMaxWidth = 480;
    const double compactTabletMinWidth = 600;
    const double largeTabletMinWidth = 800;
    const double desktopMinWidth = 1000;

    final bool isTinyPhone = size.width < tinyPhoneMaxWidth;
    final bool isVerySmallPhone =
        size.width >= tinyPhoneMaxWidth && size.width < verySmallPhoneMaxWidth;
    final bool isSmallPhone = size.width >= verySmallPhoneMaxWidth &&
        size.width < smallPhoneMaxWidth;
    final bool isCompactTablet = size.width >= compactTabletMinWidth &&
        size.width < largeTabletMinWidth;
    final bool isLargeTablet = size.width >= largeTabletMinWidth &&
        size.width < desktopMinWidth;
    final bool isDesktop = size.width >= desktopMinWidth;

    final double scaleFactor = isDesktop
        ? 1.2
        : isLargeTablet
            ? 1.1
            : isCompactTablet
                ? 1.0
                : isSmallPhone
                    ? 0.9
                    : isVerySmallPhone
                        ? 0.75
                        : isTinyPhone
                            ? 0.6
                            : 1.0;

    final double maxFormWidth = isDesktop
        ? 600
        : isLargeTablet
            ? 500
            : isCompactTablet
                ? 400
                : size.width *
                    (isTinyPhone
                        ? 0.95
                        : isVerySmallPhone
                            ? 0.92
                            : 0.9);
    final double maxFormHeight = size.height *
        (isTinyPhone
            ? 0.9
            : isVerySmallPhone
                ? 0.85
                : isSmallPhone
                    ? 0.8
                    : 0.7);

    final double dialogHorizontalPadding =
        (size.width * 0.05 * scaleFactor).clamp(16.0, 40.0);
    final double cardPadding =
        math.max(8.0, 12.0 * scaleFactor).clamp(10.0, 24.0);

    final double baseTitleFontSize = 18.0;
    final double baseAppBarFontSize = 16.0;
    final double baseFieldLabelFontSize = 12.0;
    final double baseFieldValueFontSize = 14.0;
    final double baseButtonFontSize = 14.0;

    final double titleFontSize =
        (baseTitleFontSize * scaleFactor).clamp(16.0, 22.0);
    final double appBarFontSize =
        (baseAppBarFontSize * scaleFactor).clamp(14.0, 18.0);
    final double fieldLabelFontSize =
        (baseFieldLabelFontSize * scaleFactor).clamp(10.0, 14.0);
    final double fieldValueFontSize =
        (baseFieldValueFontSize * scaleFactor).clamp(12.0, 16.0);
    final double buttonFontSize =
        (baseButtonFontSize * scaleFactor).clamp(12.0, 16.0);
    final double iconSize = (20.0 * scaleFactor).clamp(16.0, 22.0);
    final double dropdownIconSize = (22.0 * scaleFactor).clamp(18.0, 24.0);
    final double errorFontSize = (10.0 * scaleFactor).clamp(8.0, 12.0);
    final double loaderSize = (20.0 * scaleFactor).clamp(18.0, 24.0);
    final double closeIconSize = (20.0 * scaleFactor).clamp(18.0, 24.0);

    final double spacingVSmall = math.max(2.0, 4 * scaleFactor);
    final double spacingSmall = math.max(4.0, 8 * scaleFactor);
    final double spacingMedium = math.max(8.0, 12 * scaleFactor);
    final double spacingLarge = math.max(12.0, 16 * scaleFactor);
    final double spacingExtraLarge = math.max(16.0, 20 * scaleFactor);

    final double consistentVerticalPadding = math.max(12.0, 14 * scaleFactor);
    final double consistentInputHeight = 56.0;

    // Consolidated submission logic
    void submitSecurityQuestion() {
      if (!controller.isLoading.value) {
        if (selectedQuestionKey.value.isEmpty) {
          controller.securityQuestionError.value = 'please_select_question'.tr;
          return;
        }
        final selectedQuestion = securityQuestions
            .firstWhere((q) => q['key'] == selectedQuestionKey.value)['value']!;
        controller.setSecurityQuestion(
          selectedQuestion,
          answerController.text,
        ).then((_) {
          logger.i('Security question submission: questionError=${controller.securityQuestionError.value}, answerError=${controller.securityAnswerError.value}');
          if (controller.securityQuestionError.value.isEmpty &&
              controller.securityAnswerError.value.isEmpty) {
            Get.snackbar(
              'success'.tr,
              'security_question_updated'.tr,
              backgroundColor: const Color(0xFF1A6B47), // Updated to lighter green
              colorText: Colors.white, // Updated for contrast
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
              duration: const Duration(milliseconds: 1500),
            );
            answerController.clear();
            selectedQuestionKey.value = '';
            Get.back();
          } else {
            Get.snackbar(
              'error'.tr,
              controller.securityQuestionError.value.isNotEmpty
                  ? controller.securityQuestionError.value
                  : controller.securityAnswerError.value.isNotEmpty
                      ? controller.securityAnswerError.value
                      : 'security_question_failed'.tr,
              backgroundColor: theme.colorScheme.error,
              colorText: theme.colorScheme.onError,
              snackPosition: SnackPosition.TOP,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
              duration: const Duration(milliseconds: 1500),
            );
          }
        }).catchError((e) {
          logger.e('Security question submission failed: $e');
          Get.snackbar(
            'error'.tr,
            'security_question_failed'.tr,
            backgroundColor: theme.colorScheme.error,
            colorText: theme.colorScheme.onError,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            duration: const Duration(milliseconds: 1500),
          );
        });
      }
    }

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * scaleFactor)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: dialogHorizontalPadding,
        vertical: spacingLarge,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxFormWidth.clamp(240, 600),
          maxHeight: maxFormHeight.clamp(300, 600),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: isDarkMode ? 6.0 : 10.0,
              color: cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * scaleFactor)),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Obx(
                  () => SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: spacingSmall,
                            left: spacingExtraLarge,
                            right: spacingExtraLarge,
                            bottom: spacingLarge,
                          ),
                          child: Text(
                            'select_security_question'.tr,
                            style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ) ??
                                TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: spacingLarge),
                        SizedBox(
                          height: consistentInputHeight,
                          child: DropdownButtonFormField<String>(
                            value: selectedQuestionKey.value.isNotEmpty
                                ? selectedQuestionKey.value
                                : null,
                            isExpanded: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor:
                                  theme.colorScheme.onSurface.withOpacity(0.05),
                              labelText: 'question'.tr,
                              labelStyle:
                                  TextStyle(fontSize: fieldLabelFontSize),
                              prefixIcon: Icon(
                                Icons.help_outline_rounded,
                                size: iconSize,
                                color: theme.colorScheme.primary,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      math.max(5.0, 7 * scaleFactor)),
                                  borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    math.max(5.0, 7 * scaleFactor)),
                                borderSide: BorderSide(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.1),
                                    width: 1.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    math.max(5.0, 7 * scaleFactor)),
                                borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    math.max(5.0, 7 * scaleFactor)),
                                borderSide: BorderSide(
                                    color: theme.colorScheme.error, width: 1.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    math.max(5.0, 7 * scaleFactor)),
                                borderSide: BorderSide(
                                    color: theme.colorScheme.error,
                                    width: 1.5),
                              ),
                              errorText: controller
                                      .securityQuestionError.value.isNotEmpty
                                  ? controller.securityQuestionError.value
                                  : null,
                              errorStyle: TextStyle(fontSize: errorFontSize),
                            ),
                            items: securityQuestions.map((question) {
                              return DropdownMenuItem<String>(
                                value: question['key'],
                                child: Text(
                                  question['value']!,
                                  style: TextStyle(
                                      fontSize: fieldValueFontSize,
                                      fontFamily: 'NotoSansEthiopic'),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectedQuestionKey.value = value;
                                controller.validateSecurityQuestion(value);
                              }
                            },
                            icon: Icon(
                              Icons.arrow_drop_down_rounded,
                              size: dropdownIconSize,
                            ),
                            borderRadius: BorderRadius.circular(
                                math.max(5.0, 7 * scaleFactor)),
                          ),
                        ),
                        SizedBox(height: spacingMedium),
                        SizedBox(
                          height: consistentInputHeight*1.2,
                          child: CustomTextField(
                            label: 'answer'.tr,
                            controller: answerController,
                            prefixIcon: Icons.lock_outline_rounded,
                            errorText: controller.securityAnswerError.value,
                            onChanged: controller.validateSecurityAnswer,
                            scaleFactor: scaleFactor,
                            fontSize: fieldValueFontSize*2,
                            labelFontSize: fieldLabelFontSize,
                            iconSize: iconSize,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            borderRadius: math.max(5.0, 7 * scaleFactor),
                            filled: true,
                            fillColor:
                                theme.colorScheme.onSurface.withOpacity(0.05),
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            maxLines: 1,
                            onSubmitted: (_) => submitSecurityQuestion(),
                          ),
                        ),
                        SizedBox(height: spacingLarge + spacingSmall),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A6B47), // Updated to lighter green
                            foregroundColor: Colors.white, // Updated for text contrast
                            padding: EdgeInsets.symmetric(
                                vertical: math.max(10.0, 12 * scaleFactor),
                                horizontal: math.max(16.0, 20 * scaleFactor)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  math.max(5.0, 7 * scaleFactor)),
                            ),
                            textStyle: TextStyle(
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 2.0,
                          ),
                          onPressed: controller.isLoading.value
                              ? null
                              : submitSecurityQuestion,
                          child: controller.isLoading.value
                              ? SizedBox(
                                  width: loaderSize,
                                  height: loaderSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth:
                                        math.max(1.5, 2.0 * scaleFactor),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white), // Updated for contrast
                                  ),
                                )
                              : Text('update_security_question'.tr.toUpperCase()),
                        ),
                        SizedBox(height: spacingSmall),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -spacingMedium * 0,
              right: -spacingMedium * 0,
              child: InkWell(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(spacingMedium / 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A6B47), // Updated to lighter green
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: closeIconSize,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}