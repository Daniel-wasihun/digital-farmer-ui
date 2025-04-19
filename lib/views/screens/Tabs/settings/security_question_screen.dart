import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math; // Import math library
import '../../../../controllers/auth/auth_controller.dart';
import '../../../widgets/custom_text_field.dart'; // Assuming this widget can be styled

class SecurityQuestionScreen extends StatelessWidget {
  const SecurityQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Existing Logic Setup (Unchanged) ---
    final authController = Get.find<AuthController>();
    final answerController = TextEditingController();
    final RxString selectedQuestionKey = RxString('');
    final List<Map<String, String>> securityQuestions = [
      {'key': 'first_pet_name', 'value': 'first_pet_name'.tr},
      {'key': 'mothers_maiden_name', 'value': 'mothers_maiden_name'.tr},
      {'key': 'first_school_name', 'value': 'first_school_name'.tr},
      {'key': 'favorite_book', 'value': 'favorite_book'.tr},
      {'key': 'birth_city', 'value': 'birth_city'.tr},
    ];

    // --- UI & Responsive Setup ---
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Breakpoints (Adjusted for more granular control on smaller screens)
    const double tinyPhoneMaxWidth = 300; // Added tiny phone breakpoint
    const double verySmallPhoneMaxWidth = 360; // Adjusted breakpoint
    const double smallPhoneMaxWidth = 480; // Adjusted breakpoint
    const double compactTabletMinWidth = 600; // Adjusted breakpoint
    const double largeTabletMinWidth = 800; // Adjusted breakpoint
    const double desktopMinWidth = 1000; // Added desktop breakpoint

    final bool isTinyPhone = size.width < tinyPhoneMaxWidth;
    final bool isVerySmallPhone = size.width >= tinyPhoneMaxWidth && size.width < verySmallPhoneMaxWidth;
    final bool isSmallPhone = size.width >= verySmallPhoneMaxWidth && size.width < smallPhoneMaxWidth;
    final bool isCompactTablet = size.width >= compactTabletMinWidth && size.width < largeTabletMinWidth;
    final bool isLargeTablet = size.width >= largeTabletMinWidth && size.width < desktopMinWidth;
    final bool isDesktop = size.width >= desktopMinWidth;

    // Dynamic scaleFactor (Made scaling down more aggressive)
    final double scaleFactor = isDesktop
        ? 1.2 // Increased scale for larger screens
        : isLargeTablet
            ? 1.1
            : isCompactTablet
                ? 1.0
                : isSmallPhone
                    ? 0.9 // More noticeable scaling down
                    : isVerySmallPhone
                        ? 0.75 // Even more aggressive scaling down
                        : isTinyPhone
                            ? 0.6 // Very aggressive scaling down for tiny screens
                            : 1.0; // Default for normal phones

    // Responsive constraints (Reduced max width and height proportionally)
    final double maxFormWidth = isDesktop
        ? 600 // Increased max width for desktop
        : isLargeTablet
            ? 500
            : isCompactTablet
                ? 400
                : size.width * (isTinyPhone ? 0.95 : isVerySmallPhone ? 0.92 : 0.9); // Use more width on smaller phones
    final double maxFormHeight = size.height * (isTinyPhone ? 0.9 : isVerySmallPhone ? 0.85 : isSmallPhone ? 0.8 : 0.7); // Allow more relative height on smaller screens

    // Responsive padding (Reduced base padding significantly)
    final double cardPadding = math.max(8.0, 12.0 * scaleFactor).clamp(10.0, 24.0); // Reduced base padding, clamped

    // Base font sizes (Reduced across the board)
    final double baseTitleFontSize = 15.0; // Reduced base title size
    final double baseAppBarFontSize = 14.0; // Reduced base AppBar size
    final double baseFieldLabelFontSize = 10.0; // Reduced base label/hint size
    final double baseFieldValueFontSize = 11.0; // Reduced base input/dropdown text size
    final double baseButtonFontSize = 11.0; // Reduced base button text size

