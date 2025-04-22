import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/chat/ai_chat_controller.dart'; // Import your controller
import '../../../../controllers/theme_controller.dart'; // Import your theme controller

class AIChatScreen extends GetView<AIChatController> {
  const AIChatScreen({super.key});

  // Build the message text widget with rich text support and theming
  Widget _buildMessageText(
      String text,
      bool isRich,
      double scaleFactor,
      ThemeData theme,
      double textScaleFactor) {
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white.withOpacity(0.9)
        : Colors.black87;
    final bulletColor = theme.brightness == Brightness.dark
        ? Colors.white
        : theme.colorScheme.secondary;
    final baseTextStyle = TextStyle(
      fontSize: 10.0 * scaleFactor * textScaleFactor,
      fontFamily: 'SF Pro Text',
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
            padding: EdgeInsets.only(bottom: 1.2 * scaleFactor),
            child: Text(
              line.replaceAll('**', '').trim(),
              style: baseTextStyle.copyWith(
                fontSize: 11.5 * scaleFactor * textScaleFactor,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        );
      } else if (line.startsWith('• ')) {
        children.add(
          Padding(
            padding: EdgeInsets.only(bottom: 0.4 * scaleFactor),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: baseTextStyle.copyWith(color: bulletColor),
                ),
                SizedBox(width: 4 * scaleFactor),
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
            padding: EdgeInsets.only(bottom: 0.4 * scaleFactor),
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
      DateTime time, double scaleFactor, ThemeData theme, double textScaleFactor) {
    final formattedTime = DateFormat('MMM d, h:mm a').format(time);
    final timestampColor = theme.brightness == Brightness.dark
        ? Colors.white.withOpacity(0.6)
        : Colors.black54;
    return Padding(
      padding: EdgeInsets.only(top: 2.5 * scaleFactor),
      child: Text(
        formattedTime,
        style: TextStyle(
          fontSize: 8 * scaleFactor * textScaleFactor,
          color: timestampColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Inject the controller.  This is important for GetView.
    Get.put(AIChatController());
    final ThemeController themeController = Get.find<ThemeController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth > 600 ? 0.95 : 0.9;

    return Obx(() => Theme(
          data: themeController.getTheme(),
          child: GestureDetector(
            onScaleUpdate: (details) {
              controller.textScaleFactor.value =
                  (controller.textScaleFactor.value * details.scale)
                      .clamp(0.7, 1.8);
            },
            child: Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: themeController
                          .getTheme()
                          .colorScheme
                          .primary
                          .withOpacity(0.8),
                      radius: 16 * scaleFactor,
                      child: Icon(
                        Icons.android_rounded,
                        size: 18 * scaleFactor,
                        color: themeController.getTheme().colorScheme.onPrimary,
                      ),
                    ),
                    SizedBox(width: 10 * scaleFactor),
                    Expanded(
                      child: Obx(() => Text(
                            'ask_ai'.tr,
                            style: TextStyle(
                              fontSize: 9 *
                                  scaleFactor *
                                  controller.textScaleFactor.value,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'SF Pro Display',
                              color: themeController.isDarkMode.value
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )),
                    ),
                  ],
                ),
                centerTitle: false,
                elevation: 0.8,
                actions: [
                  IconButton(
                    icon: Icon(
                      themeController.isDarkMode.value
                          ? Icons.brightness_high_rounded
                          : Icons.brightness_2_rounded,
                      size: 16 * scaleFactor,
                    ),
                    onPressed: themeController.toggleTheme,
                    tooltip: 'toggle_theme'.tr,
                  ),
                  SizedBox(width: 6 * scaleFactor),
                ],
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeController
                            .getTheme()
                            .colorScheme
                            .primary
                            .withOpacity(0.6),
                        themeController
                            .getTheme()
                            .colorScheme
                            .secondary
                            .withOpacity(0.6),
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
                      child: Obx(() {
                        // Use a Stack to layer the ListView and the button.
                        return Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            ListView.builder(
                              controller: controller.scrollController,
                              padding: EdgeInsets.symmetric(
                                horizontal: 7 * scaleFactor,
                                vertical: 5 * scaleFactor,
                              ),
                              itemCount: controller.messages.length,
                              itemBuilder: (context, index) {
                                final message = controller.messages[index];
                                final isUser = message['sender'] == 'user';
                                final isError = message['isError'] == true;
                                final messageTime =
                                    message['timestamp'] as DateTime? ??
                                        DateTime.now();

                                return AnimatedPadding(
                                  duration: const Duration(milliseconds: 180),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3.5 * scaleFactor),
                                  child: Align(
                                    alignment: isUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: screenWidth * 0.65,
                                      ),
                                      child: Material(
                                        elevation: 0.4,
                                        borderRadius: BorderRadius.circular(
                                                12 * scaleFactor)
                                            .copyWith(
                                          bottomRight: isUser
                                              ? Radius.zero
                                              : Radius.circular(
                                                  12 * scaleFactor),
                                          bottomLeft: isUser
                                              ? Radius.circular(
                                                  12 * scaleFactor)
                                              : Radius.zero,
                                        ),
                                        color: isError
                                            ? themeController
                                                .getTheme()
                                                .colorScheme
                                                .error
                                                .withOpacity(0.6)
                                            : isUser
                                                ? themeController
                                                    .getTheme()
                                                    .colorScheme
                                                    .secondary
                                                    .withOpacity(0.6)
                                                : themeController
                                                    .getTheme()
                                                    .cardTheme
                                                    .color
                                                    ?.withOpacity(0.9),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              9 * scaleFactor),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _buildMessageText(
                                                message['text'],
                                                message['isRich'],
                                                scaleFactor,
                                                themeController.getTheme(),
                                                controller.textScaleFactor.value,
                                              ),
                                              _buildTimestamp(
                                                messageTime,
                                                scaleFactor,
                                                themeController.getTheme(),
                                                controller.textScaleFactor.value,
                                              ),
                                              if (isError)
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      top: 5 * scaleFactor),
                                                  child: TextButton.icon(
                                                    onPressed: () => controller
                                                        .retryMessage(
                                                            message['query']),
                                                    icon: Icon(
                                                      Icons.refresh_rounded,
                                                      size: 11 * scaleFactor,
                                                      color: themeController
                                                          .getTheme()
                                                          .colorScheme
                                                          .onError,
                                                    ),
                                                    label: Text(
                                                      'retry'.tr,
                                                      style: TextStyle(
                                                        fontSize: 9 *
                                                            scaleFactor *
                                                            controller
                                                                .textScaleFactor
                                                                .value,
                                                        color: themeController
                                                            .getTheme()
                                                            .colorScheme
                                                            .onError,
                                                      ),
                                                    ),
                                                    style: TextButton.styleFrom(
                                                      padding:
                                                          EdgeInsets.zero,
                                                      minimumSize: Size.zero,
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Show the button only when scrolled up
                            if (controller.showScrollToBottom)
                              Positioned(
                                bottom: 10,
                                child: FloatingActionButton(
                                  mini: true,
                                  backgroundColor: themeController
                                      .getTheme()
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.7),
                                  elevation: 0.6,
                                  onPressed: () {
                                    controller.scrollToBottom(animated: true); // Use the private method
                                  },
                                  child: Icon(
                                    Icons.arrow_downward_rounded,
                                    color: themeController
                                        .getTheme()
                                        .colorScheme
                                        .onSecondary,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                    Obx(() => controller.isLoading.value
                        ? Padding(
                            padding: EdgeInsets.all(5 * scaleFactor),
                            child: SizedBox(
                              width: 18 *
                                  scaleFactor *
                                  controller.textScaleFactor.value,
                              height: 18 *
                                  scaleFactor *
                                  controller.textScaleFactor.value,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  themeController
                                      .getTheme()
                                      .colorScheme
                                      .secondary,
                                ),
                                strokeWidth: 1.2 * scaleFactor,
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
                            blurRadius: 3 * scaleFactor,
                            offset: Offset(0, -0.8 * scaleFactor),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 7 * scaleFactor,
                        vertical: 5 * scaleFactor,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.textController,
                              decoration: InputDecoration(
                                hintText: 'ask_your_question'.tr,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      18 * scaleFactor),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      18 * scaleFactor),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      18 * scaleFactor),
                                  borderSide: BorderSide(
                                    color: themeController
                                        .getTheme()
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.6),
                                    width: 0.6 * scaleFactor,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12 * scaleFactor,
                                  vertical: 9 * scaleFactor,
                                ),
                                prefixIcon: Icon(
                                  Icons.message_rounded,
                                  color: themeController
                                      .getTheme()
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.5),
                                  size: 14 *
                                      scaleFactor *
                                      controller.textScaleFactor.value,
                                ),
                                suffixIcon:
                                    controller.textController.text.isNotEmpty
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.clear_rounded,
                                              color: themeController
                                                  .getTheme()
                                                  .colorScheme
                                                  .secondary
                                                  .withOpacity(0.35),
                                              size: 14 *
                                                  scaleFactor *
                                                  controller
                                                      .textScaleFactor.value,
                                            ),
                                            onPressed: () =>
                                                controller.textController.clear(),
                                          )
                                        : null,
                                filled: true,
                                fillColor: themeController
                                    .getTheme()
                                    .inputDecorationTheme
                                    .fillColor
                                    ?.withOpacity(0.7),
                                hintStyle: TextStyle(
                                  color: themeController
                                      .getTheme()
                                      .textTheme
                                      .bodyMedium!
                                      .color!
                                      .withOpacity(0.25),
                                  fontSize: 10 *
                                      scaleFactor *
                                      controller.textScaleFactor.value,
                                  fontFamily: 'SF Pro Text',
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 10 *
                                    scaleFactor *
                                    controller.textScaleFactor.value,
                                fontFamily: 'SF Pro Text',
                                color: themeController.isDarkMode.value
                                    ? Colors.white.withOpacity(0.85)
                                    : Colors.black87.withOpacity(0.85),
                              ),
                              onSubmitted: (value) =>
                                  controller.sendMessage(value),
                            ),
                          ),
                          SizedBox(width: 8 * scaleFactor),
                          SizedBox(
                            width: 44 * scaleFactor,
                            height: 44 * scaleFactor,
                            child: ElevatedButton(
                              onPressed: () {
                                controller
                                    .sendMessage(controller.textController.text);
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      22 * scaleFactor),
                                ),
                                padding: EdgeInsets.zero,
                                backgroundColor: themeController
                                    .getTheme()
                                    .colorScheme
                                    .secondary,
                              ),
                              child: Icon(
                                Icons.send_rounded,
                                color: themeController
                                    .getTheme()
                                    .colorScheme
                                    .onSecondary,
                                size: 20 * scaleFactor,
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
          ),
        ));
  }
}
