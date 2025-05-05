import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/chat/ai_chat_controller.dart';
import '../../../../controllers/theme_controller.dart';

class MessageList extends GetView<AIChatController> {
  final double adjustedScaleFactor;
  final double padding;
  final List<String> fontFamilyFallbacks;

  const MessageList({
    super.key,
    required this.adjustedScaleFactor,
    required this.padding,
    required this.fontFamilyFallbacks,
  });

  // Build the message text widget with rich text support and theming
  Widget _buildMessageText(
    String text,
    bool isRich,
    ThemeData theme,
    double textScaleFactor,
  ) {
    final textColor = theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.9) : Colors.black87;
    final bulletColor = theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.secondary;
    final baseTextStyle = TextStyle(
      fontFamily: GoogleFonts.poppins().fontFamily,
      fontFamilyFallback: fontFamilyFallbacks,
      fontSize: (14.0 * adjustedScaleFactor * 0.9).clamp(10.0, 18.0) * textScaleFactor,
      color: textColor,
      height: 1.15,
    );

    if (!isRich) {
      return Text(text, style: baseTextStyle);
    }

    final lines = text.split('\n');
    final children = <Widget>[];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('**') && line.endsWith('**')) {
        children.add(
          Padding(
            padding: EdgeInsets.only(bottom: 1.2 * adjustedScaleFactor),
            child: Text(
              line.replaceAll('**', '').trim(),
              style: baseTextStyle.copyWith(
                fontSize: (16.0 * adjustedScaleFactor * 0.9).clamp(12.0, 20.0) * textScaleFactor,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        );
      } else if (line.startsWith('• ')) {
        children.add(
          Padding(
            padding: EdgeInsets.only(bottom: 0.4 * adjustedScaleFactor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: baseTextStyle.copyWith(color: bulletColor),
                ),
                SizedBox(width: 4 * adjustedScaleFactor),
                Expanded(
                  child: Text(
                    line.replaceFirst('• ', '').trim(),
                    style: baseTextStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: EdgeInsets.only(bottom: 0.4 * adjustedScaleFactor),
            child: Text(line.trim(), style: baseTextStyle),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  // Build the timestamp widget for messages
  Widget _buildTimestamp(
    DateTime time,
    ThemeData theme,
    double textScaleFactor,
  ) {
    final formattedTime = DateFormat('MMM d, h:mm a').format(time);
    final timestampColor = theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.6) : Colors.black54;
    return Padding(
      padding: EdgeInsets.only(top: 2.5 * adjustedScaleFactor),
      child: Text(
        formattedTime,
        style: TextStyle(
          fontFamily: GoogleFonts.poppins().fontFamily,
          fontFamilyFallback: fontFamilyFallbacks,
          fontSize: (12.0 * adjustedScaleFactor * 0.9).clamp(8.0, 16.0) * textScaleFactor,
          color: timestampColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      // Ensure textScaleFactor triggers rebuild
      controller.textScaleFactor.value;
      return GestureDetector(
        // Real-time pinch-to-zoom outside selection mode
        onScaleUpdate: controller.isSelectionMode.value
            ? null
            : (details) {
                final newScale = (controller.textScaleFactor.value * details.scale).clamp(0.7, 1.8);
                controller.textScaleFactor.value = newScale;
              },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            ListView.builder(
              controller: controller.scrollController,
              padding: EdgeInsets.symmetric(horizontal: padding * 0.5, vertical: padding * 0.3),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                if (index >= controller.messages.length) return const SizedBox.shrink();
                final message = controller.messages[index];
                final isUser = message['sender'] == 'user';
                final isError = message['isError'] == true;
                final messageTime = message['timestamp'] as DateTime? ?? DateTime.now();
                final messageText = message['text'] as String;
                final isSelected = controller.selectedIndices.contains(index);

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (controller.isSelectionMode.value) {
                      controller.toggleMessageSelection(index);
                    }
                  },
                  onLongPress: () {
                    if (!controller.isSelectionMode.value) {
                      controller.toggleSelectionMode();
                      controller.toggleMessageSelection(index);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(vertical: 3.5 * adjustedScaleFactor),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? themeController.getTheme().colorScheme.primary.withOpacity(0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12 * adjustedScaleFactor),
                    ),
                    child: Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isUser && isSelected)
                            Padding(
                              padding: EdgeInsets.only(right: 8 * adjustedScaleFactor),
                              child: Container(
                                padding: EdgeInsets.all(4 * adjustedScaleFactor),
                                decoration: BoxDecoration(
                                  color: themeController.getTheme().colorScheme.primary.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 12 * adjustedScaleFactor,
                                  color: themeController.getTheme().colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: screenWidth * 0.65),
                            child: Material(
                              elevation: 6,
                              borderRadius: BorderRadius.circular(12 * adjustedScaleFactor).copyWith(
                                bottomRight: isUser ? Radius.zero : Radius.circular(12 * adjustedScaleFactor),
                                bottomLeft: isUser ? Radius.circular(12 * adjustedScaleFactor) : Radius.zero,
                              ),
                              color: isError
                                  ? themeController.getTheme().colorScheme.error.withOpacity(0.6)
                                  : isUser
                                      ? themeController.getTheme().colorScheme.secondary.withOpacity(0.6)
                                      : themeController.getTheme().cardTheme.color?.withOpacity(0.9),
                              child: Padding(
                                padding: EdgeInsets.all(padding * 0.5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildMessageText(
                                      messageText,
                                      message['isRich'],
                                      themeController.getTheme(),
                                      controller.textScaleFactor.value,
                                    ),
                                    _buildTimestamp(
                                      messageTime,
                                      themeController.getTheme(),
                                      controller.textScaleFactor.value,
                                    ),
                                    if (isError)
                                      Padding(
                                        padding: EdgeInsets.only(top: 5 * adjustedScaleFactor),
                                        child: TextButton.icon(
                                          onPressed: () => controller.retryMessage(message['query']),
                                          icon: Icon(
                                            Icons.refresh_rounded,
                                            size: 16 * adjustedScaleFactor,
                                            color: themeController.getTheme().colorScheme.onError,
                                          ),
                                          label: Text(
                                            'retry',
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.poppins().fontFamily,
                                              fontFamilyFallback: fontFamilyFallbacks,
                                              fontSize: (16.0 * adjustedScaleFactor * 0.9).clamp(12.0, 20.0) *
                                                  controller.textScaleFactor.value,
                                              color: themeController.getTheme().colorScheme.onError,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (isUser && isSelected)
                            Padding(
                              padding: EdgeInsets.only(left: 8 * adjustedScaleFactor),
                              child: Container(
                                padding: EdgeInsets.all(4 * adjustedScaleFactor),
                                decoration: BoxDecoration(
                                  color: themeController.getTheme().colorScheme.primary.withOpacity(0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 12 * adjustedScaleFactor,
                                  color: themeController.getTheme().colorScheme.onPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            if (controller.showScrollToBottom && !controller.isSelectionMode.value)
              Positioned(
                bottom: 10,
                child: FloatingActionButton(
                  heroTag: 'scroll_to_bottom_message_list',
                  mini: true,
                  backgroundColor: themeController.getTheme().colorScheme.secondary.withOpacity(0.7),
                  elevation: 0.6,
                  onPressed: () {
                    controller.scrollToBottom(animated: true);
                  },
                  child: Icon(
                    Icons.arrow_downward_rounded,
                    color: themeController.getTheme().colorScheme.onSecondary,
                    size: 20 * adjustedScaleFactor,
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}