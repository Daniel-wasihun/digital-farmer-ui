import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../controllers/chat/ai_chat_controller.dart';
import '../../../../controllers/theme_controller.dart';
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

    // Font fallbacks for Amharic
    const List<String> fontFamilyFallbacks = ['NotoSansEthiopic', 'AbyssinicaSIL'];

    return Obx(() => Theme(
          data: themeController.getTheme(),
          child: Scaffold(
            appBar: controller.isSelectionMode.value
                ? AppBar(
                    title: Text(
                      '${controller.selectedIndices.length} selected',
                      style: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontFamilyFallback: fontFamilyFallbacks,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: themeController.isDarkMode.value ? Colors.white : Colors.black87,
                      ),
                    ),
                    centerTitle: false,
                    elevation: 0.8,
                    leading: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 20 * adjustedScaleFactor,
                        color: themeController.isDarkMode.value ? Colors.white : Colors.black87,
                      ),
                      onPressed: controller.clearSelection,
                    ),
                    actions: [
                      TextButton(
                        onPressed: controller.copySelectedMessages,
                        child: Text(
                          'Copy',
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontFamilyFallback: fontFamilyFallbacks,
                            fontSize: detailFontSize,
                            color: themeController.isDarkMode.value ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: controller.deleteSelectedMessages,
                        child: Text(
                          'Delete',
                          style: TextStyle(
                            fontFamily: GoogleFonts.poppins().fontFamily,
                            fontFamilyFallback: fontFamilyFallbacks,
                            fontSize: detailFontSize,
                            color: themeController.isDarkMode.value ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      SizedBox(width: 6 * adjustedScaleFactor),
                    ],
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeController.getTheme().colorScheme.primary.withOpacity(0.6),
                            themeController.getTheme().colorScheme.secondary.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
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
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontFamilyFallback: fontFamilyFallbacks,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                              color: themeController.isDarkMode.value ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    centerTitle: false,
                    elevation: 0.8,
                    actions: [
                      IconButton(
                        icon: Icon(
                          themeController.isDarkMode.value ? Icons.brightness_high_rounded : Icons.brightness_2_rounded,
                          size: 16 * adjustedScaleFactor,
                        ),
                        onPressed: themeController.toggleTheme,
                        tooltip: 'toggle_theme',
                      ),
                      SizedBox(width: 6 * adjustedScaleFactor),
                    ],
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            themeController.getTheme().colorScheme.primary.withOpacity(0.6),
                            themeController.getTheme().colorScheme.secondary.withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
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
                      fontFamilyFallbacks: fontFamilyFallbacks,
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
                                themeController.getTheme().colorScheme.secondary,
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
                              hintText: 'ask_your_question',
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
                                  color: themeController.getTheme().colorScheme.secondary.withOpacity(0.6),
                                  width: 0.6 * adjustedScaleFactor,
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12 * adjustedScaleFactor,
                                vertical: 10 * adjustedScaleFactor,
                              ),
                              prefixIcon: Icon(
                                Icons.message_rounded,
                                color: themeController.getTheme().colorScheme.secondary.withOpacity(0.5),
                                size: 18 * adjustedScaleFactor,
                              ),
                              suffixIcon: controller.textController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: themeController.getTheme().colorScheme.secondary.withOpacity(0.35),
                                        size: 18 * adjustedScaleFactor,
                                      ),
                                      onPressed: () => controller.textController.clear(),
                                    )
                                  : null,
                              filled: true,
                              fillColor: themeController.getTheme().inputDecorationTheme.fillColor?.withOpacity(0.7),
                              hintStyle: TextStyle(
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontFamilyFallback: fontFamilyFallbacks,
                                fontSize: detailFontSize,
                                color: themeController.getTheme().textTheme.bodyMedium!.color!.withOpacity(0.25),
                              ),
                            ),
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontFamilyFallback: fontFamilyFallbacks,
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
                              backgroundColor: themeController.getTheme().colorScheme.secondary,
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