    // Calculate responsive font sizes WITH CLAMPING (Adjusted clamp range)
    final double titleFontSize = (baseTitleFontSize * scaleFactor).clamp(13.0, 18.0); // Adjusted clamp range
    final double appBarFontSize = (baseAppBarFontSize * scaleFactor).clamp(12.0, 16.0); // Adjusted clamp range
    final double fieldLabelFontSize = (baseFieldLabelFontSize * scaleFactor).clamp(8.0, 12.0); // Adjusted clamp range
    final double fieldValueFontSize = (baseFieldValueFontSize * scaleFactor).clamp(9.0, 13.0); // Adjusted clamp range
    final double buttonFontSize = (baseButtonFontSize * scaleFactor).clamp(10.0, 14.0); // Adjusted clamp range
    final double iconSize = (16.0 * scaleFactor).clamp(12.0, 18.0); // Reduced base icon size, adjusted clamp
    final double dropdownIconSize = (18.0 * scaleFactor).clamp(14.0, 20.0); // Reduced base icon size, adjusted clamp
    final double errorFontSize = (9.0 * scaleFactor).clamp(7.0, 10.0); // Reduced base error size, adjusted clamp
    final double loaderSize = (16.0 * scaleFactor).clamp(14.0, 20.0); // Reduced base loader size, adjusted clamp

    // Responsive Spacing (Reduced base spacing)
    final double spacingVSmall = math.max(2.0, 3 * scaleFactor); // Reduced base spacing
    final double spacingSmall = math.max(4.0, 6 * scaleFactor); // Reduced base spacing
    final double spacingMedium = math.max(6.0, 10 * scaleFactor); // Reduced base spacing
    final double spacingLarge = math.max(10.0, 14 * scaleFactor); // Reduced base spacing

    // Calculate a consistent vertical padding
    final double consistentVerticalPadding = math.max(12.0, 14 * scaleFactor);

