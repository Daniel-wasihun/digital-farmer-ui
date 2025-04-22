import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math; // Import math for clamp and max

// Import the FeedbackController
import '../../../../controllers/feedback_controller.dart'; // Adjust the path as needed

// Import your CustomTextField widget
import '../../../widgets/custom_text_field.dart';

class FeedbackScreen extends GetView<FeedbackController> {
  const FeedbackScreen({super.key});

  // Static method to show the screen as a dialog
  static void show() {
    // Ensure the controller is initialized before showing the dialog
    Get.put(FeedbackController()); // Initialize the controller
    Get.dialog(
      const FeedbackScreen(),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 400),
      transitionCurve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Reset state after the dialog is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("FeedbackScreen dialog built, resetting state.");
      controller.resetState(); // Reset form state in controller
    });

    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // --- Responsive Breakpoints ---
    const double tinyPhoneMaxWidth = 300;
    const double verySmallPhoneMaxWidth = 360;
    const double smallPhoneMaxWidth = 480;
    const double compactTabletMinWidth = 600;
    const double largeTabletMinWidth = 800;
    const double desktopMinWidth = 1000;

    final bool isTinyPhone = size.width < tinyPhoneMaxWidth;
    final bool isVerySmallPhone =
        size.width >= tinyPhoneMaxWidth && size.width < verySmallPhoneMaxWidth;
    final bool isSmallPhone =
        size.width >= verySmallPhoneMaxWidth && size.width < smallPhoneMaxWidth;
    final bool isCompactTablet =
        size.width >= compactTabletMinWidth && size.width < largeTabletMinWidth;
    final bool isLargeTablet =
        size.width >= largeTabletMinWidth && size.width < desktopMinWidth;
    final bool isDesktop = size.width >= desktopMinWidth;

    // --- Responsive Scale Factor ---
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

    // --- Responsive Constraints ---
    final double maxContentWidth = isDesktop
        ? 600
        : isLargeTablet
            ? 500
            : isCompactTablet
                ? 400
                : size.width *
                    (isTinyPhone ? 0.95 : isVerySmallPhone ? 0.92 : 0.9);
    final double maxContentHeight =
        (size.height * 0.7 * scaleFactor).clamp(250.0, 450.0);

    // --- Responsive Padding ---
    final double dialogHorizontalPadding =
        (size.width * 0.05 * scaleFactor).clamp(16.0, 40.0);
    final double cardContentPadding =
        (16.0 * scaleFactor).clamp(12.0, 24.0);

    // --- Responsive Font Sizes ---
    final double baseTitleFontSize = 20.0;
    final double baseFieldLabelFontSize = 12.0;
    final double baseFieldValueFontSize = 14.0;
    final double baseButtonFontSize = 16.0;

    final double titleFontSize =
        (baseTitleFontSize * scaleFactor).clamp(16.0, 24.0);
    final double fieldLabelFontSize =
        (baseFieldLabelFontSize * scaleFactor).clamp(10.0, 14.0);
    final double fieldValueFontSize =
        (baseFieldValueFontSize * scaleFactor).clamp(12.0, 16.0);
    final double buttonFontSize =
        (baseButtonFontSize * scaleFactor).clamp(14.0, 18.0);

    // --- Responsive Icon Sizes ---
    final double iconSize = (20.0 * scaleFactor).clamp(18.0, 24.0);
    final double closeIconSize = (20.0 * scaleFactor).clamp(18.0, 24.0);

    // --- Responsive Loader Size ---
    final double loaderSize = (24.0 * scaleFactor).clamp(20.0, 30.0);

    // --- Responsive Spacing ---
    final double spacingExtraSmall = (4.0 * scaleFactor).clamp(4.0, 8.0);
    final double spacingSmall = (8.0 * scaleFactor).clamp(8.0, 12.0);
    final double spacingMedium = (12.0 * scaleFactor).clamp(12.0, 16.0);
    final double spacingLarge = (16.0 * scaleFactor).clamp(16.0, 24.0);
    final double spacingExtraLarge = (24.0 * scaleFactor).clamp(24.0, 32.0);

    // --- Consistent Vertical Padding for Text Fields ---
    final double consistentVerticalPadding =
        (12.0 * scaleFactor).clamp(10.0, 16.0);

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
          maxWidth: maxContentWidth,
          maxHeight: maxContentHeight,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Card(
              elevation: isDarkMode ? 6.0 : 10.0,
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16 * scaleFactor)),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: EdgeInsets.all(cardContentPadding),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title Text
                      Padding(
                        padding: EdgeInsets.only(
                          top: spacingSmall,
                          left: spacingExtraLarge,
                          right: spacingExtraLarge,
                          bottom: spacingLarge,
                        ),
                        child: Text(
                          'feedback'.tr,
                          style: theme.textTheme.headlineSmall?.copyWith(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                shadows: isDarkMode
                                    ? null
                                    : [
                                        Shadow(
                                          blurRadius: 6.0,
                                          color: Colors.black.withOpacity(0.2),
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                              ) ??
                              TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Feedback Text Field
                      Obx(
                        () => AnimatedOpacity(
                          opacity: controller.isLoading.value ? 0.5 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: CustomTextField(
                            label: 'your_feedback'.tr,
                            controller: controller.feedbackTextController,
                            prefixIcon: Icons.feedback,
                            errorText: controller.feedbackError.value.isEmpty
                                ? null
                                : controller.feedbackError.value,
                            enabled: !controller.isLoading.value,
                            onChanged: controller.validateFeedback,
                            scaleFactor: scaleFactor,
                            fontSize: fieldValueFontSize,
                            labelFontSize: fieldLabelFontSize,
                            iconSize: iconSize,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: spacingSmall,
                                vertical: consistentVerticalPadding),
                            borderRadius: 8 * scaleFactor,
                            filled: true,
                            fillColor: theme.colorScheme.onSurface
                                .withOpacity(isDarkMode ? 0.1 : 0.05),
                            keyboardType: TextInputType.multiline,
                            minLines: 3,
                            maxLines: 8,
                            textInputAction: TextInputAction.newline,
                          ),
                        ),
                      ),
                      SizedBox(height: spacingLarge),
                      // Submit Button
                      Obx(
                        () => AnimatedScale(
                          scale: controller.isLoading.value ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.submitFeedback,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.elevatedButtonTheme.style
                                      ?.backgroundColor
                                      ?.resolve({WidgetState.pressed}) ??
                                  theme.colorScheme.primary,
                              foregroundColor: theme.elevatedButtonTheme.style
                                      ?.foregroundColor
                                      ?.resolve({WidgetState.pressed}) ??
                                  theme.colorScheme.onPrimary,
                              padding: EdgeInsets.symmetric(
                                  vertical: math.max(10.0, 14 * scaleFactor)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    math.max(6.0, 8 * scaleFactor)),
                              ),
                              elevation: 3,
                              textStyle: TextStyle(
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.w600),
                            ),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: loaderSize,
                                    height: loaderSize,
                                    child: CircularProgressIndicator(
                                      strokeWidth:
                                          math.max(1.5, 2.0 * scaleFactor),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.onPrimary),
                                    ),
                                  )
                                : Text(
                                    'submit_feedback'.tr.toUpperCase(),
                                    style: TextStyle(fontSize: buttonFontSize),
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: spacingMedium),
                    ],
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
                    color: theme.colorScheme.secondaryContainer,
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