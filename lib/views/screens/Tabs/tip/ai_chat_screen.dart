import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../controllers/chat/ai_chat_controller.dart';
import '../../../../controllers/theme_controller.dart';
import '../../../../routes/app_routes.dart'; // Added for navigation
import 'message_list.dart';

class AIChatScreen extends GetView<AIChatController> {
  const AIChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AIChatController());
    final ThemeController themeController = Get.find<ThemeController>();
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive scaling factor
    final double scaleFactor = (0.9 + (screenWidth - 320) / (1200 - 320) * (1.6 - 0.9)).clamp(0.9, 1.6);
    final double adjustedScaleFactor = scaleFactor * 1.1;

    // Dynamic responsive padding
    final double padding = (8 + (screenWidth - 320) / (1200 - 320) * (32 - 8)).clamp(8.0, 32.0);

    // Font sizes
    final double titleFontSize = (20.0 * adjustedScaleFactor).clamp(16.0, 28.0);
    final double detailFontSize = (14.0 * adjustedScaleFactor * 0.9).clamp(10.0, 18.0);

    // Set status bar color to dark green (0xFF0A3D2A)
    void setStatusBarColor() {
      if (Platform.isAndroid) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(
              statusBarColor: Color(0xFF0A3D2A), // Dark green, matching AppBar
              statusBarIconBrightness: Brightness.light, // White icons
            ),
          );
        });
      }
    }

    // Navigate to HomeScreen with controller cleanup and status bar color enforcement
    void navigateToHome() {
      Get.delete<AIChatController>(); // Clean up AIChatController
      Get.offNamed(AppRoutes.getHomePage()); // Navigate to HomeScreen
      setStatusBarColor(); // Ensure status bar is dark green
    }

    // Apply status bar color on initial build
    setStatusBarColor();

    return Obx(() => Theme(
          data: themeController.getTheme(),
          child: Scaffold(
            appBar: controller.isSelectionMode.value
                ? AppBar(
                    title: Text(
                      '${controller.selectedIndices.length} selected',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    centerTitle: false,
                    elevation: 4.0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.menu,
                        size: 20 * adjustedScaleFactor,
                        color: Colors.white,
                      ),
                      onPressed: controller.clearSelection,
                    ),
                    actions: [
                      TextButton(
                        onPressed: controller.copySelectedMessages,
                        child: Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: detailFontSize,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: controller.deleteSelectedMessages,
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: detailFontSize,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 6 * adjustedScaleFactor),
                    ],
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF0A3D2A), // Dark green
                            Color(0xFF145C3F), // Slightly lighter green
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  )
                : AppBar(
                    title: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: themeController.getTheme().colorScheme.primary.withOpacity(0.8),
                          radius: 16 * adjustedScaleFactor,
                          child: Icon(
                            Icons.android_rounded,
                            size: 18 * adjustedScaleFactor,
                            color: themeController.getTheme().colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(width: 10 * adjustedScaleFactor),
                        Expanded(
                          child: Text(
                            'ask_ai'.tr,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    centerTitle: false,
                    elevation: 4.0,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 20 * adjustedScaleFactor,
                        color: Colors.white,
                      ),
                      onPressed: navigateToHome, // Updated navigation
                    ),
                    actions: [
                      SizedBox(width: 6 * adjustedScaleFactor),
                    ],
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF0A3D2A), // Dark green
                            Color(0xFF145C3F), // Slightly lighter green
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
            body: Container(
              color: themeController.getTheme().scaffoldBackgroundColor,
              child: Column(
                children: [
                  Expanded(
                    child: MessageList(
                      adjustedScaleFactor: adjustedScaleFactor,
                      padding: padding,
                      fontFamilyFallbacks: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
                    ),
                  ),
                  Obx(() => controller.isLoading.value
                      ? Padding(
                          padding: EdgeInsets.all(padding * 0.3),
                          child: SizedBox(
                            width: 18 * adjustedScaleFactor,
                            height: 18 * adjustedScaleFactor,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF0A3D2A), // Updated to AppBar dark green
                              ),
                              strokeWidth: 1.2 * adjustedScaleFactor,
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                  Container(
                    decoration: BoxDecoration(
                      color: themeController.getTheme().cardTheme.color,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 3 * adjustedScaleFactor,
                          offset: Offset(0, -0.8 * adjustedScaleFactor),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: padding * 0.5, vertical: padding * 0.3),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.textController,
                            decoration: InputDecoration(
                              hintText: 'ask_your_question'.tr,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                                borderSide: BorderSide(
                                  color: Color(0xFF0A3D2A).withOpacity(0.6), // Updated to AppBar dark green
                                  width: 0.6 * adjustedScaleFactor,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12 * adjustedScaleFactor,
                                vertical: 10 * adjustedScaleFactor,
                              ),
                              prefixIcon: Icon(
                                Icons.message_rounded,
                                color: Color(0xFF0A3D2A).withOpacity(0.5), // Updated to AppBar dark green
                                size: 18 * adjustedScaleFactor,
                              ),
                              suffixIcon: controller.textController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: Color(0xFF0A3D2A).withOpacity(0.35), // Updated to AppBar dark green
                                        size: 18 * adjustedScaleFactor,
                                      ),
                                      onPressed: () => controller.textController.clear(),
                                    )
                                  : null,
                              filled: true,
                              fillColor: themeController.getTheme().inputDecorationTheme.fillColor?.withOpacity(0.7),
                              hintStyle: TextStyle(
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
                                fontSize: detailFontSize,
                                color: themeController.getTheme().textTheme.bodyMedium!.color!.withOpacity(0.25),
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontFamilyFallback: const ['NotoSansEthiopic', 'AbyssinicaSIL'],
                              fontSize: detailFontSize,
                              color: themeController.isDarkMode.value ? Colors.white.withOpacity(0.85) : Colors.black87.withOpacity(0.85),
                            ),
                            onSubmitted: (value) => controller.sendMessage(value),
                          ),
                        ),
                        SizedBox(width: 8 * adjustedScaleFactor),
                        SizedBox(
                          width: 44 * adjustedScaleFactor,
                          height: 44 * adjustedScaleFactor,
                          child: ElevatedButton(
                            onPressed: () {
                              controller.sendMessage(controller.textController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                              ),
                              padding: EdgeInsets.zero,
                              backgroundColor: Color(0xFF0A3D2A), // Updated to AppBar dark green
                            ),
                            child: Icon(
                              Icons.send_rounded,
                              color: themeController.getTheme().colorScheme.onSecondary,
                              size: 20 * adjustedScaleFactor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}