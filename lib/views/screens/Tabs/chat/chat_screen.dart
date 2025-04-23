import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../controllers/chat_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/constants.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverUsername;

  ChatScreen({super.key, required this.receiverId, required this.receiverUsername});

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
    chatController.selectReceiver(widget.receiverId); // Ensure messages are fetched
    _setupScrollListener();
    _setupMessageListener();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isAtBottom = _scrollController.offset >=
          _scrollController.position.maxScrollExtent - 10; // Small tolerance
      showScrollArrow.value = !isAtBottom;
      if (isAtBottom && unseenMessages.isNotEmpty) {
        unseenMessages.clear();
        unseenCount.value = 0;
      }
    });
  }

  void _setupMessageListener() {
    ever(chatController.messages, (_) {
      final newMessages = chatController.messages
          .where((msg) =>
              msg['senderId'] == widget.receiverId &&
              msg['receiverId'] == chatController.currentUserId &&
              (msg['read'] as bool? ?? false) == false)
          .toList();
      final isAtBottom = _scrollController.offset >=
          _scrollController.position.maxScrollExtent - 10;
      if (!isAtBottom) {
        for (var msg in newMessages) {
          if (!unseenMessages.any((m) => m['messageId'] == msg['messageId'])) {
            unseenMessages.add(msg);
            unseenCount.value = unseenMessages.length;
          }
        }
      } else {
        // Mark as read and auto-scroll if at bottom
        for (var msg in newMessages) {
          if (!msg['read']) {
            chatController.socketClient.markAsRead(msg['messageId']);
            msg['read'] = true;
            chatController.saveLocalMessage(msg);
          }
        }
        unseenMessages.clear();
        unseenCount.value = 0;
        // Auto-scroll for live chat
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollToBottom();
          }
        });
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      // Mark unseen messages as read
      for (var msg in unseenMessages) {
        chatController.socketClient.markAsRead(msg['messageId']);
        msg['read'] = true;
        chatController.saveLocalMessage(msg);
      }
      unseenMessages.clear();
      unseenCount.value = 0;
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    chatController.clearReceiver();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final baseScale = screenSize.width / 1920;
    final heightScale = screenSize.height / 1080;
    final scaleFactor = (baseScale * heightScale).clamp(0.5, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [Color(0xFF1A2B1F), Color(0xFF263238)]
                    : [Color(0xFFE8F5E9), Color(0xFFB2DFDB)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
                            style: GoogleFonts.poppins(fontSize: 18 * scaleFactor),
                          ),
                        );
                      }
                      if (chatController.isLoadingMessages.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppConstants.primaryColor,
                          ),
                        );
                      }
                      // Group messages by date
                      final messages = chatController.messages
                          .where((msg) =>
                              (msg['senderId'] == chatController.currentUserId &&
                                  msg['receiverId'] == widget.receiverId) ||
                              (msg['senderId'] == widget.receiverId &&
                                  msg['receiverId'] == chatController.currentUserId))
                          .toList();
                      if (messages.isEmpty) {
                        return Center(
                          child: Text(
                            'no_messages'.tr,
                            style: GoogleFonts.poppins(
                              fontSize: 16 * scaleFactor,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
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
                          } else {
                            final msg = item['message'];
                            final isSent = msg['senderId'] == chatController.currentUserId;
                            return _MessageBubble(
                              key: ValueKey(msg['messageId']),
                              message: msg,
                              isSent: isSent,
                              scaleFactor: scaleFactor,
                              screenWidth: screenSize.width,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                _buildInputArea(context, scaleFactor),
              ],
            ),
          ),
          // Scroll-to-bottom arrow (left side)
          Positioned(
            bottom: 130 * scaleFactor,
            left: 20 * scaleFactor, // Moved to left
            child: Obx(
              () => AnimatedOpacity(
                opacity: showScrollArrow.value ? 1.0 : 0.0,
                duration: Duration(milliseconds: 200),
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
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6 * scaleFactor,
                            offset: Offset(0, 2 * scaleFactor),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down, // V-like chevron
                        color: Colors.white,
                        size: 24 * scaleFactor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // New messages badge (right side)
          Positioned(
            bottom: 115 * scaleFactor,
            right: 20 * scaleFactor, // Stays on right
            child: Obx(
              () => AnimatedOpacity(
                opacity: unseenCount.value > 0 ? 1.0 : 0.0,
                duration: Duration(milliseconds: 200),
                child: Visibility(
                  visible: unseenCount.value > 0,
                  child: GestureDetector(
                    onTap: _scrollToBottom,
                    child: Container(
                      padding: EdgeInsets.all(12 * scaleFactor), // 2x padding
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unseenCount.value.toString(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20 * scaleFactor, // 2x font size
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

  Map<String, List<Map<String, dynamic>>> _groupMessagesByDate(List<Map<String, dynamic>> messages) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));
    final weekAgo = today.subtract(Duration(days: 7));

    for (var msg in messages) {
      DateTime? date;
      try {
        date = DateTime.parse(msg['timestamp']).toLocal();
      } catch (e) {
        print('ChatScreen: Invalid timestamp in message ${msg['messageId']}: $e');
        date = DateTime.now(); // Fallback
      }
      String key;
      if (date.year == today.year && date.month == today.month && date.day == today.day) {
        key = 'Today';
      } else if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        key = 'Yesterday';
      } else if (date.isAfter(weekAgo)) {
        switch (date.weekday) {
          case 1:
            key = 'Monday';
            break;
          case 2:
            key = 'Tuesday';
            break;
          case 3:
            key = 'Wednesday';
            break;
          case 4:
            key = 'Thursday';
            break;
          case 5:
            key = 'Friday';
            break;
          case 6:
            key = 'Saturday';
            break;
          case 7:
            key = 'Sunday';
            break;
          default:
            key = '${date.day}/${date.month}/${date.year}';
        }
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
      ..sort((a, b) {
        final aDate = _parseDateKey(a);
        final bDate = _parseDateKey(b);
        return aDate.compareTo(bDate); // Oldest first
      });

    for (var key in sortedKeys) {
      items.add({'type': 'header', 'value': key});
      final msgs = groupedMessages[key]!
        ..sort((a, b) {
          DateTime aTime, bTime;
          try {
            aTime = DateTime.parse(a['timestamp']);
          } catch (e) {
            aTime = DateTime.now();
            print('ChatScreen: Invalid timestamp in sort ${a['messageId']}: $e');
          }
          try {
            bTime = DateTime.parse(b['timestamp']);
          } catch (e) {
            bTime = DateTime.now();
            print('ChatScreen: Invalid timestamp in sort ${a['messageId']}: $e');
          }
          return aTime.compareTo(bTime);
        });
      items.addAll(msgs.map((msg) => {'type': 'message', 'message': msg}));
    }
    return items;
  }

  DateTime _parseDateKey(String key) {
    if (key == 'Today') return DateTime.now();
    if (key == 'Yesterday') return DateTime.now().subtract(Duration(days: 1));
    if (['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].contains(key)) {
      final today = DateTime.now();
      final weekdayMap = {
        'Monday': 1,
        'Tuesday': 2,
        'Wednesday': 3,
        'Thursday': 4,
        'Friday': 5,
        'Saturday': 6,
        'Sunday': 7,
      };
      final targetWeekday = weekdayMap[key]!;
      final currentWeekday = today.weekday;
      int daysBack = currentWeekday - targetWeekday;
      if (daysBack < 0) daysBack += 7;
      return today.subtract(Duration(days: daysBack));
    }
    try {
      final parts = key.split('/');
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (e) {
      print('ChatScreen: Invalid date key $key: $e');
      return DateTime.now();
    }
  }

  Widget _buildDateHeader(String date, double scaleFactor, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scaleFactor, horizontal: 20 * scaleFactor),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * scaleFactor, vertical: 4 * scaleFactor),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(12 * scaleFactor),
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppConstants.primaryColor,
              Color(0xFF2E7D32),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
      shadowColor: Colors.black38,
      title: Obx(() {
        final user = chatController.allUsers
            .firstWhereOrNull((u) => u['email'] == widget.receiverId);
        final isTyping = chatController.typingUsers.contains(widget.receiverId);
        final isOnline = user != null && user['online'] == true;
        return GestureDetector(
          onTap: () {
            Get.toNamed(
              AppRoutes.getUserProfilePage(widget.receiverId, widget.receiverUsername),
              arguments: {
                'email': widget.receiverId,
                'username': widget.receiverUsername,
                'profilePicture': user?['profilePicture'],
                'bio': user?['bio'],
              },
            );
          },
          child: Row(
            children: [
              SizedBox(width: 4 * scaleFactor),
              CircleAvatar(
                radius: 48 * scaleFactor,
                backgroundColor: Colors.white,
                backgroundImage: user != null &&
                        user['profilePicture'] != null &&
                        user['profilePicture'].isNotEmpty
                    ? NetworkImage('http://localhost:5000${user['profilePicture']}')
                    : null,
                child: user == null ||
                        user['profilePicture'] == null ||
                        user['profilePicture'].isEmpty
                    ? Text(
                        widget.receiverUsername[0].toUpperCase(),
                        style: TextStyle(
                          color: AppConstants.primaryColor,
                          fontSize: 24 * scaleFactor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 8 * scaleFactor),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverUsername,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26 * scaleFactor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        isTyping
                            ? 'Typing...'
                            : isOnline
                                ? 'Online'
                                : 'Offline',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 16 * scaleFactor,
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
      leadingWidth: 40 * scaleFactor,
      leading: IconButton(
        padding: EdgeInsets.only(left: 8 * scaleFactor),
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 28 * scaleFactor),
        onPressed: () {
          try {
            Get.offNamed(AppRoutes.getHomePage());
          } catch (e) {
            print('ChatScreen: Back button error: $e');
            Get.offNamed(AppRoutes.getHomePage());
          }
        },
      ),
    );
  }

  Widget _buildInputArea(BuildContext context, double scaleFactor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(12 * scaleFactor),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2E3B43) : Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10 * scaleFactor,
            offset: Offset(0, -4 * scaleFactor),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file,
                color: isDarkMode
                    ? Color(0xFFCFD8DC)
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                size: 26 * scaleFactor),
            onPressed: () {
              // Implement attachment functionality
            },
          ),
          Expanded(
            child: TextField(
              controller: messageController,
              style: GoogleFonts.poppins(
                fontSize: 18 * scaleFactor,
                height: 1.4,
                color: isDarkMode ? Color(0xFFE0E0E0) : Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'type_message'.tr,
                hintStyle: GoogleFonts.poppins(
                  color: isDarkMode
                      ? Color(0xFFCFD8DC).withOpacity(0.7)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 18 * scaleFactor,
                ),
                filled: true,
                fillColor: isDarkMode ? Color(0xFF37474F) : Color(0xFFECEFF1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(32 * scaleFactor),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 24 * scaleFactor,
                  vertical: 14 * scaleFactor,
                ),
              ),
              onChanged: (text) {
                if (text.isNotEmpty && chatController.currentUserId != null) {
                  chatController.onTyping(widget.receiverId);
                } else {
                  chatController.onStopTyping(widget.receiverId);
                }
              },
              onSubmitted: (text) {
                if (text.trim().isNotEmpty && chatController.currentUserId != null) {
                  chatController.send(text.trim(), widget.receiverId);
                  messageController.clear();
                  chatController.onStopTyping(widget.receiverId);
                  // Scroll to bottom
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
              },
            ),
          ),
          SizedBox(width: 12 * scaleFactor),
          FloatingActionButton(
            mini: true,
            backgroundColor: AppConstants.primaryColor,
            elevation: 4,
            child: Icon(Icons.send, color: Colors.white, size: 26 * scaleFactor),
            onPressed: () {
              if (messageController.text.trim().isNotEmpty &&
                  chatController.currentUserId != null) {
                chatController.send(messageController.text.trim(), widget.receiverId);
                messageController.clear();
                chatController.onStopTyping(widget.receiverId);
                // Scroll to bottom
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }
            },
          ),
        ],
      ),
    );
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
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(widget.isSent ? 0.5 : -0.5, 0),
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
    final bool isLongMessage = widget.message['message'] is String &&
        (widget.message['message'] as String).length > 50;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: widget.isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.isSent && isLongMessage ? 20 * widget.scaleFactor : 0,
          right: !widget.isSent && isLongMessage ? 20 * widget.scaleFactor : 0,
        ),
        child: Column(
          crossAxisAlignment:
              widget.isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 8 * widget.scaleFactor,
                    horizontal: 20 * widget.scaleFactor,
                  ),
                  constraints: BoxConstraints(
                    maxWidth: widget.screenWidth * 0.7,
                  ),
                  child: IntrinsicWidth(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * widget.scaleFactor,
                        vertical: 8 * widget.scaleFactor,
                      ),
                      decoration: BoxDecoration(
                        gradient: widget.isSent
                            ? LinearGradient(
                                colors: [
                                  AppConstants.primaryColor,
                                  Color(0xFF2E7D32),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: widget.isSent ? null : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24 * widget.scaleFactor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10 * widget.scaleFactor,
                            offset: Offset(0, 4 * widget.scaleFactor),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.message['message'] ?? 'Error',
                        style: GoogleFonts.poppins(
                          color: widget.isSent
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                          fontSize: 20 * widget.scaleFactor,
                          fontWeight: FontWeight.w400,
                        ),
                        softWrap: true,
                        maxLines: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20 * widget.scaleFactor),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(widget.message['timestamp']),
                    style: GoogleFonts.poppins(
                      color: isDarkMode
                          ? Colors.white70
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14 * widget.scaleFactor,
                    ),
                  ),
                  if (widget.isSent) ...[
                    SizedBox(width: 8 * widget.scaleFactor),
                    Text(
                      widget.message['read'] == true
                          ? 'read'.tr
                          : widget.message['delivered'] == true
                              ? 'delivered'.tr
                              : 'sent'.tr,
                      style: GoogleFonts.poppins(
                        color: isDarkMode
                            ? Colors.white70
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 14 * widget.scaleFactor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? timestamp) {
    try {
      final date = DateTime.parse(timestamp!).toLocal();
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      print('ChatScreen: Invalid timestamp format: $timestamp, error: $e');
      return 'N/A';
    }
  }
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
      duration: Duration(milliseconds: 1000),
    )..repeat();
    _dot1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.33, curve: Curves.easeInOut),
      ),
    );
    _dot2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.33, 0.66, curve: Curves.easeInOut),
      ),
    );
    _dot3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.66, 1.0, curve: Curves.easeInOut),
      ),
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
      builder: (context, child) {
        return Row(
          children: [
            _buildDot(_dot1.value),
            SizedBox(width: 4 * widget.scaleFactor),
            _buildDot(_dot2.value),
            SizedBox(width: 4 * widget.scaleFactor),
            _buildDot(_dot3.value),
          ],
        );
      },
    );
  }

  Widget _buildDot(double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 8 * widget.scaleFactor,
        height: 8 * widget.scaleFactor,
        decoration: BoxDecoration(
          color: Colors.white70,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}