import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../services/socket_client.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../routes/app_routes.dart';

class ChatController extends GetxController {
  final SocketClient socketClient = SocketClient();
  final StorageService storageService = Get.find<StorageService>();
  final ApiService apiService = Get.find<ApiService>();
  String? currentUserId;
  final messages = <Map<String, dynamic>>[].obs;
  final allUsers = <Map<String, dynamic>>[].obs;
  final filteredUsers = <Map<String, dynamic>>[].obs;
  final userListItems = <Map<String, dynamic>>[].obs; // Computed list for UI
  final typingUsers = <String>{}.obs;
  final isConnected = false.obs;
  final errorMessage = ''.obs;
  final selectedReceiverId = ''.obs;
  final isLoadingUsers = false.obs;
  final isLoadingMessages = false.obs;
  final searchController = TextEditingController();
  Timer? _searchDebounceTimer;
  bool _isConnecting = false;

  @override
  void onInit() {
    super.onInit();
    ever(storageService.user, (_) => _handleUserChange());
    ever(allUsers, (_) => _updateUserListItems());
    ever(messages, (_) => _updateUserListItems());
    ever(typingUsers, (_) => _updateUserListItems());
    ever(filteredUsers, (_) => _updateUserListItems());

    // Debounce search input
    searchController.addListener(() {
      _searchDebounceTimer?.cancel();
      _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        final query = searchController.text.trim().toLowerCase();
        filteredUsers.value = query.isEmpty
            ? allUsers
            : allUsers
                .where((user) => user['username']?.toString().toLowerCase().contains(query) ?? false)
                .toList();
      });
    });

    _initialize();
  }

  @override
  void onClose() {
    socketClient.disconnect();
    _searchDebounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
    print('ChatController: Closed');
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
      await loadLocalData();
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
      filteredUsers.clear();
      userListItems.clear();
      messages.clear();
      typingUsers.clear();
      selectedReceiverId.value = '';
      searchController.clear();
      await socketClient.disconnect();
      await _initialize();
    } else if (user == null) {
      print('ChatController: No user, logging out');
      currentUserId = null;
      await socketClient.disconnect();
      allUsers.clear();
      filteredUsers.clear();
      userListItems.clear();
      messages.clear();
      typingUsers.clear();
      selectedReceiverId.value = '';
      searchController.clear();
      errorMessage.value = 'no_user'.tr;
      Get.offAllNamed(AppRoutes.getSignInPage());
    }
  }

  Future<void> loadLocalData() async {
    if (currentUserId == null) {
      print('ChatController: No userId for loading local data');
      return;
    }
    try {
      final storedUsers = storageService.getUsers(currentUserId!);
      if (storedUsers.isNotEmpty) {
        allUsers.assignAll(storedUsers);
        filteredUsers.assignAll(storedUsers);
        _sortUsersByLastMessage();
        print('ChatController: Loaded ${allUsers.length} users from storage');
      }
      final uniqueReceivers = allUsers.map((u) => u['email']?.toString()).where((e) => e != null).toSet();
      final loadedMessages = <Map<String, dynamic>>[];
      for (var receiverId in uniqueReceivers) {
        final userMessages = storageService.getMessagesForUser(currentUserId!, receiverId!);
        final validMessages = userMessages.where((msg) {
          final timestamp = msg['timestamp']?.toString();
          if (timestamp == null || timestamp.isEmpty) {
            print('ChatController: Discarding message with invalid timestamp: $msg');
            return false;
          }
          return true;
        }).toList();
        loadedMessages.addAll(validMessages);
      }
      final uniqueMessages = <String, Map<String, dynamic>>{};
      for (var msg in loadedMessages) {
        if (msg['messageId'] != null) {
          if (msg['timestamp'] == null || msg['timestamp'].toString().isEmpty) {
            msg['timestamp'] = DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();
          }
          uniqueMessages[msg['messageId']] = msg;
        }
      }
      messages.assignAll(uniqueMessages.values);
      print('ChatController: Loaded ${uniqueMessages.length} messages from storage');
      _updateAllUsersLastMessageTime();
      messages.refresh();
    } catch (e) {
      print('ChatController: loadLocalData error: $e');
      errorMessage.value = 'failed_to_load_local_data'.tr;
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
      final users = response.cast<Map<String, dynamic>>();
      final newUsers = users
          .where((u) {
            final email = u['email']?.toString() ?? '';
            return email != currentUserId && email.isNotEmpty;
          })
          .map((u) => {
                'email': u['email']?.toString() ?? '',
                'username': u['username']?.toString() ?? 'Unknown',
                'online': u['online'] as bool? ?? false,
                'profilePicture': u['profilePicture']?.toString() ?? '',
                'lastMessageTime': _getLatestMessageTime(u['email']?.toString() ?? ''),
              })
          .toList();

      bool hasChanges = false;
      if (newUsers.length != allUsers.length) {
        hasChanges = true;
      } else {
        for (int i = 0; i < newUsers.length; i++) {
          final newUser = newUsers[i];
          final oldUser = allUsers[i];
          if (newUser['email'] != oldUser['email'] ||
              newUser['username'] != oldUser['username'] ||
              newUser['online'] != oldUser['online'] ||
              newUser['profilePicture'] != oldUser['profilePicture'] ||
              newUser['lastMessageTime'] != oldUser['lastMessageTime']) {
            hasChanges = true;
            break;
          }
        }
      }

      if (hasChanges) {
        allUsers.assignAll(newUsers);
        final query = searchController.text.trim().toLowerCase();
        filteredUsers.value = query.isEmpty
            ? newUsers
            : newUsers
                .where((user) => user['username']?.toString().toLowerCase().contains(query) ?? false)
                .toList();
        await storageService.saveUsers(currentUserId!, newUsers);
        _sortUsersByLastMessage();
        print('ChatController: Fetched and saved ${allUsers.length} users');
      } else {
        print('ChatController: No changes in users, skipping update');
      }
      errorMessage.value = '';
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
        final storedUsers = storageService.getUsers(currentUserId!);
        if (storedUsers.isNotEmpty) {
          allUsers.assignAll(storedUsers);
          filteredUsers.assignAll(storedUsers);
          _sortUsersByLastMessage();
          print('ChatController: Loaded ${allUsers.length} users from storage as fallback');
        }
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
              data['timestamp'] ??= DateTime.now().toIso8601String();
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
            data['timestamp'] ??= DateTime.now().toIso8601String();
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
            storageService.saveUsers(currentUserId!, allUsers);
            _sortUsersByLastMessage();
            print('ChatController: Added new user: ${newUser['email']}');
          }
        },
        (email) {
          final user = allUsers.firstWhereOrNull((u) => u['email'] == email);
          if (user != null && user['online'] != true) {
            user['online'] = true;
            allUsers.refresh();
            storageService.saveUsers(currentUserId!, allUsers);
            print('ChatController: User online: $email');
          }
        },
        (email) {
          final user = allUsers.firstWhereOrNull((u) => u['email'] == email);
          if (user != null && user['online'] != false) {
            user['online'] = false;
            allUsers.refresh();
            storageService.saveUsers(currentUserId!, allUsers);
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
      await storageService.saveMessagesForUser(
        currentUserId!,
        receiverId,
        messages
            .where((m) =>
                m['senderId'] == currentUserId && m['receiverId'] == receiverId ||
                m['senderId'] == receiverId && m['receiverId'] == currentUserId)
            .toList(),
      );
      _updateUserLastMessageTime(message);
      messages.refresh();
      print('ChatController: Added and saved message: $messageId to $receiverId');
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
    if (message['timestamp'] == null || message['timestamp'].toString().isEmpty) {
      message['timestamp'] = DateTime.now().toIso8601String();
      print('ChatController: Added missing timestamp to message: ${message['messageId']}');
    }
    final receiverId =
        message['senderId'] == currentUserId ? message['receiverId'] : message['senderId'];
    final relatedMessages = messages
        .where((m) =>
            m['senderId'] == currentUserId && m['receiverId'] == receiverId ||
            m['senderId'] == receiverId && m['receiverId'] == currentUserId)
        .toList();
    if (!relatedMessages.any((m) => m['messageId'] == message['messageId'])) {
      relatedMessages.add(message);
    }
    await storageService.saveMessagesForUser(currentUserId!, receiverId, relatedMessages);
    print('ChatController: Saved message: ${message['messageId']} for $receiverId');
  }

  Future<void> loadLocalMessages() async {
    if (currentUserId == null) {
      print('ChatController: No userId for loading messages');
      return;
    }
    try {
      final uniqueReceivers = allUsers.map((u) => u['email']?.toString()).where((e) => e != null).toSet();
      final loadedMessages = <Map<String, dynamic>>[];
      for (var receiverId in uniqueReceivers) {
        final userMessages = storageService.getMessagesForUser(currentUserId!, receiverId!);
        final validMessages = userMessages.where((msg) {
          final timestamp = msg['timestamp']?.toString();
          if (timestamp == null || timestamp.isEmpty) {
            print('ChatController: Discarding message with invalid timestamp: $msg');
            return false;
          }
          return true;
        }).toList();
        loadedMessages.addAll(validMessages);
      }
      final uniqueMessages = <String, Map<String, dynamic>>{};
      for (var msg in loadedMessages) {
        if (msg['messageId'] != null) {
          if (msg['timestamp'] == null || msg['timestamp'].toString().isEmpty) {
            msg['timestamp'] = DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();
          }
          uniqueMessages[msg['messageId']] = msg;
        }
      }
      messages.assignAll(uniqueMessages.values);
      print('ChatController: Loaded ${uniqueMessages.length} local messages');
      _updateAllUsersLastMessageTime();
      messages.refresh();
    } catch (e) {
      print('ChatController: loadLocalMessages error: $e');
      errorMessage.value = 'failed_to_load_messages'.tr;
    }
  }

  Future<void> fetchMessagesFromBackend(String receiverId,
      {int retryCount = 0, int maxRetries = 5}) async {
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
      print('ChatController: Received ${backendMessages.length} messages from backend: $backendMessages');
      final existingMessages = Map<String, Map<String, dynamic>>.fromEntries(
        messages.map((m) => MapEntry(m['messageId'], Map<String, dynamic>.from(m))),
      );
      for (var msg in backendMessages) {
        if (msg['senderId'] != null && msg['receiverId'] != null) {
          if (msg['timestamp'] == null || msg['timestamp'].toString().isEmpty) {
            msg['timestamp'] = DateTime.now().toIso8601String();
            print('ChatController: Added missing timestamp to backend message: ${msg['messageId']}');
          }
          existingMessages[msg['messageId']] = {
            'senderId': msg['senderId'].toString(),
            'receiverId': msg['receiverId'].toString(),
            'message': msg['message']?.toString() ?? '',
            'messageId': msg['messageId']?.toString() ?? Uuid().v4(),
            'timestamp': msg['timestamp'].toString(),
            'delivered': msg['delivered'] as bool? ?? false,
            'read': msg['read'] as bool? ?? false,
          };
        }
      }
      messages.assignAll(existingMessages.values);
      await storageService.saveMessagesForUser(currentUserId!, receiverId, existingMessages.values.toList());
      _updateUserLastMessageTime({
        'senderId': backendMessages.isNotEmpty ? backendMessages.last['senderId'] : currentUserId,
        'receiverId': receiverId,
        'timestamp': backendMessages.isNotEmpty
            ? backendMessages.last['timestamp']
            : DateTime.now().toIso8601String(),
      });
      errorMessage.value = '';
      print('ChatController: Updated and saved ${existingMessages.length} messages for $receiverId');
      messages.refresh();
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
      } else if (retryCount < maxRetries) {
        print('ChatController: Retrying fetchMessages ${retryCount + 1}/$maxRetries');
        await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
        await fetchMessagesFromBackend(receiverId, retryCount: retryCount + 1, maxRetries: maxRetries);
      } else {
        print('ChatController: Using local messages for $receiverId');
        errorMessage.value = 'failed_to_load_messages'.tr;
        final localMessages = storageService.getMessagesForUser(currentUserId!, receiverId);
        if (localMessages.isNotEmpty) {
          final uniqueMessages = <String, Map<String, dynamic>>{};
          for (var msg in localMessages) {
            if (msg['messageId'] != null) {
              if (msg['timestamp'] == null || msg['timestamp'].toString().isEmpty) {
                msg['timestamp'] = DateTime.fromMillisecondsSinceEpoch(0).toIso8601String();
              }
              uniqueMessages[msg['messageId']] = msg;
            }
          }
          messages.assignAll(uniqueMessages.values);
          print('ChatController: Loaded ${uniqueMessages.length} local messages for $receiverId as fallback');
        }
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
    if (msg['timestamp'] == null || msg['timestamp'].toString().isEmpty) {
      msg['timestamp'] = DateTime.now().toIso8601String();
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
    final count = messages
        .where((msg) =>
            msg['senderId'] == receiverId &&
            msg['receiverId'] == currentUserId &&
            (msg['read'] as bool? ?? false) == false)
        .length;
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
    messages.refresh();
  }

    void clearReceiver() {
        selectedReceiverId.value = '';
        // Avoid clearing typingUsers immediately to prevent rebuild during dispose
        if (typingUsers.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            typingUsers.clear();
            print('ChatController: Cleared typingUsers after frame');
          });
        }
        print('ChatController: Cleared receiver');
      }

  void _updateUserListItems() {
    final items = filteredUsers.map((user) {
      final unseenCount = getUnseenMessageCount(user['email']);
      final isTyping = typingUsers.contains(user['email']);
      final lastMessageData = _getLastMessageData(user['email']);
      return {
        'user': user,
        'unseenCount': unseenCount,
        'isTyping': isTyping,
        'lastMessage': lastMessageData['message'] ?? '',
        'timestamp': lastMessageData['timestamp'] ?? '',
        'isSentByUser': lastMessageData['senderId'] == currentUserId,
        'isDelivered': lastMessageData['delivered'] == true,
        'isRead': lastMessageData['read'] == true,
      };
    }).toList();
    userListItems.assignAll(items);
  }

  Map<String, dynamic> _getLastMessageData(String userEmail) {
    if (currentUserId == null) {
      return {'message': '', 'timestamp': '', 'senderId': '', 'delivered': false, 'read': false};
    }
    final relatedMessages = messages.where(
      (msg) =>
          (msg['senderId'] == currentUserId && msg['receiverId'] == userEmail) ||
          (msg['senderId'] == userEmail && msg['receiverId'] == currentUserId),
    );
    if (relatedMessages.isEmpty) {
      return {'message': '', 'timestamp': '', 'senderId': '', 'delivered': false, 'read': false};
    }
    final latestMessage = relatedMessages.reduce((a, b) {
      final aTime = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return aTime.isAfter(bTime) ? a : b;
    });
    return {
      'message': latestMessage['message']?.toString() ?? '',
      'timestamp': latestMessage['timestamp']?.toString() ?? '',
      'senderId': latestMessage['senderId']?.toString() ?? '',
      'delivered': latestMessage['delivered'] as bool? ?? false,
      'read': latestMessage['read'] as bool? ?? false,
    };
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
    if (timestamp == null || timestamp.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    try {
      return DateTime.parse(timestamp);
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
    final userId =
        message['senderId'] == currentUserId ? message['receiverId'] : message['senderId'];
    final user = allUsers.firstWhereOrNull((u) => u['email'] == userId);
    if (user != null) {
      final currentTime = _parseTimestamp(user['lastMessageTime']);
      final messageTime = _parseTimestamp(message['timestamp']);
      if (messageTime.isAfter(currentTime)) {
        user['lastMessageTime'] = message['timestamp']?.toString() ?? '';
        _sortUsersByLastMessage();
        storageService.saveUsers(currentUserId!, allUsers);
      }
    }
  }

  void _updateAllUsersLastMessageTime() {
    for (var user in allUsers) {
      user['lastMessageTime'] = _getLatestMessageTime(user['email']);
    }
    _sortUsersByLastMessage();
    if (currentUserId != null) {
      storageService.saveUsers(currentUserId!, allUsers);
    }
  }
}