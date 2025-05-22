import 'dart:io' show Platform;
import 'package:agri/controllers/theme_controller.dart';
import 'package:agri/routes/app_routes.dart'; // Added for navigation
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? const Color(0xFF1A252F) : Colors.white;
    final scaleFactor = size.width > 900 ? 1.3 : size.width > 600 ? 1.1 : size.width < 360 ? 0.85 : 1.0;
    final adjustedScaleFactor = scaleFactor * 1.1;
    final padding = size.width > 900 ? 16.0 : size.width > 600 ? 12.0 : size.width < 360 ? 8.0 : 10.0;
    final cardMargin = size.width > 900 ? 6.0 : size.width > 600 ? 5.0 : size.width < 360 ? 3.0 : 4.0;
    final double maxWidth = size.width > 900 ? 900 : size.width > 600 ? 800 : size.width * (size.width < 360 ? 0.98 : 0.97);
    final titleFontSize = (20.0 * adjustedScaleFactor).clamp(16.0, 28.0);
    final questionFontSize = (14.0 * adjustedScaleFactor).clamp(12.0, 18.0);
    final answerFontSize = (12.0 * adjustedScaleFactor).clamp(10.0, 16.0);
    final appBarFontSize = (20.0 * adjustedScaleFactor).clamp(16.0, 28.0);

    final faqItems = [
      {'question': 'faq_question_1'.tr, 'answer': 'faq_answer_1'.tr},
      {'question': 'faq_question_2'.tr, 'answer': 'faq_answer_2'.tr},
      {'question': 'faq_question_3'.tr, 'answer': 'faq_answer_3'.tr},
      {'question': 'faq_question_4'.tr, 'answer': 'faq_answer_4'.tr},
      {'question': 'faq_question_5'.tr, 'answer': 'faq_answer_5'.tr},
    ];

    final expandedBackgroundColor = isDarkMode ? theme.colorScheme.secondary.withOpacity(0.1) : theme.colorScheme.secondary.withOpacity(0.05);
    final cardBorderRadius = theme.cardTheme.shape is RoundedRectangleBorder
        ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius as BorderRadius
        : BorderRadius.circular(12.0);

    // Set status bar color to dark green (0xFF0A3D2A)
    void setStatusBarColor() {
      if (Platform.isAndroid) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          SystemChrome.setSystemUIOverlayStyle(
            const SystemUiOverlayStyle(
              statusBarColor: Color(0xFF0A3D2A),
              statusBarIconBrightness: Brightness.light,
            ),
          );
        });
      }
    }

    // Navigate to HomeScreen with status bar color enforcement
    void navigateToHome() {
      Get.offNamed(AppRoutes.getHomePage()); // Navigate to HomeScreen
      setStatusBarColor(); // Ensure status bar is dark green
    }

    // Apply status bar color on initial build
    setStatusBarColor();

    // Update status bar on theme change
    ever(themeController.isDarkMode, (_) {
      setStatusBarColor();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'faq'.tr,
          style: TextStyle(
            fontSize: appBarFontSize,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 4.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20 * adjustedScaleFactor, color: Colors.white),
          onPressed: navigateToHome, // Updated navigation
        ),
        actions: [SizedBox(width: 6 * adjustedScaleFactor)],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A3D2A), Color(0xFF145C3F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26, // Simplified from Colors.black.withOpacity(0.3)
                blurRadius: 8 * adjustedScaleFactor,
                offset: Offset(0, 2 * adjustedScaleFactor),
              ),
            ],
          ),
        ),
        toolbarHeight: size.width < 360 ? 48 : 56,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, minHeight: size.height * 0.9),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                SizedBox(height: padding*1.2),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: faqItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Container(
                          key: ValueKey(index),
                          margin: EdgeInsets.symmetric(vertical: cardMargin, horizontal: 1.0),
                          child: Material(
                            elevation: theme.cardTheme.elevation ?? 2,
                            borderRadius: cardBorderRadius,
                            shadowColor: theme.cardTheme.shadowColor,
                            color: cardColor,
                            child: ClipRRect(
                              borderRadius: cardBorderRadius,
                              child: ExpansionTile(
                                title: Text(
                                  item['question']!,
                                  style: theme.textTheme.titleMedium?.copyWith(fontSize: questionFontSize),
                                ),
                                iconColor: theme.iconTheme.color,
                                collapsedIconColor: theme.iconTheme.color?.withOpacity(0.7),
                                backgroundColor: cardColor,
                                collapsedBackgroundColor: cardColor,
                                shape: theme.cardTheme.shape as RoundedRectangleBorder? ??
                                    const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
                                onExpansionChanged: (expanded) => setState(() => _expandedIndex = expanded ? index : null),
                                initiallyExpanded: _expandedIndex == index,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: expandedBackgroundColor,
                                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12.0)),
                                    ),
                                    padding: EdgeInsets.all(padding),
                                    child: Text(
                                      item['answer']!,
                                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: answerFontSize, height: 1.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}