import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../controllers/chat_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/constants.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverUsername;

  const ChatScreen({super.key, required this.receiverId, required this.receiverUsername});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.find<ChatController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxList<Map<String, dynamic>> unseenMessages = <Map<String, dynamic>>[].obs;
  final RxInt unseenCount = 0.obs;
  final RxBool showScrollArrow = false.obs;

  @override
  void initState() {
    super.initState();
    chatController.selectReceiver(widget.receiverId);
    _setupScrollListener();
    _setupMessageListener();
    _scheduleInitialScroll();
  }

  void _scheduleInitialScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && chatController.messages.isNotEmpty && _scrollController.hasClients) {
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      for (var msg in unseenMessages) {
        chatController.socketClient.markAsRead(msg['messageId']);
        msg['read'] = true;
        chatController.saveLocalMessage(msg);
      }
      unseenMessages.clear();
      unseenCount.value = 0;
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isAtBottom = _scrollController.offset >=
          _scrollController.position.maxScrollExtent - 10;
      showScrollArrow.value = !isAtBottom;
      if (isAtBottom && unseenMessages.isNotEmpty) {
        unseenMessages.clear();
        unseenCount.value = 0;
      }
    });
  }

  void _setupMessageListener() {
    ever(chatController.messages, (_) {
      if (!chatController.isLoadingMessages.value && chatController.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollToBottom();
          }
        });
      }
      final newMessages = chatController.messages
          .where((msg) =>
              msg['senderId']?.toString() == widget.receiverId &&
              msg['receiverId']?.toString() == chatController.currentUserId &&
              !(msg['read'] as bool? ?? false))
          .toList();
      final isAtBottom = _scrollController.hasClients &&
          _scrollController.offset >= _scrollController.position.maxScrollExtent - 10;
      if (!isAtBottom) {
        for (var msg in newMessages) {
          if (!unseenMessages.any((m) => m['messageId'] == msg['messageId'])) {
            unseenMessages.add(msg);
            unseenCount.value = unseenMessages.length;
          }
        }
      } else {
        for (var msg in newMessages) {
          if (!(msg['read'] as bool? ?? false)) {
            chatController.socketClient.markAsRead(msg['messageId']);
            msg['read'] = true;
            chatController.saveLocalMessage(msg);
          }
        }
        unseenMessages.clear();
        unseenCount.value = 0;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    chatController.clearReceiver();
    super.dispose();
    messageController.dispose(); // Dispose after super.dispose()
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scaleFactor = (screenSize.width / 1920 * screenSize.height / 1080).clamp(0.5, 1.0);

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
                _buildAppBar(context, scaleFactor),
                Expanded(
                  child: Obx(
                    () {
                      if (chatController.currentUserId == null) {
                        return Center(
                          child: Text(
                            'no_user'.tr,
                            style: GoogleFonts.poppins(
                              fontSize: 18 * scaleFactor,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                      }
                      if (chatController.isLoadingMessages.value) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppConstants.primaryColor,
                          ),
                        );
                      }
                      final messages = chatController.messages
                          .where((msg) => _isValidMessage(msg))
                          .toList();
                      print('ChatScreen: Filtered ${messages.length} messages for ${widget.receiverId}: $messages');
                      if (messages.isEmpty) {
                        return Center(
                          child: Text(
                            'no_messages'.tr,
                            style: GoogleFonts.poppins(
                              fontSize: 16 * scaleFactor,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        );
                      }
                      final groupedMessages = _groupMessagesByDate(messages);
                      final items = _buildMessageItems(groupedMessages);

                      return ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(vertical: 16 * scaleFactor),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          if (item['type'] == 'header') {
                            return _buildDateHeader(item['value'], scaleFactor, context);
                          }
                          final msg = item['message'];
                          final isSent = msg['senderId'].toString() ==
                              chatController.currentUserId;
                          return FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            child: _MessageBubble(
                              key: ValueKey(msg['messageId']),
                              message: msg,
                              isSent: isSent,
                              scaleFactor: scaleFactor,
                              screenWidth: screenSize.width,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildInputArea(context, scaleFactor),
              ],
            ),
          ),
          Positioned(
            bottom: 130 * scaleFactor,
            left: 20 * scaleFactor,
            child: Obx(
              () => AnimatedOpacity(
                opacity: showScrollArrow.value ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Visibility(
                  visible: showScrollArrow.value,
                  child: GestureDetector(
                    onTap: _scrollToBottom,
                    child: Container(
                      padding: EdgeInsets.all(20 * scaleFactor),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8 * scaleFactor,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                        size: 24 * scaleFactor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 115 * scaleFactor,
            right: 20 * scaleFactor,
            child: Obx(
              () => AnimatedOpacity(
                opacity: unseenCount.value > 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Visibility(
                  visible: unseenCount.value > 0,
                  child: GestureDetector(
                    onTap: _scrollToBottom,
                    child: Container(
                      padding: EdgeInsets.all(12 * scaleFactor),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8 * scaleFactor,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        unseenCount.value.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20 * scaleFactor,
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

  bool _isValidMessage(Map<String, dynamic> msg) {
    final isValid = msg['senderId'] != null &&
        msg['receiverId'] != null &&
        msg['message'] != null &&
        msg['messageId'] != null &&
        msg['timestamp'] != null &&
        ((msg['senderId'].toString() == chatController.currentUserId &&
                msg['receiverId'].toString() == widget.receiverId) ||
            (msg['senderId'].toString() == widget.receiverId &&
                msg['receiverId'].toString() == chatController.currentUserId));
    if (!isValid) {
      print('ChatScreen: Invalid message: $msg');
    }
    return isValid;
  }

  Map<String, List<Map<String, dynamic>>> _groupMessagesByDate(List<Map<String, dynamic>> messages) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    for (var msg in messages) {
      DateTime date;
      try {
        date = DateTime.parse(msg['timestamp']).toLocal();
      } catch (e) {
        date = DateTime.now();
      }
      String key;
      if (date.year == today.year && date.month == today.month && date.day == today.day) {
        key = 'today'.tr;
      } else if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        key = 'yesterday'.tr;
      } else if (date.isAfter(weekAgo)) {
        key = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'][date.weekday % 7].tr;
      } else {
        key = '${date.day}/${date.month}/${date.year}';
      }
      grouped.putIfAbsent(key, () => []).add(msg);
    }
    return grouped;
  }

  List<Map<String, dynamic>> _buildMessageItems(Map<String, List<Map<String, dynamic>>> groupedMessages) {
    final items = <Map<String, dynamic>>[];
    final sortedKeys = groupedMessages.keys.toList()
      ..sort((a, b) => _parseDateKey(a).compareTo(_parseDateKey(b)));

    for (var key in sortedKeys) {
      items.add({'type': 'header', 'value': key});
      final msgs = groupedMessages[key]!
        ..sort((a, b) => DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));
      items.addAll(msgs.map((msg) => {'type': 'message', 'message': msg}));
    }
    return items;
  }

  DateTime _parseDateKey(String key) {
    if (key == 'today'.tr) return DateTime.now();
    if (key == 'yesterday'.tr) return DateTime.now().subtract(const Duration(days: 1));
    final weekdays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'];
    final translatedWeekdays = weekdays.map((day) => day.tr).toList();
    if (translatedWeekdays.contains(key)) {
      final today = DateTime.now();
      final targetWeekday = translatedWeekdays.indexOf(key);
      final currentWeekday = today.weekday;
      final daysBack = (currentWeekday - targetWeekday) % 7;
      return today.subtract(Duration(days: daysBack));
    }
    try {
      final parts = key.split('/');
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (e) {
      return DateTime.now();
    }
  }

  Widget _buildDateHeader(String date, double scaleFactor, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12 * scaleFactor, horizontal: 20 * scaleFactor),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 6 * scaleFactor),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800]!.withOpacity(0.9) : Colors.grey[200]!.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20 * scaleFactor),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4 * scaleFactor,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            date,
            style: GoogleFonts.poppins(
              fontSize: 14 * scaleFactor,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double scaleFactor) {
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
      elevation: 8,
      shadowColor: Colors.black26,
      title: Obx(() {
        final user = chatController.allUsers
            .firstWhereOrNull((u) => u['email'] == widget.receiverId);
        final isTyping = chatController.typingUsers.contains(widget.receiverId);
        final isOnline = user != null && user['online'] == true;
        return GestureDetector(
          onTap: () => Get.toNamed(
            AppRoutes.getUserProfilePage(widget.receiverId, widget.receiverUsername),
            arguments: {
              'email': widget.receiverId,
              'username': widget.receiverUsername,
              'profilePicture': user?['profilePicture'],
              'bio': user?['bio'],
            },
          ),
          child: Row(
            children: [
              SizedBox(width: 4 * scaleFactor),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24 * scaleFactor,
                    backgroundColor: Colors.white,
                    backgroundImage: user != null && user['profilePicture']?.isNotEmpty == true
                        ? CachedNetworkImageProvider('http://localhost:5000${user['profilePicture']}')
                        : null,
                    child: user == null || user['profilePicture']?.isEmpty != false
                        ? Text(
                            widget.receiverUsername.isNotEmpty
                                ? widget.receiverUsername[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: AppConstants.primaryColor,
                              fontSize: 24 * scaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16 * scaleFactor,
                        height: 16 * scaleFactor,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2 * scaleFactor),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 8 * scaleFactor),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverUsername,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20 * scaleFactor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        isTyping ? 'typing'.tr : isOnline ? 'online'.tr : 'offline'.tr,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14 * scaleFactor,
                        ),
                      ),
                      if (isTyping) ...[
                        SizedBox(width: 6 * scaleFactor),
                        _TypingDots(scaleFactor: scaleFactor),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 28 * scaleFactor),
        onPressed: () => Get.offNamed(AppRoutes.getHomePage()),
      ),
      actions: [
        Obx(() => chatController.errorMessage.value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.error, color: Colors.red),
                onPressed: () => Get.snackbar('Error', chatController.errorMessage.value,
                    snackPosition: SnackPosition.BOTTOM),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildInputArea(BuildContext context, double scaleFactor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor, vertical: 4 * scaleFactor),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8 * scaleFactor, vertical: 4 * scaleFactor),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2E2E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16 * scaleFactor),
          border: Border.all(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1 * scaleFactor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6 * scaleFactor,
              offset: Offset(0, 2 * scaleFactor),
            ),
          ],
        ),
        height: 75 * scaleFactor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.attach_file,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                size: 18 * scaleFactor,
              ),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(maxWidth: 100 * scaleFactor),
              alignment: Alignment.center,
            ),
            Expanded(
              child: TextField(
                controller: messageController,
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
                    horizontal: 8 * scaleFactor,
                    vertical: 6 * scaleFactor,
                  ),
                ),
                minLines: 1,
                maxLines: 3,
                onChanged: (text) {
                  if (text.trim().isNotEmpty && chatController.currentUserId != null) {
                    chatController.onTyping(widget.receiverId);
                  } else {
                    chatController.onStopTyping(widget.receiverId);
                  }
                },
                onSubmitted: (text) => _sendMessage(text),
              ),
            ),
            SizedBox(width: 4 * scaleFactor),
            Container(
              width: 56 * scaleFactor,
              height: 56 * scaleFactor,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: AppConstants.primaryColor,
                elevation: 0,
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 28 * scaleFactor,
                ),
                onPressed: () {
                  final text = messageController.text; // Capture text before async operations
                  _sendMessage(text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty || chatController.currentUserId == null) return;
    chatController.send(text.trim(), widget.receiverId);
    if (mounted) {
      messageController.clear(); // Only clear if mounted
      chatController.onStopTyping(widget.receiverId);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollToBottom();
      }
    });
  }
}

class _MessageBubble extends StatefulWidget {
  final Map<String, dynamic> message;
  final bool isSent;
  final double scaleFactor;
  final double screenWidth;

  const _MessageBubble({
    required Key key,
    required this.message,
    required this.isSent,
    required this.scaleFactor,
    required this.screenWidth,
  }) : super(key: key);

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final maxBubbleWidth = widget.screenWidth - (20 * 8 * widget.scaleFactor); // Max width minus paddings
    final fontSize = 16 * widget.scaleFactor;
    final padding = 10 * widget.scaleFactor;
    final messageText = widget.message['message'] ?? 'Error';
    final edgePadding = 8 * widget.scaleFactor; // Minimal padding on both sides

    // Calculate text width to determine if wrapping is needed
    final textPainter = TextPainter(
      text: TextSpan(
        text: messageText,
        style: GoogleFonts.poppins(
          color: widget.isSent
              ? Colors.white
              : isDarkMode
                  ? Colors.white
                  : Colors.black,
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: Directionality.of(context),
    )..layout();

    // Determine if text needs to wrap based on its natural width
    final shouldWrap = textPainter.width > maxBubbleWidth;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * widget.scaleFactor),
      child: Column(
        crossAxisAlignment: widget.isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (widget.isSent) ...[
                SizedBox(width: edgePadding), // Minimal padding on the left
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                    child: CustomPaint(
                      painter: ChatBubblePainter(
                        isSent: widget.isSent,
                        gradient: widget.isSent
                            ? const LinearGradient(
                                colors: [AppConstants.primaryColor, Color(0xFF2E7D32)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: widget.isSent
                            ? null
                            : isDarkMode
                                ? const Color(0xFF2E2E2E)
                                : Colors.white,
                        scaleFactor: widget.scaleFactor,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20 * widget.scaleFactor,
                          vertical: padding,
                        ),
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              messageText,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                color: widget.isSent
                                    ? Colors.white
                                    : isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w400,
                              ),
                              softWrap: shouldWrap,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: edgePadding), // Minimal padding on the right
              ] else ...[
                SizedBox(width: edgePadding), // Minimal padding on the left
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxBubbleWidth),
                    child: CustomPaint(
                      painter: ChatBubblePainter(
                        isSent: widget.isSent,
                        gradient: widget.isSent
                            ? const LinearGradient(
                                colors: [AppConstants.primaryColor, Color(0xFF2E7D32)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: widget.isSent
                            ? null
                            : isDarkMode
                                ? const Color(0xFF2E2E2E)
                                : Colors.white,
                        scaleFactor: widget.scaleFactor,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18 * widget.scaleFactor,
                          vertical: padding,
                        ),
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Text(
                              messageText,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.poppins(
                                color: widget.isSent
                                    ? Colors.white
                                    : isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w400,
                              ),
                              softWrap: shouldWrap,
                              overflow: TextOverflow.clip,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: edgePadding), // Minimal padding on the right
              ],
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: widget.isSent ? 0 : edgePadding,
              right: widget.isSent ? edgePadding : 0,
              top: 4 * widget.scaleFactor,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(widget.message['timestamp']),
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 12 * widget.scaleFactor,
                  ),
                ),
                if (widget.isSent) ...[
                  SizedBox(width: 8 * widget.scaleFactor),
                  Row(
                    children: [
                      Text(
                        widget.message['read'] == true
                            ? 'read'.tr
                            : widget.message['delivered'] == true
                                ? 'delivered'.tr
                                : 'sent'.tr,
                        style: GoogleFonts.poppins(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 12 * widget.scaleFactor,
                        ),
                      ),
                      SizedBox(width: 4 * widget.scaleFactor),
                      widget.message['read'] == true
                          ? Stack(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: isDarkMode ? Colors.white70 : Colors.black54,
                                  size: 12 * widget.scaleFactor,
                                ),
                                Positioned(
                                  left: 4 * widget.scaleFactor,
                                  top: 2 * widget.scaleFactor,
                                  child: Icon(
                                    Icons.check,
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                    size: 12 * widget.scaleFactor,
                                  ),
                                ),
                              ],
                            )
                          : Icon(
                              Icons.check,
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                              size: 12 * widget.scaleFactor,
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

  String _formatTime(String? timestamp) {
    try {
      final date = DateTime.parse(timestamp!).toLocal();
      return DateFormat('h:mm a').format(date);
    } catch (e) {
      return 'N/A';
    }
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
      ..color = Colors.black26
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * scaleFactor);

    final path = Path();
    final shadowPath = Path();
    final cornerRadius = 12.0 * scaleFactor;
    final tailSize = 12.0 * scaleFactor;
    final tailCurveControl1 = 5.0 * scaleFactor;
    final tailCurveControl2 = 2.0 * scaleFactor;
    final tailHeightOffset = 0.1 * scaleFactor;

    if (isSent) {
      path.moveTo(cornerRadius, 0);
      shadowPath.moveTo(cornerRadius, 0);
      path.lineTo(size.width - cornerRadius - tailSize, 0);
      shadowPath.lineTo(size.width - cornerRadius - tailSize, 0);
      path.quadraticBezierTo(
          size.width - tailSize, 0, size.width - tailSize, cornerRadius);
      shadowPath.quadraticBezierTo(
          size.width - tailSize, 0, size.width - tailSize, cornerRadius);
      path.lineTo(size.width - tailSize, size.height - cornerRadius - tailSize * 0.7);
      shadowPath.lineTo(size.width - tailSize, size.height - cornerRadius - tailSize * 0.7);
      path.quadraticBezierTo(
          size.width - tailSize + tailCurveControl1,
          size.height - cornerRadius - tailHeightOffset,
          size.width - tailCurveControl2,
          size.height - cornerRadius + tailSize * 0.1);
      shadowPath.quadraticBezierTo(
          size.width - tailSize + tailCurveControl1,
          size.height - cornerRadius - tailHeightOffset,
          size.width - tailCurveControl2,
          size.height - cornerRadius + tailSize * 0.1);
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
      path.lineTo(tailSize, size.height - cornerRadius - tailSize * 0.7);
      shadowPath.lineTo(tailSize, size.height - cornerRadius - tailSize * 0.7);
      path.quadraticBezierTo(
          tailSize - tailCurveControl1,
          size.height - cornerRadius - tailHeightOffset,
          tailCurveControl2,
          size.height - cornerRadius + tailSize * 0.1);
      shadowPath.quadraticBezierTo(
          tailSize - tailCurveControl1,
          size.height - cornerRadius - tailHeightOffset,
          tailCurveControl2,
          size.height - cornerRadius + tailSize * 0.1);
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

class _TypingDots extends StatefulWidget {
  final double scaleFactor;

  const _TypingDots({required this.scaleFactor});

  @override
  _TypingDotsState createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dot1;
  late Animation<double> _dot2;
  late Animation<double> _dot3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _dot1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.33, curve: Curves.easeInOut)),
    );
    _dot2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.33, 0.66, curve: Curves.easeInOut)),
    );
    _dot3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.66, 1.0, curve: Curves.easeInOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Row(
        children: [
          Bounce(
            duration: const Duration(milliseconds: 1000),
            child: _buildDot(_dot1.value),
          ),
          SizedBox(width: 4 * widget.scaleFactor),
          Bounce(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 200),
            child: _buildDot(_dot2.value),
          ),
          SizedBox(width: 4 * widget.scaleFactor),
          Bounce(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 400),
            child: _buildDot(_dot3.value),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(double opacity) => Opacity(
        opacity: opacity,
        child: Container(
          width: 8 * widget.scaleFactor,
          height: 8 * widget.scaleFactor,
          decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
        ),
      );
}