import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../../../../controllers/feedback_controller.dart';
import '../../../widgets/custom_text_field.dart';

class FeedbackScreen extends GetView<FeedbackController> {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Responsive Breakpoints
    const double tinyPhoneMaxWidth = 300;
    const double verySmallPhoneMaxWidth = 360;
    const double smallPhoneMaxWidth = 480;
    const double compactTabletMinWidth = 600;
    const double largeTabletMinWidth = 800;
    const double desktopMinWidth = 1000;

    final bool isTinyPhone = size.width < tinyPhoneMaxWidth;
    final bool isVerySmallPhone = size.width >= tinyPhoneMaxWidth && size.width < verySmallPhoneMaxWidth;
    final bool isSmallPhone = size.width >= verySmallPhoneMaxWidth && size.width < smallPhoneMaxWidth;
    final bool isCompactTablet = size.width >= compactTabletMinWidth && size.width < largeTabletMinWidth;
    final bool isLargeTablet = size.width >= largeTabletMinWidth && size.width < desktopMinWidth;
    final bool isDesktop = size.width >= desktopMinWidth;

    // Responsive Scale Factor
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

    // Responsive Constraints
    final double maxFormWidth = isDesktop
        ? 600
        : isLargeTablet
            ? 500
            : isCompactTablet
                ? 400
                : size.width * (isTinyPhone ? 0.95 : isVerySmallPhone ? 0.92 : 0.9);

    // Responsive Padding
    final double cardPadding = math.max(8.0, 16.0 * scaleFactor).clamp(16.0, 32.0);

    // Responsive Font Sizes
    final double baseTitleFontSize = 20.0;
    final double baseAppBarFontSize = 18.0;
    final double baseFieldLabelFontSize = 12.0;
    final double baseFieldValueFontSize = 14.0;
    final double baseButtonFontSize = 16.0;

    final double titleFontSize = (baseTitleFontSize * scaleFactor).clamp(18.0, 24.0);
    final double appBarFontSize = (baseAppBarFontSize * scaleFactor).clamp(16.0, 20.0);
    final double fieldLabelFontSize = (baseFieldLabelFontSize * scaleFactor).clamp(10.0, 14.0);
    final double fieldValueFontSize = (baseFieldValueFontSize * scaleFactor).clamp(12.0, 16.0);
    final double buttonFontSize = (baseButtonFontSize * scaleFactor).clamp(14.0, 18.0);

    // Responsive Icon and Loader Sizes
    final double iconSize = (20.0 * scaleFactor).clamp(18.0, 24.0);
    final double loaderSize = (24.0 * scaleFactor).clamp(20.0, 30.0);

    // Responsive Spacing
    final double spacingSmall = math.max(8.0, 10 * scaleFactor);
    final double spacingMedium = math.max(12.0, 16 * scaleFactor);
    final double spacingLarge = math.max(18.0, 24 * scaleFactor);

    // Consistent Vertical Padding for Text Fields
    final double consistentVerticalPadding = math.max(12.0, 14 * scaleFactor);

    // Reset controller state after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetState();
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: Text(
          'feedback'.tr,
          style: theme.appBarTheme.titleTextStyle?.copyWith(
                fontSize: appBarFontSize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary,
              ) ??
              TextStyle(
                fontSize: appBarFontSize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary,
              ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary,
            size: iconSize,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxFormWidth.clamp(300, 700),
          ),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: size.width * (isTinyPhone ? 0.03 : 0.04)),
            child: Card(
              elevation: isDarkMode ? 2.0 : 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(math.max(8.0, 12 * scaleFactor)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(cardPadding),
                child: SingleChildScrollView(
                  child: Obx(
                    () => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AnimatedOpacity(
                          opacity: controller.isLoading.value ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            'feedback'.tr,
                            style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                              ) ??
                              TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: spacingLarge),
                        AnimatedOpacity(
                          opacity: controller.isLoading.value ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: CustomTextField(
                            label: 'your_feedback'.tr,
                            controller: controller.feedbackTextController,
                            prefixIcon: Icons.feedback,
                            errorText: controller.feedbackError.value.isEmpty ? null : controller.feedbackError.value,
                            enabled: !controller.isLoading.value,
                            onChanged: controller.validateFeedback,
                            scaleFactor: scaleFactor,
                            fontSize: fieldValueFontSize,
                            labelFontSize: fieldLabelFontSize,
                            iconSize: iconSize,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: math.max(10.0, 12 * scaleFactor),
                              vertical: consistentVerticalPadding,
                            ),
                            borderRadius: math.max(6.0, 8 * scaleFactor),
                            filled: true,
                            fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                            keyboardType: TextInputType.multiline,
                            // Multiline configuration
                            minLines: 3, // Minimum 3 lines for feedback
                            maxLines: 8, // Maximum 8 lines to prevent excessive growth
                            textInputAction: TextInputAction.newline, // Show newline key
                          ),
                        ),
                        SizedBox(height: spacingLarge),
                        AnimatedScale(
                          scale: controller.isLoading.value ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value ? null : controller.submitFeedback,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: math.max(10.0, 14 * scaleFactor)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(math.max(6.0, 8 * scaleFactor)),
                              ),
                              elevation: 3,
                              textStyle: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.w600),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: loaderSize,
                                    height: loaderSize,
                                    child: CircularProgressIndicator(
                                      strokeWidth: math.max(1.5, 2.0 * scaleFactor),
                                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                                    ),
                                  )
                                : Text(
                                    'submit'.tr.toUpperCase(),
                                    style: TextStyle(fontSize: buttonFontSize),
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
      ),
    );
  }
}