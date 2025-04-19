import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'chat_controller.dart';

class ChatScreenController extends GetxController with GetSingleTickerProviderStateMixin {
  final ChatController chatController = Get.find<ChatController>();
  final String receiverId;
  final String receiverUsername;

  // Reactive state
  final unseenMessages = <String, Map<String, dynamic>>{}.obs; // Keyed by messageId
  final unseenCount = 0.obs;
  final showScrollArrow = false.obs;
  final messageItems = <Map<String, dynamic>>[].obs;
  final isAtBottom = true.obs;

  // Controllers
  late final ScrollController scrollController;
  late final TextEditingController messageController;
  late final AnimationController animationController;
  late final Animation<double> dot1;
  late final Animation<double> dot2;
  late final Animation<double> dot3;

  // Internal
  Timer? _debounceTimer;
  bool _needsInitialScroll = true;
  static const _debounceDuration = Duration(milliseconds: 100);

  ChatScreenController({required this.receiverId, required this.receiverUsername});

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    scrollController = ScrollController();
    messageController = TextEditingController();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    // Setup typing dot animations
    dot1 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: const Interval(0.0, 0.33, curve: Curves.easeInOut)),
    );
    dot2 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: const Interval(0.33, 0.66, curve: Curves.easeInOut)),
    );
    dot3 = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: animationController, curve: const Interval(0.66, 1.0, curve: Curves.easeInOut)),
    );

    // Initialize chat
    chatController.selectReceiver(receiverId);
    _setupScrollListener();
    _setupMessageListener();
    _scheduleInitialScroll();
  }

  void _scheduleInitialScroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_needsInitialScroll && chatController.messages.isNotEmpty && scrollController.hasClients) {
        scrollToBottom(immediate: true);
        _needsInitialScroll = false;
      }
    });
  }

  void scrollToBottom({bool immediate = false}) {
    if (!scrollController.hasClients) return;
    if (isAtBottom.value && !immediate) return;
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: immediate ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    for (var msg in unseenMessages.values) {
      chatController.socketClient.markAsRead(msg['messageId']);
      msg['read'] = true;
      chatController.saveMessagesForUser(receiverId);
    }
    unseenMessages.clear();
    unseenCount.value = 0;
  }

  void _setupScrollListener() {
    scrollController.addListener(() {
      final offset = scrollController.offset;
      final maxExtent = scrollController.position.maxScrollExtent;
      final newIsAtBottom = offset >= maxExtent - 10;
      if (isAtBottom.value != newIsAtBottom) {
        isAtBottom.value = newIsAtBottom;
        showScrollArrow.value = !newIsAtBottom;
      }
      if (newIsAtBottom && unseenMessages.isNotEmpty) {
        scrollToBottom();
      }
    });
  }

  void _setupMessageListener() {
    ever(chatController.messages, (_) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(_debounceDuration, _processMessages);
    });
  }

  void _processMessages() {
    final newMessages = chatController.messages.values
        .where((msg) =>
            msg['senderId'] == receiverId &&
            msg['receiverId'] == chatController.currentUserId.value &&
            !msg['read'])
        .toList();

    if (!isAtBottom.value) {
      for (var msg in newMessages) {
        if (!unseenMessages.containsKey(msg['messageId'])) {
          unseenMessages[msg['messageId']] = msg;
          unseenCount.value = unseenMessages.length;
        }
      }
    } else {
      for (var msg in newMessages) {
        if (!msg['read']) {
          chatController.socketClient.markAsRead(msg['messageId']);
          msg['read'] = true;
          chatController.saveMessagesForUser(receiverId);
        }
      }
      unseenMessages.clear();
      unseenCount.value = 0;
    }

    if (!chatController.isLoadingMessages.value && chatController.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients && isAtBottom.value) {
          scrollToBottom();
        }
      });
    }
    _updateMessageItems();
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
    final messages = chatController.messages.values.where(_isValidMessage).toList();
    final groupedMessages = _groupMessagesByDate(messages);
    final items = <Map<String, dynamic>>[];
    final sortedKeys = groupedMessages.keys.toList()
      ..sort((a, b) => _parseDateKey(a).compareTo(_parseDateKey(b)));

    for (var key in sortedKeys) {
      items.add({'type': 'header', 'value': key, 'key': key});
      final msgs = groupedMessages[key]!
        ..sort((a, b) => DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));
      items.addAll(msgs.map((msg) => {
            'type': 'message',
            'message': msg,
            'key': msg['messageId'],
            'isNew': DateTime.parse(msg['timestamp']).isAfter(DateTime.now().subtract(const Duration(seconds: 1))),
          }));
    }
    messageItems.assignAll(items);
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

  void sendMessage(String text) {
    if (text.trim().isEmpty || chatController.currentUserId.value == null) {
      print('ChatScreenController: Empty text or no userId');
      return;
    }
    chatController.send(text.trim(), receiverId);
    messageController.clear();
    chatController.onStopTyping(receiverId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollToBottom();
      }
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

  @override
  void onClose() {
    _debounceTimer?.cancel();
    scrollController.dispose();
    messageController.dispose();
    animationController.dispose();
    chatController.clearReceiver();
    super.onClose();
    print('ChatScreenController: Closed');
  }
}