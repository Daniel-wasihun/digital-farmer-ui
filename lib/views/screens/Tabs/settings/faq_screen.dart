import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // Track the index of the currently expanded accordion item
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLargeTablet = size.width > 900;
    final isSmallPhone = size.width < 360;

    // Dynamic scaling factors for better responsiveness
    final double scaleFactor = isLargeTablet
        ? 1.3
        : isTablet
            ? 1.1
            : isSmallPhone
                ? 0.85
                : 1.0;

    // Base font sizes (unchanged from previous update)
    final double baseTitleFontSize = 17.0;
    final double baseQuestionFontSize = 14.0;
    final double baseAnswerFontSize = 12.0;
    final double baseAppBarFontSize = 16.0;

    // Calculate responsive font sizes
    final double titleFontSize = baseTitleFontSize * scaleFactor;
    final double questionFontSize = baseQuestionFontSize * scaleFactor;
    final double answerFontSize = baseAnswerFontSize * scaleFactor;
    final double appBarFontSize = baseAppBarFontSize * scaleFactor;

    // Responsive padding and margins
    final double padding = isLargeTablet
        ? 16.0 // Reduced from 20.0
        : isTablet
            ? 12.0 // Reduced from 16.0
            : isSmallPhone
                ? 8.0 // Reduced from 12.0
                : 10.0; // Reduced from 14.0

    final double cardMargin = isLargeTablet
        ? 6.0
        : isTablet
            ? 5.0
            : isSmallPhone
                ? 3.0
                : 4.0;

    // Responsive max width for the content, further increased for wider cards
    final double maxWidth = isLargeTablet
        ? 900 // Increased from 800
        : isTablet
            ? 800 // Increased from 700
        : size.width * (isSmallPhone ? 0.98 : 0.97); // Increased from 0.95/0.94

    // List of FAQ items with translated questions and answers
    final List<Map<String, String>> faqItems = [
      {
        'question': 'faq_question_1'.tr,
        'answer': 'faq_answer_1'.tr,
      },
      {
        'question': 'faq_question_2'.tr,
        'answer': 'faq_answer_2'.tr,
      },
      {
        'question': 'faq_question_3'.tr,
        'answer': 'faq_answer_3'.tr,
      },
      {
        'question': 'faq_question_4'.tr,
        'answer': 'faq_answer_4'.tr,
      },
      {
        'question': 'faq_question_5'.tr,
        'answer': 'faq_answer_5'.tr,
      },
    ];

    // Use theme colors
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    final Color expandedBackgroundColor = isDarkMode
        ? theme.colorScheme.secondary.withOpacity(0.1)
        : theme.colorScheme.secondary.withOpacity(0.05);

    // Safely extract borderRadius from theme.cardTheme.shape
    final BorderRadius cardBorderRadius = theme.cardTheme.shape is RoundedRectangleBorder
        ? (theme.cardTheme.shape as RoundedRectangleBorder).borderRadius as BorderRadius
        : BorderRadius.circular(12.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'faq'.tr,
          style: TextStyle(
            fontSize: appBarFontSize,
            fontWeight: FontWeight.w600,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        toolbarHeight: isSmallPhone ? 48 : 56,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            minHeight: size.height * 0.9,
          ),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'faq'.tr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: titleFontSize,
                    shadows: [
                      Shadow(
                        color: isDarkMode ? Colors.black54 : Colors.black12,
                        offset: const Offset(1, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: padding),
                // FAQ List with Accordion
                Flexible(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: List.generate(faqItems.length, (index) {
                        return Container(
                          key: ValueKey(index),
                          margin: EdgeInsets.symmetric(vertical: cardMargin, horizontal: 1.0), // Reduced from 2.0
                          child: Material(
                            elevation: theme.cardTheme.elevation ?? 2,
                            borderRadius: cardBorderRadius,
                            shadowColor: theme.cardTheme.shadowColor,
                            color: theme.cardTheme.color,
                            child: ClipRRect(
                              borderRadius: cardBorderRadius,
                              child: ExpansionTile(
                                title: Text(
                                  faqItems[index]['question']!,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: questionFontSize,
                                  ),
                                ),
                                iconColor: theme.iconTheme.color,
                                collapsedIconColor: theme.iconTheme.color?.withOpacity(0.7),
                                backgroundColor: theme.cardTheme.color,
                                collapsedBackgroundColor: theme.cardTheme.color,
                                shape: theme.cardTheme.shape as RoundedRectangleBorder? ?? const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                ),
                                onExpansionChanged: (bool expanded) {
                                  setState(() {
                                    _expandedIndex = expanded ? index : null;
                                  });
                                },
                                initiallyExpanded: _expandedIndex == index,
                                maintainState: false,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: expandedBackgroundColor,
                                      borderRadius: const BorderRadius.vertical(
                                        bottom: Radius.circular(12.0),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(padding),
                                    child: Text(
                                      faqItems[index]['answer']!,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: answerFontSize,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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