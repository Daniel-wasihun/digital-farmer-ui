import 'dart:async';
import 'package:agri/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import 'chat_controller.dart';

class ChatScreenController extends GetxController with GetSingleTickerProviderStateMixin {
  final ChatController chatController = Get.find<ChatController>();
  final String receiverId;
  final String receiverUsername;

  final unseenMessages = <String, Map<String, dynamic>>{}.obs;
  final unseenCount = 0.obs;
  final showScrollArrow = false.obs;
  final messageItems = <Map<String, dynamic>>[].obs;
  final isAtBottom = true.obs;
  final isSelectionMode = false.obs;
  final selectedIndices = <int>{}.obs;
  final textScaleFactor = 1.0.obs;

  late final ScrollController scrollController;
  late final TextEditingController messageController;
  late final AnimationController animationController;
  late final Animation<double> dot1;
  late final Animation<double> dot2;
  late final Animation<double> dot3;

  Timer? _typingTimer;
  bool _needsInitialScroll = true;
  static const _typingDebounceDuration = Duration(milliseconds: 500);
  bool _isTyping = false;
  bool _disposed = false;
  final messageText = ''.obs;
  final GetStorage _storage = GetStorage();
  static const String _textScaleKey = 'chat_text_scale';

  ChatScreenController({required this.receiverId, required this.receiverUsername});

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    messageController = TextEditingController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    dot1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: const Interval(0.0, 0.33, curve: Curves.easeInOut)),
    );
    dot2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: const Interval(0.33, 0.66, curve: Curves.easeInOut)),
    );
    dot3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: const Interval(0.66, 1.0, curve: Curves.easeInOut)),
    );

    Get.closeAllSnackbars();

    _loadTextScale();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.selectReceiver(receiverId);
      _updateMessageItems();
      _markMessagesAsReadAndClearNotifications();
      _setupScrollListener();
      _setupMessageListener();
      _scheduleInitialScroll();
      _loadUnseenMessages();
    });
  }

  Future<void> _loadTextScale() async {
    try {
      await GetStorage.init();
      final savedScale = _storage.read<double>(_textScaleKey);
      if (savedScale != null) {
        textScaleFactor.value = savedScale.clamp(0.7, 1.8);
      }
    } catch (e) {
      print('Error loading text scale: $e');
    }
  }

  Future<void> _saveTextScale() async {
    try {
      await GetStorage.init();
      await _storage.write(_textScaleKey, textScaleFactor.value);
    } catch (e) {
      print('Error saving text scale: $e');
    }
  }

  void _markMessagesAsReadAndClearNotifications() {
    final unreadMessages = chatController.messages.values
        .where((msg) =>
            msg['senderId'] == receiverId &&
            msg['receiverId'] == chatController.currentUserId.value &&
            !msg['read'])
        .toList();

    for (var msg in unreadMessages) {
      chatController.socketClient.markAsRead(msg['messageId']);
      msg['read'] = true;
      chatController.messages[msg['messageId']]!['read'] = true;
    }
    chatController.saveMessagesForUser(receiverId);

    if (chatController.unseenNotifications.containsKey(receiverId)) {
      chatController.unseenNotifications.remove(receiverId);
      chatController.saveUnseenNotifications();
    }
    unseenMessages.clear();
    unseenCount.value = 0;
  }

  void _loadUnseenMessages() {
    if (chatController.unseenNotifications.containsKey(receiverId)) {
      final unseen = chatController.unseenNotifications[receiverId]!;
      for (var msg in unseen) {
        if (!unseenMessages.containsKey(msg['messageId'])) {
          unseenMessages[msg['messageId']] = msg;
        }
      }
      unseenCount.value = unseenMessages.length;
    }
  }

  void _scheduleInitialScroll() {
    if (!_needsInitialScroll) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_disposed || !scrollController.hasClients) return;
        scrollToBottom(immediate: true);
        _needsInitialScroll = false;
        // Retry after another 200ms if not at bottom
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_disposed || !scrollController.hasClients) return;
          if (scrollController.offset < scrollController.position.maxScrollExtent) {
            scrollToBottom(immediate: true);
          }
        });
      });
    });
  }

  void scrollToBottom({bool immediate = false}) {
    if (!scrollController.hasClients) return;
    final maxExtent = scrollController.position.maxScrollExtent + 20; // Account for bottom padding
    if (immediate) {
      scrollController.jumpTo(maxExtent);
    } else {
      scrollController.animateTo(
        maxExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    isAtBottom.value = true;
    showScrollArrow.value = false;
    unseenCount.value = 0;
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      final offset = scrollController.offset;
      final maxExtent = scrollController.position.maxScrollExtent;
      final newIsAtBottom = offset >= maxExtent - 20; // Adjusted tolerance for padding
      if (isAtBottom.value != newIsAtBottom) {
        isAtBottom.value = newIsAtBottom;
        showScrollArrow.value = !newIsAtBottom && offset > 200;
      }
    });
  }

  void _setupMessageListener() {
    ever(chatController.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMessageItems();
        if (scrollController.hasClients && isAtBottom.value) {
          scrollToBottom(immediate: false);
        }
      });
    });
    ever(textScaleFactor, (_) {
      _saveTextScale();
    });
  }

  bool _isValidMessage(Map<String, dynamic> msg) {
    return msg['senderId'] != null &&
        msg['receiverId'] != null &&
        msg['message'] != null &&
        msg['messageId'] != null &&
        msg['timestamp'] != null &&
        ((msg['senderId'] == chatController.currentUserId.value && msg['receiverId'] == receiverId) ||
            (msg['senderId'] == receiverId && msg['receiverId'] == chatController.currentUserId.value));
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
        print('ChatScreenController: Invalid timestamp: ${msg['timestamp']}, using now');
        date = DateTime.now();
      }
      String key;
      if (date.year == today.year && date.month == today.month && date.day == today.day) {
        key = 'today'.tr;
      } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
        key = 'yesterday'.tr;
      } else if (date.isAfter(weekAgo)) {
        key = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday'][date.weekday % 7].tr;
      } else {
        key = DateFormat('dd/MM/yyyy').format(date);
      }
      grouped.putIfAbsent(key, () => []).add(msg);
    }
    return grouped;
  }

  void _updateMessageItems() {
    final messages = chatController.messages.values.where(_isValidMessage).toList()
      ..sort((a, b) => DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));
    final groupedMessages = _groupMessagesByDate(messages);
    final items = <Map<String, dynamic>>[];
    final sortedKeys = groupedMessages.keys.toList()
      ..sort((a, b) => _parseDateKey(a).compareTo(_parseDateKey(b)));

    for (var key in sortedKeys) {
      items.add({'type': 'header', 'value': key, 'key': key});
      final msgs = groupedMessages[key]!;
      items.addAll(msgs.map((msg) => {
            'type': 'message',
            'message': msg,
            'key': msg['messageId'],
            'isNew': DateTime.parse(msg['timestamp']).isAfter(DateTime.now().subtract(const Duration(seconds: 1))),
          }));
    }
    messageItems.assignAll(items);
    messageItems.refresh();
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
      print('ChatScreenController: Invalid date key: $key, using now');
      return DateTime.now();
    }
  }

  void onMessageChanged(String text) {
    if (_disposed) return;

    messageText.value = text;

    if (text.trim().isNotEmpty && !_isTyping) {
      _isTyping = true;
      chatController.onTyping(receiverId);
    } else if (text.trim().isEmpty && _isTyping) {
      _isTyping = false;
      chatController.onStopTyping(receiverId);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(_typingDebounceDuration, () {
      if (_disposed) return;
      if (!_isTyping || messageText.value.trim().isEmpty) {
        _isTyping = false;
        chatController.onStopTyping(receiverId);
      }
    });
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty || chatController.currentUserId.value == null) {
      print('ChatScreenController: Empty text or no userId');
      return;
    }
    chatController.send(text.trim(), receiverId);
    messageText.value = '';
    messageController.clear();
    _isTyping = false;
    chatController.onStopTyping(receiverId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients && !_disposed) {
          scrollToBottom(immediate: false);
          // Ensure absolute bottom after animation
          Future.delayed(const Duration(milliseconds: 300), () {
            if (scrollController.hasClients && !_disposed) {
              scrollToBottom(immediate: true);
            }
          });
        }
      });
    });
  }

  String formatTime(String? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      return DateFormat('h:mm a').format(date);
    } catch (e) {
      print('ChatScreenController: Invalid timestamp: $timestamp, error: $e');
      return 'N/A';
    }
  }

  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedIndices.clear();
    }
    selectedIndices.refresh();
    messageItems.refresh();
  }

  void toggleMessageSelection(int index) {
    if (index < 0 || index >= messageItems.length || messageItems[index]['type'] == 'header') return;
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }
    if (selectedIndices.isEmpty) {
      isSelectionMode.value = false;
    }
    selectedIndices.refresh();
    messageItems.refresh();
  }

  void copySelectedMessages() {
    if (selectedIndices.isEmpty) return;
    final validIndices = selectedIndices.where((index) => index < messageItems.length && messageItems[index]['type'] == 'message').toList();
    if (validIndices.isEmpty) {
      clearSelection();
      return;
    }
    final selectedMessages = validIndices.map((index) => messageItems[index]['message']['message'] as String).join('\n');
    Clipboard.setData(ClipboardData(text: selectedMessages));
    Get.snackbar(
      'copied'.tr,
      validIndices.length == 1 ? 'message_copied'.tr : 'messages_copied'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppConstants.primaryColor.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(8),
      icon: const Icon(Icons.copy, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
    clearSelection();
  }

  void deleteSelectedMessages() {
    if (selectedIndices.isEmpty) return;
    final validIndices = selectedIndices.where((index) => index < messageItems.length && messageItems[index]['type'] == 'message').toList();
    if (validIndices.isEmpty) {
      clearSelection();
      return;
    }
    Get.dialog(
      AlertDialog(
        title: Text(
          'confirm_delete'.tr,
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontFamilyFallback: ['NotoSansEthiopic', 'AbyssinicaSIL', 'Noto Sans', 'Roboto', 'Arial'],
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'delete_messages_confirm'.trParams({
            'count': validIndices.length.toString(),
          }),
          style: TextStyle(
            fontFamily: GoogleFonts.poppins().fontFamily,
            fontFamilyFallback: ['NotoSansEthiopic', 'AbyssinicaSIL', 'Noto Sans', 'Roboto', 'Arial'],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontFamilyFallback: ['NotoSansEthiopic', 'AbyssinicaSIL', 'Noto Sans', 'Roboto', 'Arial'],
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              final messagesToDelete = validIndices.map((index) => messageItems[index]['message']['messageId'] as String).toList();
              for (var messageId in messagesToDelete) {
                chatController.messages.remove(messageId);
              }
              chatController.saveMessagesForUser(receiverId);
              _updateMessageItems();
              Get.snackbar(
                'deleted'.tr,
                validIndices.length == 1 ? 'message_deleted'.tr : 'messages_deleted'.tr,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppConstants.primaryColor.withOpacity(0.8),
                colorText: Colors.white,
                margin: const EdgeInsets.all(8),
                icon: const Icon(Icons.delete, color: Colors.white),
                duration: const Duration(seconds: 2),
              );
              clearSelection();
            },
            child: Text(
              'delete'.tr,
              style: TextStyle(
                fontFamily: GoogleFonts.poppins().fontFamily,
                fontFamilyFallback: ['NotoSansEthiopic', 'AbyssinicaSIL', 'Noto Sans', 'Roboto', 'Arial'],
                color: Get.theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void clearSelection() {
    selectedIndices.clear();
    isSelectionMode.value = false;
    selectedIndices.refresh();
    messageItems.refresh();
  }

  @override
  void onClose() {
    _disposed = true;
    _typingTimer?.cancel();
    _typingTimer = null;
    scrollController.dispose();
    animationController.dispose();
    messageController.clear();
    messageController.dispose();
    messageText.value = '';
    chatController.clearReceiver();
    super.onClose();
    print('ChatScreenController: Closed');
  }
}

// Placeholder for vsync (replace with actual implementation if needed)
class PlaceholderVsync implements TickerProvider {
  const PlaceholderVsync();
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}