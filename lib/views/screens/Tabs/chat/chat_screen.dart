import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../controllers/chat/chat_screen_controller.dart';
import '../../../../routes/app_routes.dart';
import 'user_profile_screen.dart';
import '../../../../utils/constants.dart';
import '../../../../services/api/base_api.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaleFactor = (screenSize.width / 400 * screenSize.height / 800).clamp(0.7, 1.05);
    final fontFamilyFallbacks = ['NotoSansEthiopic', 'AbyssinicaSIL', 'Noto Sans', 'Roboto', 'Arial'];

    return Obx(() => Theme(
          data: Theme.of(context),
          child: Scaffold(
            backgroundColor: Theme.of(context).cardTheme.color ?? (isDarkMode ? Colors.grey[850] : Colors.white),
            body: Stack(
              children: [
                Column(
                  children: [
                    controller.isSelectionMode.value
                        ? _buildSelectionAppBar(context, scaleFactor, controller, fontFamilyFallbacks)
                        : _buildAppBar(context, scaleFactor, controller, fontFamilyFallbacks),
                    Expanded(
                      child: Obx(() {
                        controller.textScaleFactor.value;
                        if (controller.chatController.isLoadingMessages.value) {
                          return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
                        }
                        if (controller.messageItems.isEmpty) {
                          return Center(
                            child: Text(
                              'no_messages'.tr,
                              style: TextStyle(
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontFamilyFallback: fontFamilyFallbacks,
                                fontSize: 15 * scaleFactor * controller.textScaleFactor.value,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          );
                        }
                        return GestureDetector(
                          onScaleUpdate: controller.isSelectionMode.value
                              ? null
                              : (details) {
                                  final newScale = (controller.textScaleFactor.value * details.scale).clamp(0.7, 1.8);
                                  controller.textScaleFactor.value = newScale;
                                },
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            alignment: Alignment.bottomLeft,
                            children: [
                              ListView.builder(
                                key: const ValueKey('chat_list'),
                                controller: controller.scrollController,
                                padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor, horizontal: 8 * scaleFactor)
                                    .copyWith(bottom: 20 * scaleFactor),
                                itemCount: controller.messageItems.length,
                                itemBuilder: (context, index) {
                                  final item = controller.messageItems[index];
                                  final itemKey = item['key'] as String;
                                  if (item['type'] == 'header') {
                                    return _buildDateHeader(
                                        item['value'] as String,
                                        scaleFactor,
                                        context,
                                        controller.textScaleFactor.value,
                                        fontFamilyFallbacks,
                                        key: ValueKey('header_$itemKey'));
                                  }
                                  final msg = item['message'] as Map<String, dynamic>;
                                  final isSent = msg['senderId'].toString() == controller.chatController.currentUserId.toString();
                                  final isNew = item['isNew'] as bool? ?? false;
                                  final isSelected = controller.selectedIndices.contains(index);
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => controller.isSelectionMode.value ? controller.toggleMessageSelection(index) : null,
                                    onLongPress: () {
                                      if (!controller.isSelectionMode.value) {
                                        controller.toggleSelectionMode();
                                        controller.toggleMessageSelection(index);
                                      }
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 100),
                                      curve: Curves.easeInOut,
                                      padding: EdgeInsets.symmetric(vertical: 3.5 * scaleFactor),
                                      decoration: BoxDecoration(
                                        color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.25) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12 * scaleFactor),
                                      ),
                                      child: isNew
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
                                                isSelected: isSelected,
                                                textScaleFactor: controller.textScaleFactor.value,
                                                fontFamilyFallbacks: fontFamilyFallbacks,
                                              ),
                                            )
                                          : _MessageBubble(
                                              key: ValueKey('message_$itemKey'),
                                              message: msg,
                                              isSent: isSent,
                                              scaleFactor: scaleFactor,
                                              screenWidth: screenSize.width,
                                              controller: controller,
                                              isSelected: isSelected,
                                              textScaleFactor: controller.textScaleFactor.value,
                                              fontFamilyFallbacks: fontFamilyFallbacks,
                                            ),
                                    ),
                                  );
                                },
                              ),
                              if (controller.showScrollArrow.value && !controller.isSelectionMode.value)
                                Positioned(
                                  bottom: 10 * scaleFactor,
                                  left: 16 * scaleFactor,
                                  child: FloatingActionButton(
                                    heroTag: 'scroll_to_bottom_chat',
                                    mini: true,
                                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.85),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scaleFactor)),
                                    onPressed: controller.scrollToBottom,
                                    child: Icon(Icons.arrow_drop_down_rounded,
                                        color: Theme.of(context).colorScheme.onPrimary, size: 24 * scaleFactor),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                    _buildInputArea(context, scaleFactor, controller, fontFamilyFallbacks),
                  ],
                ),
                Positioned(
                  bottom: 80 * scaleFactor,
                  right: 16 * scaleFactor,
                  child: Obx(() => AnimatedOpacity(
                        opacity: controller.unseenCount.value > 0 && !controller.isSelectionMode.value ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Visibility(
                          visible: controller.unseenCount.value > 0 && !controller.isSelectionMode.value,
                          child: GestureDetector(
                            onTap: controller.scrollToBottom,
                            child: Container(
                              padding: EdgeInsets.all(10 * scaleFactor),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8 * scaleFactor,
                                    offset: Offset(0, 4 * scaleFactor),
                                  ),
                                ],
                              ),
                              child: Text(
                                controller.unseenCount.value.toString(),
                                style: TextStyle(
                                  fontFamily: GoogleFonts.poppins().fontFamily,
                                  fontFamilyFallback: fontFamilyFallbacks,
                                  color: Theme.of(context).colorScheme.onSecondary,
                                  fontSize: 16 * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildSelectionAppBar(
      BuildContext context, double scaleFactor, ChatScreenController controller, List<String> fontFamilyFallbacks) {
    return PreferredSize(
      preferredSize: Size.fromHeight(80 * scaleFactor),
      child: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
        shadowColor: Colors.black26,
        title: Obx(() => Text(
              '${controller.selectedIndices.length} ${controller.selectedIndices.length == 1 ? 'message_selected'.tr : 'messages_selected'.tr}',
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontFamilyFallback: fontFamilyFallbacks,
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 20 * scaleFactor,
                fontWeight: FontWeight.w600,
              ),
            )),
        leading: IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onPrimary, size: 28 * scaleFactor),
          onPressed: controller.clearSelection,
          tooltip: 'cancel'.tr,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.copy, color: Theme.of(context).colorScheme.onPrimary, size: 28 * scaleFactor),
            onPressed: controller.copySelectedMessages,
            tooltip: 'copy'.tr,
          ),
          IconButton(
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.onPrimary, size: 28 * scaleFactor),
            onPressed: controller.deleteSelectedMessages,
            tooltip: 'delete'.tr,
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.6),
                Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, double scaleFactor, ChatScreenController controller, List<String> fontFamilyFallbacks) {
    return PreferredSize(
      preferredSize: Size.fromHeight(80 * scaleFactor),
      child: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 2,
        shadowColor: Colors.black26,
        titleSpacing: 0,
        title: Obx(() {
          final user = controller.chatController.allUsers.firstWhereOrNull((u) => u['email'] == receiverId);
          final isTyping = controller.chatController.typingUsers.contains(receiverId);
          final isOnline = user != null && user['online'] == true;
          return GestureDetector(
            onTap: () => UserProfileScreen.show(context, {
              'email': receiverId,
              'username': receiverUsername,
              'profilePicture': user?['profilePicture'],
              'bio': user?['bio'],
            }),
            child: Row(
              children: [
                SizedBox(width: 8 * scaleFactor),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24 * scaleFactor, // Reduced size for better fit
                      backgroundColor: AppConstants.primaryColor.withOpacity(0.8),
                      backgroundImage: user != null && user['profilePicture']?.isNotEmpty == true
                          ? CachedNetworkImageProvider('${BaseApi.imageBaseUrl}${user['profilePicture']}')
                          : null,
                      child: user == null || user['profilePicture']?.isEmpty != false
                          ? Text(
                              receiverUsername.isNotEmpty ? receiverUsername[0].toUpperCase() : '?',
                              style: TextStyle(
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                fontFamilyFallback: fontFamilyFallbacks,
                                color: Colors.white,
                                fontSize: 18 * scaleFactor,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
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
                            border: Border.all(color: Theme.of(context).colorScheme.onPrimary, width: 1.2 * scaleFactor),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 10 * scaleFactor),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        receiverUsername,
                        style: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontFamilyFallback: fontFamilyFallbacks,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 18 * scaleFactor,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Text(
                            isTyping ? 'typing'.tr : isOnline ? 'online'.tr : 'offline'.tr,
                            style: TextStyle(
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              fontFamilyFallback: fontFamilyFallbacks,
                              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                              fontSize: 13 * scaleFactor,
                            ),
                          ),
                          if (isTyping) ...[
                            SizedBox(width: 5 * scaleFactor),
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
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary, size: 28 * scaleFactor),
          onPressed: () {
            Get.delete<ChatScreenController>();
            Get.offNamed(AppRoutes.getHomePage());
          },
          tooltip: 'back'.tr,
        ),
        actions: [
          Obx(() => controller.chatController.errorMessage.value.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.error, color: Colors.redAccent, size: 28 * scaleFactor),
                  onPressed: () => Get.snackbar(
                    'Error',
                    controller.chatController.errorMessage.value,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.redAccent.withOpacity(0.8),
                    colorText: Theme.of(context).colorScheme.onPrimary,
                    margin: EdgeInsets.all(8 * scaleFactor),
                    icon: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.onPrimary, size: 28 * scaleFactor),
                    shouldIconPulse: true,
                  ),
                  tooltip: 'show_error'.tr,
                )
              : const SizedBox.shrink()),
          IconButton(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onPrimary, size: 28 * scaleFactor),
            onPressed: () {},
            tooltip: 'more_options'.tr,
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.6),
                Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(
    String date,
    double scaleFactor,
    BuildContext context,
    double textScaleFactor,
    List<String> fontFamilyFallbacks, {
    Key? key,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      key: key,
      padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor, horizontal: 16 * scaleFactor),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14 * scaleFactor, vertical: 5 * scaleFactor),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800]!.withOpacity(0.9) : Colors.grey[200]!.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16 * scaleFactor),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3 * scaleFactor,
                offset: Offset(0, 1.5 * scaleFactor),
              ),
            ],
          ),
          child: Text(
            date,
            style: TextStyle(
              fontFamily: GoogleFonts.poppins().fontFamily,
              fontFamilyFallback: fontFamilyFallbacks,
              fontSize: 13 * scaleFactor * textScaleFactor,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(
      BuildContext context, double scaleFactor, ChatScreenController controller, List<String> fontFamilyFallbacks) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2E2E2E) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16 * scaleFactor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.08 : 0.15),
            blurRadius: 6 * scaleFactor,
            offset: Offset(0, -2 * scaleFactor),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 8 * scaleFactor),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: 'type_message'.tr,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scaleFactor), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scaleFactor), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12 * scaleFactor),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.6), width: 0.8 * scaleFactor),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 10 * scaleFactor),
                prefixIcon: Icon(Icons.message_rounded, color: Theme.of(context).colorScheme.secondary.withOpacity(0.5), size: 18 * scaleFactor),
                suffixIcon: controller.messageController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, color: Theme.of(context).colorScheme.secondary.withOpacity(0.35), size: 18 * scaleFactor),
                        onPressed: () => controller.messageController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor?.withOpacity(0.8) ??
                    (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                hintStyle: TextStyle(
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  fontFamilyFallback: fontFamilyFallbacks,
                  color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.3),
                  fontSize: 15 * scaleFactor,
                ),
              ),
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontFamilyFallback: fontFamilyFallbacks,
                fontSize: 15 * scaleFactor,
                color: isDarkMode ? Colors.white.withOpacity(0.9) : Colors.black87.withOpacity(0.9),
              ),
              minLines: 1,
              maxLines: 3,
              onChanged: controller.onMessageChanged,
              onSubmitted: controller.sendMessage,
            ),
          ),
          SizedBox(width: 8 * scaleFactor),
          SizedBox(
            width: 44 * scaleFactor,
            height: 44 * scaleFactor,
            child: ElevatedButton(
              onPressed: () => controller.sendMessage(controller.messageController.text),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scaleFactor)),
                padding: EdgeInsets.zero,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 1,
              ),
              child: Icon(Icons.send_rounded, color: Theme.of(context).colorScheme.onSecondary, size: 20 * scaleFactor),
            ),
          ),
        ],
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
  final bool isSelected;
  final double textScaleFactor;
  final List<String> fontFamilyFallbacks;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.isSent,
    required this.scaleFactor,
    required this.screenWidth,
    required this.controller,
    required this.isSelected,
    required this.textScaleFactor,
    required this.fontFamilyFallbacks,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final maxBubbleWidth = screenWidth * 0.65;
    final messageText = message['message'] ?? 'Error';
    final edgePadding = 16 * scaleFactor;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5 * scaleFactor, horizontal: 8 * scaleFactor),
      child: Column(
        crossAxisAlignment: isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isSent && isSelected)
                Padding(
                  padding: EdgeInsets.only(right: 8 * scaleFactor),
                  child: Container(
                    padding: EdgeInsets.all(4 * scaleFactor),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 12 * scaleFactor, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12 * scaleFactor).copyWith(
                    bottomRight: isSent ? Radius.zero : Radius.circular(12 * scaleFactor),
                    bottomLeft: isSent ? Radius.circular(12 * scaleFactor) : Radius.zero,
                  ),
                  color: isSent
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.7)
                      : Theme.of(context).cardTheme.color?.withOpacity(0.95) ?? (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                  child: Padding(
                    padding: EdgeInsets.all(12 * scaleFactor),
                    child: Text(
                      messageText,
                      style: TextStyle(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontFamilyFallback: fontFamilyFallbacks,
                        color: isSent
                            ? Theme.of(context).colorScheme.onSecondary
                            : isDarkMode
                                ? Colors.white.withOpacity(0.9)
                                : Colors.black87,
                        fontSize: 14 * scaleFactor * textScaleFactor,
                        fontWeight: FontWeight.w400,
                      ),
                      softWrap: true,
                    ),
                  ),
                ),
              ),
              if (isSent && isSelected)
                Padding(
                  padding: EdgeInsets.only(left: 8 * scaleFactor),
                  child: Container(
                    padding: EdgeInsets.all(4 * scaleFactor),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 12 * scaleFactor, color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: isSent ? 0 : edgePadding, right: isSent ? edgePadding : 0, top: 4 * scaleFactor),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.formatTime(message['timestamp']),
                  style: TextStyle(
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontFamilyFallback: fontFamilyFallbacks,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 11 * scaleFactor * textScaleFactor,
                  ),
                ),
                if (isSent) ...[
                  SizedBox(width: 5 * scaleFactor),
                  Row(
                    children: [
                      Text(
                        message['read'] == true
                            ? 'read'.tr
                            : message['delivered'] == true
                                ? 'delivered'.tr
                                : 'sent'.tr,
                        style: TextStyle(
                          fontFamily: GoogleFonts.poppins().fontFamily,
                          fontFamilyFallback: fontFamilyFallbacks,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 11 * scaleFactor * textScaleFactor,
                        ),
                      ),
                      SizedBox(width: 3 * scaleFactor),
                      Icon(
                        message['delivered'] == true || message['read'] == true ? Icons.done_all : Icons.check,
                        color: message['read'] == true ? Colors.blue[300] : isDarkMode ? Colors.white70 : Colors.black54,
                        size: 13 * scaleFactor,
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

class _TypingDots extends StatelessWidget {
  final double scaleFactor;
  final ChatScreenController controller;

  const _TypingDots({required this.scaleFactor, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: controller.dot1,
          builder: (context, _) => Opacity(
            opacity: controller.dot1.value,
            child: Container(
              width: 7 * scaleFactor,
              height: 7 * scaleFactor,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        SizedBox(width: 3 * scaleFactor),
        AnimatedBuilder(
          animation: controller.dot2,
          builder: (context, _) => Opacity(
            opacity: controller.dot2.value,
            child: Container(
              width: 7 * scaleFactor,
              height: 7 * scaleFactor,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        SizedBox(width: 3 * scaleFactor),
        AnimatedBuilder(
          animation: controller.dot3,
          builder: (context, _) => Opacity(
            opacity: controller.dot3.value,
            child: Container(
              width: 7 * scaleFactor,
              height: 7 * scaleFactor,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}