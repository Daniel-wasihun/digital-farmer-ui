import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../controllers/chat/chat_screen_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/constants.dart';

class ChatScreen extends StatelessWidget {
  final String receiverId;
  final String receiverUsername;

  const ChatScreen({super.key, required this.receiverId, required this.receiverUsername});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatScreenController(
      receiverId: receiverId,
      receiverUsername: receiverUsername,
    ));
    final screenSize = MediaQuery.of(context).size;
    final scaleFactor = (screenSize.width / 400 * screenSize.height / 800).clamp(0.7, 1.2);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [const Color(0xFF121212), const Color(0xFF1E1E1E)]
                    : [const Color(0xFFF5F7FA), const Color(0xFFE8ECEF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                _buildAppBar(context, scaleFactor, controller),
                Expanded(
                  child: Obx(
                    () {
                      if (controller.chatController.isLoadingMessages.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppConstants.primaryColor,
                          ),
                        );
                      }
                      if (controller.messageItems.isEmpty) {
                        return Center(
                          child: Text(
                            'no_messages'.tr,
                            style: GoogleFonts.poppins(
                              fontSize: 14 * scaleFactor,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        );
                      }
                      return ListView.builder(
                        key: const ValueKey('chat_list'),
                        controller: controller.scrollController,
                        padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor, horizontal: 8 * scaleFactor),
                        itemCount: controller.messageItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.messageItems[index];
                          final itemKey = item['key'] as String;
                          if (item['type'] == 'header') {
                            return _buildDateHeader(
                              item['value'] as String,
                              scaleFactor,
                              context,
                              key: ValueKey('header_$itemKey'),
                            );
                          }
                          final msg = item['message'] as Map<String, dynamic>;
                          final isSent = msg['senderId'].toString() == controller.chatController.currentUserId.toString();
                          print('Message $itemKey: isSent=$isSent, senderId=${msg['senderId']}, currentUserId=${controller.chatController.currentUserId}');
                          final isNew = item['isNew'] as bool? ?? false;
                          return isNew
                              ? FadeInUp(
                                  key: ValueKey('message_$itemKey'),
                                  duration: const Duration(milliseconds: 400),
                                  child: _MessageBubble(
                                    key: ValueKey('message_$itemKey'),
                                    message: msg,
                                    isSent: isSent,
                                    scaleFactor: scaleFactor,
                                    screenWidth: screenSize.width,
                                    controller: controller,
                                  ),
                                )
                              : _MessageBubble(
                                  key: ValueKey('message_$itemKey'),
                                  message: msg,
                                  isSent: isSent,
                                  scaleFactor: scaleFactor,
                                  screenWidth: screenSize.width,
                                  controller: controller,
                                );
                        },
                      );
                    },
                  ),
                ),
                _buildInputArea(context, scaleFactor, controller),
              ],
            ),
          ),
          Positioned(
            bottom: 90 * scaleFactor,
            left: 16 * scaleFactor,
            child: Obx(
              () => AnimatedOpacity(
                opacity: controller.showScrollArrow.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Visibility(
                  visible: controller.showScrollArrow.value,
                  child: GestureDetector(
                    onTap: () => controller.scrollToBottom(),
                    child: Container(
                      padding: EdgeInsets.all(12 * scaleFactor),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6 * scaleFactor,
                            offset: Offset(0, 3 * scaleFactor),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 20 * scaleFactor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 75 * scaleFactor,
            right: 16 * scaleFactor,
            child: Obx(
              () => AnimatedOpacity(
                opacity: controller.unseenCount.value > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Visibility(
                  visible: controller.unseenCount.value > 0,
                  child: GestureDetector(
                    onTap: () => controller.scrollToBottom(),
                    child: Container(
                      padding: EdgeInsets.all(8 * scaleFactor),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6 * scaleFactor,
                            offset: Offset(0, 3 * scaleFactor),
                          ),
                        ],
                      ),
                      child: Text(
                        controller.unseenCount.value.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14 * scaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date, double scaleFactor, BuildContext context, {Key? key}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      key: key,
      padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor, horizontal: 16 * scaleFactor),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 4 * scaleFactor),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800]!.withOpacity(0.9) : Colors.grey[200]!.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16 * scaleFactor),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3 * scaleFactor,
                offset: Offset(0, 1 * scaleFactor),
              ),
            ],
          ),
          child: Text(
            date,
            style: GoogleFonts.poppins(
              fontSize: 12 * scaleFactor,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double scaleFactor, ChatScreenController controller) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppConstants.primaryColor, Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 4,
      shadowColor: Colors.black26,
      titleSpacing: 0,
      title: Obx(() {
        final user = controller.chatController.allUsers
            .firstWhereOrNull((u) => u['email'] == receiverId);
        final isTyping = controller.chatController.typingUsers.contains(receiverId);
        final isOnline = user != null && user['online'] == true;
        return GestureDetector(
          onTap: () => Get.toNamed(
            AppRoutes.getUserProfilePage(receiverId, receiverUsername),
            arguments: {
              'email': receiverId,
              'username': receiverUsername,
              'profilePicture': user?['profilePicture'],
              'bio': user?['bio'],
            },
          ),
          child: Row(
            children: [
              SizedBox(width: 0 * scaleFactor),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 18 * scaleFactor,
                    backgroundColor: Colors.white,
                    child: user != null && user['profilePicture']?.isNotEmpty == true
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: 'http://localhost:5000${user['profilePicture']}',
                              fit: BoxFit.cover,
                              width: 36 * scaleFactor,
                              height: 36 * scaleFactor,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) {
                                print('AppBar profile picture error: $error, URL: $url');
                                return Text(
                                  receiverUsername.isNotEmpty
                                      ? receiverUsername[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: AppConstants.primaryColor,
                                    fontSize: 18 * scaleFactor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            receiverUsername.isNotEmpty
                                ? receiverUsername[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontSize: 18 * scaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 10 * scaleFactor,
                        height: 10 * scaleFactor,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5 * scaleFactor),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 8 * scaleFactor),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiverUsername,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16 * scaleFactor,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          isTyping ? 'typing'.tr : isOnline ? 'online'.tr : 'offline'.tr,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12 * scaleFactor,
                          ),
                        ),
                        if (isTyping) ...[
                          SizedBox(width: 4 * scaleFactor),
                          _TypingDots(scaleFactor: scaleFactor, controller: controller),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 24 * scaleFactor),
        onPressed: () => Get.offNamed(AppRoutes.getHomePage()),
        tooltip: 'back'.tr,
      ),
      actions: [
        Obx(() => controller.chatController.errorMessage.value.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.error, color: Colors.redAccent, size: 24 * scaleFactor),
                onPressed: () => Get.snackbar('Error', controller.chatController.errorMessage.value,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent.withOpacity(0.8),
                    colorText: Colors.white,
                    margin: EdgeInsets.all(8 * scaleFactor),
                    icon: Icon(Icons.error_outline, color: Colors.white, size: 24 * scaleFactor),
                    shouldIconPulse: true,
                  ),
                tooltip: 'show_error'.tr,
              )
            : const SizedBox.shrink()),
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.white, size: 24 * scaleFactor),
          onPressed: () {
            // TODO: Implement chat options/info
          },
          tooltip: 'more_options'.tr,
        ),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context, double scaleFactor, ChatScreenController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 8 * scaleFactor),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2E2E2E) : Colors.white,
          borderRadius: BorderRadius.circular(24 * scaleFactor),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1 * scaleFactor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 8 * scaleFactor,
              offset: Offset(0, 4 * scaleFactor),
            ),
          ],
        ),
        height: 50 * scaleFactor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.sentiment_satisfied_alt_rounded,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 22 * scaleFactor,
              ),
              onPressed: () {
                // TODO: Implement emoji picker
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(maxWidth: 40 * scaleFactor),
              alignment: Alignment.center,
            ),
            SizedBox(width: 4 * scaleFactor),
            Expanded(
              child: TextField(
                controller: controller.messageController,
                style: GoogleFonts.poppins(
                  fontSize: 14 * scaleFactor,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'type_message'.tr,
                  hintStyle: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                    fontSize: 14 * scaleFactor,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 10 * scaleFactor,
                    horizontal: 8 * scaleFactor,
                  ),
                ),
                minLines: 1,
                maxLines: 3,
                onChanged: (text) {
                  if (text.trim().isNotEmpty) {
                    controller.chatController.onTyping(receiverId);
                  } else {
                    controller.chatController.onStopTyping(receiverId);
                  }
                },
                onSubmitted: controller.sendMessage,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.attach_file,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 22 * scaleFactor,
              ),
              onPressed: () {
                // TODO: Implement file attachment
              },
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(maxWidth: 40 * scaleFactor),
              alignment: Alignment.center,
            ),
            SizedBox(width: 4 * scaleFactor),
            FloatingActionButton(
              mini: true,
              backgroundColor: AppConstants.primaryColor,
              elevation: 0,
              onPressed: () => controller.sendMessage(controller.messageController.text),
              tooltip: 'send_message'.tr,
              child: Icon(
                Icons.send,
                color: Colors.white,
                size: 20 * scaleFactor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isSent;
  final double scaleFactor;
  final double screenWidth;
  final ChatScreenController controller;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.isSent,
    required this.scaleFactor,
    required this.screenWidth,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final maxBubbleWidth = screenWidth * 0.75;
    final fontSize = 14 * scaleFactor;
    final padding = 8 * scaleFactor;
    final messageText = message['message'] ?? 'Error';
    final edgePadding = 16 * scaleFactor;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * scaleFactor, horizontal: 8 * scaleFactor),
      child: Column(
        crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                child: CustomPaint(
                  painter: ChatBubblePainter(
                    isSent: isSent,
                    gradient: isSent
                        ? const LinearGradient(
                            colors: [AppConstants.primaryColor, Color(0xFF2E7D32)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSent
                        ? null
                        : isDarkMode
                            ? const Color(0xFF2E2E2E)
                            : Colors.white,
                    scaleFactor: scaleFactor,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scaleFactor,
                      vertical: padding,
                    ),
                    child: Text(
                      messageText,
                      style: GoogleFonts.poppins(
                        color: isSent
                            ? Colors.white
                            : isDarkMode
                                ? Colors.white
                                : Colors.black,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w400,
                      ),
                      softWrap: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: isSent ? 0 : edgePadding,
              right: isSent ? edgePadding : 0,
              top: 2 * scaleFactor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.formatTime(message['timestamp']),
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 10 * scaleFactor,
                  ),
                ),
                if (isSent) ...[
                  SizedBox(width: 4 * scaleFactor),
                  Row(
                    children: [
                      Text(
                        message['read'] == true
                            ? 'read'.tr
                            : message['delivered'] == true
                                ? 'delivered'.tr
                                : 'sent'.tr,
                        style: GoogleFonts.poppins(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 10 * scaleFactor,
                        ),
                      ),
                      SizedBox(width: 2 * scaleFactor),
                      message['read'] == true
                          ? Stack(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  size: 10 * scaleFactor,
                                ),
                                Positioned(
                                  left: 4 * scaleFactor,
                                  top: 2 * scaleFactor,
                                  child: Icon(
                                    Icons.check,
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                    size: 10 * scaleFactor,
                                  ),
                                ),
                              ],
                            )
                          : Icon(
                              Icons.check,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                              size: 10 * scaleFactor,
                            ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubblePainter extends CustomPainter {
  final bool isSent;
  final LinearGradient? gradient;
  final Color? color;
  final double scaleFactor;

  ChatBubblePainter({
    required this.isSent,
    this.gradient,
    this.color,
    required this.scaleFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (gradient != null) {
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      paint.shader = gradient!.createShader(rect);
    } else {
      paint.color = color ?? Colors.grey;
    }

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3 * scaleFactor);

    final path = Path();
    final shadowPath = Path();
    final cornerRadius = 10.0 * scaleFactor;
    final tailSize = 10.0 * scaleFactor;
    final tailCurveControl1 = 4.0 * scaleFactor;
    final tailCurveControl2 = 2.0 * scaleFactor;
    final tailHeightOffset = 0.5 * scaleFactor;

    if (isSent) {
      path.moveTo(cornerRadius, 0);
      shadowPath.moveTo(cornerRadius, 0);
      path.lineTo(size.width - cornerRadius - tailSize, 0);
      shadowPath.lineTo(size.width - cornerRadius - tailSize, 0);
      path.quadraticBezierTo(
          size.width - tailSize, 0, size.width - tailSize, cornerRadius);
      shadowPath.quadraticBezierTo(
          size.width - tailSize, 0, size.width - tailSize, cornerRadius);
      path.lineTo(size.width - tailSize, size.height - cornerRadius - tailSize * 0.5);
      shadowPath.lineTo(size.width - tailSize, size.height - cornerRadius - tailSize * 0.5);
      path.quadraticBezierTo(
          size.width - tailSize + tailCurveControl1,
          size.height - cornerRadius - tailHeightOffset,
          size.width - tailCurveControl2,
          size.height - cornerRadius + tailSize * 0.2);
      shadowPath.quadraticBezierTo(
          size.width - tailSize + tailCurveControl1,
          size.height - cornerRadius - tailHeightOffset,
          size.width - tailCurveControl2,
          size.height - cornerRadius + tailSize * 0.2);
      path.quadraticBezierTo(
          size.width - tailSize + tailCurveControl2,
          size.height - tailHeightOffset,
          size.width - tailSize - cornerRadius,
          size.height);
      shadowPath.quadraticBezierTo(
          size.width - tailSize + tailCurveControl2,
          size.height - tailHeightOffset,
          size.width - tailSize - cornerRadius,
          size.height);
      path.lineTo(cornerRadius, size.height);
      shadowPath.lineTo(cornerRadius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
      shadowPath.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
      path.lineTo(0, cornerRadius);
      shadowPath.lineTo(0, cornerRadius);
      path.quadraticBezierTo(0, 0, cornerRadius, 0);
      shadowPath.quadraticBezierTo(0, 0, cornerRadius, 0);
    } else {
      path.moveTo(size.width - cornerRadius, 0);
      shadowPath.moveTo(size.width - cornerRadius, 0);
      path.lineTo(cornerRadius + tailSize, 0);
      shadowPath.lineTo(cornerRadius + tailSize, 0);
      path.quadraticBezierTo(tailSize, 0, tailSize, cornerRadius);
      shadowPath.quadraticBezierTo(tailSize, 0, tailSize, cornerRadius);
      path.lineTo(tailSize, size.height - cornerRadius - tailSize * 0.5);
      shadowPath.lineTo(tailSize, size.height - cornerRadius - tailSize * 0.5);
      path.quadraticBezierTo(
          tailSize - tailCurveControl1,
          size.height - cornerRadius - tailHeightOffset,
          tailCurveControl2,
          size.height - cornerRadius + tailSize * 0.2);
      shadowPath.quadraticBezierTo(
          tailSize - tailCurveControl1,
          size.height - cornerRadius - tailHeightOffset,
          tailCurveControl2,
          size.height - cornerRadius + tailSize * 0.2);
      path.quadraticBezierTo(
          tailSize - tailCurveControl2,
          size.height - tailHeightOffset,
          cornerRadius,
          size.height);
      shadowPath.quadraticBezierTo(
          tailSize - tailCurveControl2,
          size.height - tailHeightOffset,
          cornerRadius,
          size.height);
      path.lineTo(size.width - cornerRadius, size.height);
      shadowPath.lineTo(size.width - cornerRadius, size.height);
      path.quadraticBezierTo(
          size.width, size.height, size.width, size.height - cornerRadius);
      shadowPath.quadraticBezierTo(
          size.width, size.height, size.width, size.height - cornerRadius);
      path.lineTo(size.width, cornerRadius);
      shadowPath.lineTo(size.width, cornerRadius);
      path.quadraticBezierTo(size.width, 0, size.width - cornerRadius, 0);
      shadowPath.quadraticBezierTo(size.width, 0, size.width - cornerRadius, 0);
    }

    path.close();
    shadowPath.close();

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _TypingDots extends StatelessWidget {
  final double scaleFactor;
  final ChatScreenController controller;

  const _TypingDots({required this.scaleFactor, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.animationController,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Bounce(
            duration: const Duration(milliseconds: 1000),
            child: _buildDot(controller.dot1.value, scaleFactor),
          ),
          SizedBox(width: 3 * scaleFactor),
          Bounce(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 200),
            child: _buildDot(controller.dot2.value, scaleFactor),
          ),
          SizedBox(width: 3 * scaleFactor),
          Bounce(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 400),
            child: _buildDot(controller.dot3.value, scaleFactor),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(double opacity, double scaleFactor) => Opacity(
        opacity: opacity,
        child: Container(
          width: 6 * scaleFactor,
          height: 6 * scaleFactor,
          decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
        ),
      );
}