    // --- Build Method ---
    return Scaffold(
      // Optional: Add a subtle gradient background?
      // backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        // backgroundColor: Colors.transparent, // Optional: Transparent AppBar
        elevation: 0.5, // Subtle elevation
        title: Text(
          'security_question'.tr,
          style: theme.appBarTheme.titleTextStyle?.copyWith(
                fontSize: appBarFontSize, // Use calculated AppBar font size
                fontWeight: FontWeight.w600,
              ) ??
              TextStyle(
                // Fallback style
                fontSize: appBarFontSize,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimary,
              ),
        ),
        toolbarHeight: (isTinyPhone || isVerySmallPhone || isSmallPhone) ? 45 : 56, // Adjusted toolbar height
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxFormWidth.clamp(240, 600), // Adjusted clamp range
            maxHeight: maxFormHeight.clamp(300, 600), // Adjusted clamp range
          ),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: size.width * (isTinyPhone ? 0.03 : 0.04)), // Reduced horizontal padding on tiny phones
            child: Card(
              elevation: isDarkMode ? 2.0 : 4.0, // Adjust elevation based on mode
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(math.max(8.0, 12 * scaleFactor)) // Adjusted responsive radius
                  ),
              clipBehavior: Clip.antiAlias, // Ensures content respects rounded corners
              child: Padding(
                padding: EdgeInsets.all(cardPadding), // Use responsive card padding
                child: Obx(
                  () => SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Title ---
                        Text(
                          'select_security_question'.tr,
                          style: theme.textTheme.headlineSmall?.copyWith(
                                fontSize: titleFontSize, // Apply clamped font size
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
                        SizedBox(height: spacingLarge), // Use responsive spacing

                        // --- Dropdown ---
                        DropdownButtonFormField<String>(
                          value: selectedQuestionKey.value.isNotEmpty
                              ? selectedQuestionKey.value
                              : null,
                          isExpanded: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                            labelText: 'question'.tr,
                            labelStyle: TextStyle(fontSize: fieldLabelFontSize), // Apply clamped label size
                            prefixIcon: Icon(
                              Icons.help_outline_rounded,
                              size: iconSize, // Apply clamped icon size
                              color: theme.colorScheme.primary,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: math.max(8.0, 10 * scaleFactor), // Reduced padding
                              vertical: consistentVerticalPadding, // Use consistent vertical padding
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(math.max(5.0, 7 * scaleFactor)), // Reduced radius
                                borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(math.max(5.0, 7 * scaleFactor)),
                              borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1), width: 1.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(math.max(5.0, 7 * scaleFactor)),
                              borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(math.max(5.0, 7 * scaleFactor)),
                              borderSide: BorderSide(color: theme.colorScheme.error, width: 1.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(math.max(5.0, 7 * scaleFactor)),
                              borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
                            ),
                            errorText: authController.securityQuestionError.value.isNotEmpty
                                ? authController.securityQuestionError.value
                                : null,
                            errorStyle: TextStyle(fontSize: errorFontSize), // Clamped error size
                          ),
                          items: securityQuestions.map((question) {
                            return DropdownMenuItem<String>(
                              value: question['key'],
                              child: Text(
                                question['value']!,
                                style: TextStyle(fontSize: fieldValueFontSize, fontFamily: 'NotoSansEthiopic'), // Clamped value size
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              selectedQuestionKey.value = value;
                              authController.validateSecurityQuestion(value);
                            }
                          },
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            size: dropdownIconSize, // Clamped icon size
                          ),
                          borderRadius: BorderRadius.circular(math.max(5.0, 7 * scaleFactor)), // Match input border radius
                        ),
                        SizedBox(height: spacingMedium), // Responsive spacing

                        // --- Answer Field ---
                        CustomTextField(
                          label: 'answer'.tr,
                          controller: answerController,
                          prefixIcon: Icons.lock_outline_rounded,
                          errorText: authController.securityAnswerError.value,
                          onChanged: (value) => authController.validateSecurityAnswer(value),
                          scaleFactor: scaleFactor, // Pass scale factor
                          // Pass new styling props
                          fontSize: fieldValueFontSize, // Use clamped value size
                          labelFontSize: fieldLabelFontSize, // Use clamped label size
                          iconSize: iconSize, // Use clamped icon size
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: math.max(8.0, 10 * scaleFactor), // Reduced padding
                            vertical: consistentVerticalPadding, // Use the same consistent vertical padding
                          ),
                          borderRadius: math.max(5.0, 7 * scaleFactor), // Reduced radius
                          filled: true,
                          fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (!authController.isLoading.value) {
                              if (selectedQuestionKey.value.isEmpty) {
                                authController.securityQuestionError.value =
                                    'please_select_question'.tr;
                                return;
                              }
                              final selectedQuestion = securityQuestions
                                  .firstWhere((q) => q['key'] == selectedQuestionKey.value)['value']!;
                              authController.setSecurityQuestion(
                                selectedQuestion,
                                answerController.text,
                              );
                            }
                          },
                        ),
                        SizedBox(height: spacingLarge + spacingSmall), // More space before button

                        // --- Button ---
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: math.max(10.0, 12 * scaleFactor), // Reduced padding
                                horizontal: math.max(16.0, 20 * scaleFactor) // Reduced padding
                                ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(math.max(5.0, 7 * scaleFactor)), // Matching reduced radius
                            ),
                            textStyle: TextStyle(
                              fontSize: buttonFontSize, // Clamped button font size
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 2.0,
                          ),
                          onPressed: authController.isLoading.value
                              ? null
                              : () {
                                  if (selectedQuestionKey.value.isEmpty) {
                                    authController.securityQuestionError.value =
                                        'please_select_question'.tr;
                                    return;
                                  }
                                  final selectedQuestion = securityQuestions
                                      .firstWhere((q) => q['key'] == selectedQuestionKey.value)['value']!;
                                  authController.setSecurityQuestion(
                                    selectedQuestion,
                                    answerController.text,
                                  );
                                },
                          child: authController.isLoading.value
                              ? SizedBox(
                                  width: loaderSize,
                                  height: loaderSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth: math.max(1.5, 2.0 * scaleFactor), // Reduced stroke width
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        theme.colorScheme.onPrimary),
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
          ),
        ),
      ),
    );
  }
}