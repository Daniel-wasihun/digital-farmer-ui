import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../services/socket_client.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class ChatController extends GetxController {
  final SocketClient socketClient = SocketClient();
  final StorageService storageService = Get.find<StorageService>();
  final ApiService apiService = Get.find<ApiService>();
  String? currentUserId;
  final messages = <Map<String, dynamic>>[].obs;
  final allUsers = <Map<String, dynamic>>[].obs;
  final typingUsers = <String>{}.obs;
  final isConnected = false.obs;
  final errorMessage = ''.obs;
  final selectedReceiverId = ''.obs;
  final isLoadingUsers = false.obs;
  final isLoadingMessages = false.obs;

  @override
  void onInit() {
    super.onInit();
    ever(storageService.user, (_) => _handleUserChange());
    _initialize();
  }

  void _initialize() async {
    try {
      final user = storageService.getUser();
      if (user == null || storageService.getToken() == null) {
        print('ChatController: No user or token, redirecting to login');
        errorMessage.value = 'not_logged_in'.tr;
        Get.offAllNamed(AppRoutes.getSignInPage());
        return;
      }
      currentUserId = user['email']?.toString();
      print('ChatController: Initialized with userId: $currentUserId');
      await loadLocalMessages();
      await fetchUsers();
      connect();
      ever(isConnected, (_) {
        if (isConnected.value) {
          fetchUsers();
          syncLocalMessages();
        }
      });
    } catch (e) {
      print('ChatController: Initialize error: $e');
      errorMessage.value = 'failed_to_initialize'.tr;
      Get.snackbar('Error', 'failed_to_initialize'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _handleUserChange() {
    final user = storageService.getUser();
    if (user != null && currentUserId != user['email']) {
      currentUserId = user['email']?.toString();
      allUsers.clear();
      messages.clear();
      typingUsers.clear();
      selectedReceiverId.value = '';
      socketClient.disconnect();
      _initialize();
    } else if (user == null) {
      currentUserId = null;
      socketClient.disconnect();
      errorMessage.value = 'no_user'.tr;
      Get.offAllNamed(AppRoutes.getSignInPage());
    }
  }

  Future<void> fetchUsers({int retryCount = 0, int maxRetries = 3}) async {
    if (isLoadingUsers.value || currentUserId == null) return;
    final token = storageService.getToken();
    if (token == null) {
      print('ChatController: No token, redirecting to login');
      errorMessage.value = 'not_logged_in'.tr;
      Get.offAllNamed(AppRoutes.getSignInPage());
      return;
    }
    isLoadingUsers.value = true;
    try {
      final response = await apiService.getUsers();
      final users = (response as List<dynamic>).cast<Map<String, dynamic>>();
      allUsers.assignAll(users.where((Map<String, dynamic> u) {
        final email = u['email']?.toString() ?? '';
        return email != currentUserId && email.isNotEmpty;
      }).map((u) => {
            'email': u['email']?.toString() ?? '',
            'username': u['username']?.toString() ?? 'Unknown',
            'online': u['online'] as bool? ?? false,
            'profilePicture': u['profilePicture']?.toString() ?? '',
            'lastMessageTime': _getLatestMessageTime(u['email']?.toString() ?? ''),
          }).toList());
      _sortUsersByLastMessage();
      errorMessage.value = '';
      print('ChatController: Fetched ${allUsers.length} users');
    } catch (e) {
      print('ChatController: fetchUsers error: $e');
      if (e.toString().contains('Invalid token') && retryCount < maxRetries) {
        print('ChatController: Attempting token refresh');
        final refreshed = await apiService.refreshToken();
        if (refreshed) {
          await fetchUsers(retryCount: retryCount + 1, maxRetries: maxRetries);
        } else {
          print('ChatController: Token refresh failed, redirecting to login');
          storageService.clear();
          errorMessage.value = 'session_expired'.tr;
          Get.offAllNamed(AppRoutes.getSignInPage());
        }
      } else if (e.toString().contains('Server error') && retryCount < maxRetries) {
        print('ChatController: Server error, retrying ${retryCount + 1}/$maxRetries');
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        await fetchUsers(retryCount: retryCount + 1, maxRetries: maxRetries);
      } else {
        errorMessage.value = 'server_error'.tr;
        Get.snackbar('Error', 'server_error'.tr, snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoadingUsers.value = false;
    }
  }

  void connect() {
    final token = storageService.getToken();
    if (token == null || currentUserId == null) {
      print('ChatController: No token or userId, redirecting to login');
      errorMessage.value = 'not_logged_in'.tr;
      Get.offAllNamed(AppRoutes.getSignInPage());
      return;
    }
    socketClient.connect(
      currentUserId!,
      token,
      () {
        isConnected.value = true;
        errorMessage.value = '';
        syncLocalMessages();
        print('ChatController: Socket connected');
      },
      (data) {
        if (data['receiverId'] == currentUserId || data['senderId'] == currentUserId) {
          if (!messages.any((m) => m['messageId'] == data['messageId'])) {
            messages.add(data);
            saveLocalMessage(data);
            _updateUserLastMessageTime(data);
            print('ChatController: Received message: ${data['messageId']}');
          }
        }
      },
      (data) {
        if (data['senderId'] == currentUserId &&
            !messages.any((m) => m['messageId'] == data['messageId'])) {
          messages.add(data);
          saveLocalMessage(data);
          _updateUserLastMessageTime(data);
          print('ChatController: Message sent: ${data['messageId']}');
        }
      },
      (senderId) {
        if (senderId != currentUserId) {
          typingUsers.add(senderId);
          print('ChatController: Typing: $senderId');
        }
      },
      (senderId) {
        typingUsers.remove(senderId);
        print('ChatController: Stopped typing: $senderId');
      },
      (error) {
        errorMessage.value = error;
        isConnected.value = false;
        print('ChatController: Socket error: $error');
        Get.snackbar('Error', 'socket_error'.tr, snackPosition: SnackPosition.BOTTOM);
      },
      (newUser) {
        if (newUser['email'] != currentUserId &&
            newUser['email']?.toString().isNotEmpty == true &&
            !allUsers.any((u) => u['email'] == newUser['email'])) {
          allUsers.add({
            'email': newUser['email']?.toString() ?? '',
            'username': newUser['username']?.toString() ?? 'Unknown',
            'online': newUser['online'] as bool? ?? false,
            'profilePicture': newUser['profilePicture']?.toString() ?? '',
            'lastMessageTime': '',
          });
          _sortUsersByLastMessage();
          print('ChatController: Added new user: ${newUser['email']}');
        }
      },
      (email) {
        final user = allUsers.firstWhereOrNull((u) => u['email'] == email);
        if (user != null) {
          user['online'] = true;
          allUsers.refresh();
          print('ChatController: User online: $email');
        }
      },
      (email) {
        final user = allUsers.firstWhereOrNull((u) => u['email'] == email);
        if (user != null) {
          user['online'] = false;
          allUsers.refresh();
          print('ChatController: User offline: $email');
        }
      },
    );
  }

  Future<void> send(String text, String receiverId) async {
    if (text.trim().isEmpty || currentUserId == null) return;
    final isValidReceiver = allUsers.any((u) => u['email'] == receiverId);
    if (!isValidReceiver) {
      print('ChatController: Invalid receiverId: $receiverId');
      Get.snackbar('Error', 'invalid_receiver'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final messageId = Uuid().v4();
    final message = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': text,
      'messageId': messageId,
      'timestamp': DateTime.now().toIso8601String(),
      'delivered': false,
      'read': false,
    };
    if (!messages.any((m) => m['messageId'] == messageId)) {
      messages.add(message);
      await saveLocalMessage(message);
      _updateUserLastMessageTime(message);
      print('ChatController: Added message: $messageId to $receiverId');
    }
    if (isConnected.value && socketClient.socket?.connected == true) {
      socketClient.sendMessage(currentUserId!, receiverId, text, messageId);
    } else {
      await storeOfflineMessage(message);
      Get.snackbar('offline'.tr, 'message_stored_locally'.tr,
          backgroundColor: Colors.grey, colorText: Colors.white);
    }
  }

  void onTyping(String receiverId) {
    if (isConnected.value &&
        socketClient.socket?.connected == true &&
        receiverId.isNotEmpty &&
        allUsers.any((u) => u['email'] == receiverId && (u['online'] as bool? ?? false))) {
      socketClient.sendTyping(currentUserId!, receiverId);
    }
  }

  void onStopTyping(String receiverId) {
    if (isConnected.value &&
        socketClient.socket?.connected == true &&
        receiverId.isNotEmpty &&
        allUsers.any((u) => u['email'] == receiverId && (u['online'] as bool? ?? false))) {
      socketClient.sendStopTyping(currentUserId!, receiverId);
    }
  }

  Future<void> saveLocalMessage(Map<String, dynamic> message) async {
    if (currentUserId == null || message['messageId'] == null || message['messageId'].isEmpty) {
      print('ChatController: Skipped saving invalid message: $message');
      return;
    }
    final key = 'messages_${currentUserId!}';
    final stored = storageService.box.read(key) ?? <String>[];
    if (!stored.any((s) => jsonDecode(s)['messageId'] == message['messageId'])) {
      stored.add(jsonEncode(message));
      if (stored.length > 1000) stored.removeAt(0);
      await storageService.box.write(key, stored);
      print('ChatController: Saved message: ${message['messageId']}');
    }
  }

  Future<void> loadLocalMessages() async {
    if (currentUserId == null) {
      print('ChatController: No userId for loading messages');
      return;
    }
    try {
      final key = 'messages_${currentUserId!}';
      final stored = storageService.box.read(key) as List<dynamic>? ?? <String>[];
      final decodedMessages = stored.map<Map<String, dynamic>>((m) {
        try {
          final decoded = jsonDecode(m as String);
          return decoded is Map<String, dynamic> &&
                  decoded['messageId'] != null &&
                  decoded['senderId'] != null &&
                  decoded['receiverId'] != null
              ? decoded
              : <String, dynamic>{};
        } catch (e) {
          print('ChatController: Invalid stored message: $m, error: $e');
          return <String, dynamic>{};
        }
      }).where((m) => m.isNotEmpty).toList();
      messages.assignAll(decodedMessages);
      _updateAllUsersLastMessageTime();
      print('ChatController: Loaded ${decodedMessages.length} local messages');
    } catch (e) {
      print('ChatController: loadLocalMessages error: $e');
      errorMessage.value = 'failed_to_load_messages'.tr;
    }
  }

  Future<void> fetchMessagesFromBackend(String receiverId, {int retryCount = 0, int maxRetries = 3}) async {
    if (currentUserId == null || receiverId.isEmpty) {
      print('ChatController: Invalid fetch params: userId=$currentUserId, receiverId=$receiverId');
      return;
    }
    final token = storageService.getToken();
    if (token == null) {
      print('ChatController: No token, redirecting to login');
      Get.offAllNamed(AppRoutes.getSignInPage());
      return;
    }
    isLoadingMessages.value = true;
    try {
      final backendMessages = await apiService.getMessages(currentUserId!, receiverId);
      final newMessages = backendMessages.where((msg) => !messages.any((m) => m['messageId'] == msg['messageId'])).toList();
      if (newMessages.isEmpty && backendMessages.isEmpty) {
        messages.removeWhere((m) => m['receiverId'] == receiverId || m['senderId'] == receiverId);
        Get.snackbar('Info', 'No messages found', snackPosition: SnackPosition.BOTTOM);
      } else {
        messages.addAll(newMessages);
        for (var msg in newMessages) {
          await saveLocalMessage(msg);
        }
        _updateUserLastMessageTime({
          'senderId': newMessages.last['senderId'],
          'receiverId': newMessages.last['receiverId'],
          'timestamp': newMessages.last['timestamp'],
        });
      }
      errorMessage.value = '';
      print('ChatController: Fetched ${newMessages.length} new messages for $receiverId');
    } catch (e) {
      print('ChatController: fetchMessagesFromBackend error: $e');
      if (e.toString().contains('Invalid token') && retryCount < maxRetries) {
        print('ChatController: Attempting token refresh');
        final refreshed = await apiService.refreshToken();
        if (refreshed) {
          await fetchMessagesFromBackend(receiverId, retryCount: retryCount + 1, maxRetries: maxRetries);
        } else {
          print('ChatController: Token refresh failed, redirecting to login');
          storageService.clear();
          errorMessage.value = 'session_expired'.tr;
          Get.offAllNamed(AppRoutes.getSignInPage());
        }
      } else if (e.toString().contains('Server error') && retryCount < maxRetries) {
        print('ChatController: Server error, retrying ${retryCount + 1}/$maxRetries');
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        await fetchMessagesFromBackend(receiverId, retryCount: retryCount + 1, maxRetries: maxRetries);
      } else if (e.toString().contains('404')) {
        messages.removeWhere((m) => m['receiverId'] == receiverId || m['senderId'] == receiverId);
        Get.snackbar('Info', 'No messages found', snackPosition: SnackPosition.BOTTOM);
      } else {
        errorMessage.value = 'failed_to_load_messages'.tr;
        Get.snackbar('Error', 'failed_to_load_messages'.tr, snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> storeOfflineMessage(Map<String, dynamic> msg) async {
    if (currentUserId == null) {
      print('ChatController: No userId, cannot store offline message');
      return;
    }
    final offlineKey = 'offline_${currentUserId!}';
    final stored = storageService.box.read(offlineKey) ?? <String>[];
    stored.add(jsonEncode(msg));
    await storageService.box.write(offlineKey, stored);
    print('ChatController: Stored offline message: ${msg['messageId']}');
  }

  Future<void> syncLocalMessages() async {
    if (currentUserId == null || !isConnected.value || socketClient.socket?.connected != true) {
      print('ChatController: Cannot sync messages, not connected');
      return;
    }
    final offlineKey = 'offline_${currentUserId!}';
    final stored = storageService.box.read(offlineKey) ?? <String>[];
    for (var msgStr in List.from(stored)) {
      final msg = jsonDecode(msgStr) as Map<String, dynamic>;
      socketClient.sendMessage(msg['senderId'], msg['receiverId'], msg['message'], msg['messageId']);
      stored.remove(msgStr);
    }
    await storageService.box.write(offlineKey, stored);
    print('ChatController: Synced ${stored.length} offline messages');
  }

  int getUnseenMessageCount(String receiverId) {
    if (currentUserId == null || receiverId.isEmpty) {
      print('ChatController: Invalid unseen count params: userId=$currentUserId, receiverId=$receiverId');
      return 0;
    }
    final count = messages.where((msg) =>
        msg['senderId'] == receiverId &&
        msg['receiverId'] == currentUserId &&
        (msg['read'] as bool? ?? false) == false).length;
    print('ChatController: Unseen count for $receiverId: $count');
    return count;
  }

  void selectReceiver(String receiverId) async {
    if (receiverId.isEmpty || currentUserId == null) return;
    selectedReceiverId.value = receiverId;
    await fetchMessagesFromBackend(receiverId);
    final unreadMessages = messages
        .where((msg) =>
            msg['senderId'] == receiverId &&
            msg['receiverId'] == currentUserId &&
            (msg['read'] as bool? ?? false) == false)
        .toList();
    for (var msg in unreadMessages) {
      socketClient.markAsRead(msg['messageId']);
      msg['read'] = true;
      await saveLocalMessage(msg);
    }
    print('ChatController: Selected receiver: $receiverId');
  }

  void clearReceiver() {
    selectedReceiverId.value = '';
    typingUsers.clear();
    print('ChatController: Cleared receiver');
  }

  String _getLatestMessageTime(String userId) {
    if (currentUserId == null || userId.isEmpty) return '';
    final relatedMessages = messages.where((msg) =>
        (msg['senderId'] == currentUserId && msg['receiverId'] == userId) ||
        (msg['senderId'] == userId && msg['receiverId'] == currentUserId));
    if (relatedMessages.isEmpty) return '';
    final latestMessage = relatedMessages.reduce((a, b) {
      final aTime = _parseTimestamp(a['timestamp']);
      final bTime = _parseTimestamp(b['timestamp']);
      return aTime.isAfter(bTime) ? a : b;
    });
    return latestMessage['timestamp']?.toString() ?? '';
  }

  DateTime _parseTimestamp(String? timestamp) {
    try {
      return DateTime.parse(timestamp!);
    } catch (e) {
      print('ChatController: Invalid timestamp: $timestamp, error: $e');
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  void _sortUsersByLastMessage() {
    allUsers.sort((a, b) {
      final aTime = _parseTimestamp(a['lastMessageTime']);
      final bTime = _parseTimestamp(b['lastMessageTime']);
      if (aTime.isAtSameMomentAs(bTime)) return 0;
      return bTime.compareTo(aTime); // Most recent first
    });
    allUsers.refresh();
  }

  void _updateUserLastMessageTime(Map<String, dynamic> message) {
    final userId = message['senderId'] == currentUserId
        ? message['receiverId']
        : message['senderId'];
    final user = allUsers.firstWhereOrNull((u) => u['email'] == userId);
    if (user != null) {
      final currentTime = _parseTimestamp(user['lastMessageTime']);
      final messageTime = _parseTimestamp(message['timestamp']);
      if (messageTime.isAfter(currentTime)) {
        user['lastMessageTime'] = message['timestamp'];
        _sortUsersByLastMessage();
      }
    }
  }

  void _updateAllUsersLastMessageTime() {
    for (var user in allUsers) {
      user['lastMessageTime'] = _getLatestMessageTime(user['email']);
    }
    _sortUsersByLastMessage();
  }

  @override
  void onClose() {
    socketClient.disconnect();
    super.onClose();
    print('ChatController: Closed');
  }
}