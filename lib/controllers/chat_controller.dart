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
  bool _isConnecting = false;

  @override
  void onInit() {
    super.onInit();
    ever(storageService.user, (_) => _handleUserChange());
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final user = storageService.getUser();
      final token = storageService.getToken();
      if (user == null || token == null) {
        print('ChatController: No user or token, redirecting to login');
        errorMessage.value = 'not_logged_in'.tr;
        Get.offAllNamed(AppRoutes.getSignInPage());
        return;
      }
      currentUserId = user['email']?.toString();
      if (currentUserId == null || currentUserId!.isEmpty) {
        print('ChatController: Invalid user email');
        errorMessage.value = 'invalid_user'.tr;
        Get.offAllNamed(AppRoutes.getSignInPage());
        return;
      }
      print('ChatController: Initialized with userId: $currentUserId');
      await loadLocalMessages();
      await fetchUsers();
      await connect();
    } catch (e) {
      print('ChatController: Initialize error: $e');
      errorMessage.value = 'failed_to_initialize'.tr;
      Get.snackbar('Error', 'failed_to_initialize'.tr, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _handleUserChange() async {
    final user = storageService.getUser();
    if (user != null && currentUserId != user['email']) {
      print('ChatController: User changed to: ${user['email']}');
      currentUserId = user['email']?.toString();
      allUsers.clear();
      messages.clear();
      typingUsers.clear();
      selectedReceiverId.value = '';
      await socketClient.disconnect();
      await _initialize();
    } else if (user == null) {
      print('ChatController: No user, logging out');
      currentUserId = null;
      await socketClient.disconnect();
      allUsers.clear();
      messages.clear();
      typingUsers.clear();
      selectedReceiverId.value = '';
      errorMessage.value = 'no_user'.tr;
      Get.offAllNamed(AppRoutes.getSignInPage());
    }
  }

  Future<void> fetchUsers({int retryCount = 0, int maxRetries = 3}) async {
    if (isLoadingUsers.value || currentUserId == null) {
      print('ChatController: Skipping fetchUsers: loading=${isLoadingUsers.value}, userId=$currentUserId');
      return;
    }
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
      final users = (response).cast<Map<String, dynamic>>();
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
      } else if (retryCount < maxRetries) {
        print('ChatController: Retrying fetchUsers ${retryCount + 1}/$maxRetries');
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        await fetchUsers(retryCount: retryCount + 1, maxRetries: maxRetries);
      } else {
        errorMessage.value = 'failed_to_load_users'.tr;
        Get.snackbar('Error', 'failed_to_load_users'.tr, snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> connect() async {
    if (_isConnecting || isConnected.value) {
      print('ChatController: Skipping connect: connecting=$_isConnecting, connected=${isConnected.value}');
      return;
    }
    final token = storageService.getToken();
    if (token == null || currentUserId == null) {
      print('ChatController: No token or userId, redirecting to login');
      errorMessage.value = 'not_logged_in'.tr;
      Get.offAllNamed(AppRoutes.getSignInPage());
      return;
    }
    _isConnecting = true;
    try {
      await apiService.getUsers();
      print('ChatController: Token valid, proceeding with socket connection');
      await socketClient.disconnect();
      socketClient.connect(
        currentUserId!,
        token,
        () {
          isConnected.value = true;
          errorMessage.value = '';
          syncLocalMessages();
          fetchUsers();
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
        (error) async {
          errorMessage.value = error;
          isConnected.value = false;
          print('ChatController: Socket error: $error');
          if (error.contains('Invalid token')) {
            await _handleInvalidToken();
          } else {
            Get.snackbar('Error', 'socket_error'.tr, snackPosition: SnackPosition.BOTTOM);
            await Future.delayed(Duration(seconds: 5));
            if (!isConnected.value) {
              print('ChatController: Retrying socket connection');
              await connect();
            }
          }
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
    } catch (e) {
      print('ChatController: Connect error: $e');
      errorMessage.value = 'socket_connect_failed'.tr;
      Get.snackbar('Error', 'socket_connect_failed'.tr, snackPosition: SnackPosition.BOTTOM);
      await Future.delayed(Duration(seconds: 5));
      if (!isConnected.value) {
        print('ChatController: Retrying socket connection');
        await connect();
      }
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _handleInvalidToken() async {
    print('ChatController: Handling invalid token');
    final refreshed = await apiService.refreshToken();
    if (refreshed) {
      print('ChatController: Token refreshed, retrying connection');
      await connect();
    } else {
      print('ChatController: Token refresh failed, redirecting to login');
      storageService.clear();
      errorMessage.value = 'session_expired'.tr;
      Get.offAllNamed(AppRoutes.getSignInPage());
    }
  }

  Future<void> send(String text, String receiverId) async {
    if (text.trim().isEmpty || currentUserId == null) {
      print('ChatController: Empty text or no userId');
      return;
    }
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
    // Ensure no duplicates by messageId
    stored.removeWhere((s) {
      try {
        return jsonDecode(s)['messageId'] == message['messageId'];
      } catch (e) {
        return false;
      }
    });
    stored.add(jsonEncode(message));
    if (stored.length > 1000) stored.removeAt(0);
    await storageService.box.write(key, stored);
    print('ChatController: Saved message: ${message['messageId']}');
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
                  decoded['receiverId'] != null &&
                  decoded['message'] != null &&
                  decoded['timestamp'] != null
              ? decoded
              : <String, dynamic>{};
        } catch (e) {
          print('ChatController: Invalid stored message: $m, error: $e');
          return <String, dynamic>{};
        }
      }).where((m) => m.isNotEmpty).toList();
      // Deduplicate by messageId
      final uniqueMessages = <String, Map<String, dynamic>>{};
      for (var msg in decodedMessages) {
        uniqueMessages[msg['messageId']] = msg;
      }
      messages.assignAll(uniqueMessages.values);
      print('ChatController: Loaded ${uniqueMessages.length} local messages');
      _updateAllUsersLastMessageTime();
    } catch (e) {
      print('ChatController: loadLocalMessages error: $e');
      errorMessage.value = 'failed_to_load_messages'.tr;
    }
  }

  Future<void> fetchMessagesFromBackend(String receiverId, {int retryCount = 0, int maxRetries = 5}) async {
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
    final isValidReceiver = allUsers.any((u) => u['email'] == receiverId);
    if (!isValidReceiver) {
      print('ChatController: Invalid receiverId: $receiverId');
      errorMessage.value = 'invalid_receiver'.tr;
      Get.snackbar('Error', 'invalid_receiver'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoadingMessages.value = true;
    try {
      final backendMessages = await apiService.getMessages(currentUserId!, receiverId);
      print('ChatController: Received ${backendMessages.length} messages from backend');
      final existingMessages = Map<String, Map<String, dynamic>>.fromEntries(
        messages.where((m) => m['senderId'] == receiverId || m['receiverId'] == receiverId).map(
              (m) => MapEntry(m['messageId'], Map<String, dynamic>.from(m)),
            ),
      );
      final newMessages = backendMessages.where((msg) => !existingMessages.containsKey(msg['messageId'])).toList();
      // Update messages with backend data
      for (var msg in backendMessages) {
        existingMessages[msg['messageId']] = Map<String, dynamic>.from(msg);
      }
      // Update messages list
      messages.removeWhere((m) => m['senderId'] == receiverId || m['receiverId'] == receiverId);
      messages.addAll(existingMessages.values);
      print('ChatController: Updated messages list with ${existingMessages.length} messages for $receiverId');
      // Save new messages to local storage
      for (var msg in newMessages) {
        await saveLocalMessage(msg);
      }
      _updateUserLastMessageTime({
        'senderId': newMessages.isNotEmpty ? newMessages.last['senderId'] : currentUserId,
        'receiverId': receiverId,
        'timestamp': newMessages.isNotEmpty ? newMessages.last['timestamp'] : DateTime.now().toIso8601String(),
      });
      errorMessage.value = '';
      print('ChatController: Successfully fetched ${newMessages.length} new messages for $receiverId');
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
      } else if (retryCount < maxRetries && !e.toString().contains('ScrollController')) {
        print('ChatController: Retrying fetchMessages ${retryCount + 1}/$maxRetries');
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        await fetchMessagesFromBackend(receiverId, retryCount: retryCount + 1, maxRetries: maxRetries);
      } else {
        print('ChatController: Using local messages for $receiverId');
        errorMessage.value = 'failed_to_load_messages'.tr;
        await loadLocalMessages(); // Ensure local messages are reloaded
        Get.snackbar('Warning', 'showing_local_messages'.tr, snackPosition: SnackPosition.BOTTOM);
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
    if (!stored.any((s) => jsonDecode(s)['messageId'] == msg['messageId'])) {
      stored.add(jsonEncode(msg));
      await storageService.box.write(offlineKey, stored);
      print('ChatController: Stored offline message: ${msg['messageId']}');
    }
  }

  Future<void> syncLocalMessages() async {
    if (currentUserId == null || !isConnected.value || socketClient.socket?.connected != true) {
      print('ChatController: Cannot sync messages, not connected');
      return;
    }
    final offlineKey = 'offline_${currentUserId!}';
    final stored = storageService.box.read(offlineKey) ?? <String>[];
    final messagesToSend = List.from(stored);
    for (var msgStr in messagesToSend) {
      try {
        final msg = jsonDecode(msgStr) as Map<String, dynamic>;
        if (!messages.any((m) => m['messageId'] == msg['messageId']) ||
            messages.firstWhere((m) => m['messageId'] == msg['messageId'])['delivered'] == false) {
          socketClient.sendMessage(msg['senderId'], msg['receiverId'], msg['message'], msg['messageId']);
          print('ChatController: Sent offline message: ${msg['messageId']}');
        }
        stored.remove(msgStr);
      } catch (e) {
        print('ChatController: Error syncing message: $msgStr, error: $e');
      }
    }
    await storageService.box.write(offlineKey, stored);
    print('ChatController: Synced ${messagesToSend.length} offline messages');
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
    if (receiverId.isEmpty || currentUserId == null) {
      print('ChatController: Invalid selectReceiver: receiverId=$receiverId, userId=$currentUserId');
      return;
    }
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
    print('ChatController: Selected receiver: $receiverId, messages: ${messages.length}');
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
      return bTime.compareTo(aTime);
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