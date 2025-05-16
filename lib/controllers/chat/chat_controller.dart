import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../services/socket_client.dart';
import '../../services/storage_service.dart';
import '../../services/api_service.dart';
import '../../routes/app_routes.dart';

class ChatController extends GetxController {
  final SocketClient socketClient = SocketClient();
  final StorageService storageService = Get.find<StorageService>();
  final ApiService apiService = Get.find<ApiService>();

  final currentUserId = RxnString();
  final messages = <String, Map<String, dynamic>>{}.obs;
  final allUsers = <Map<String, dynamic>>[].obs;
  final filteredUsers = <Map<String, dynamic>>[].obs;
  final typingUsers = <String>{}.obs;
  final isConnected = false.obs;
  final hasInternet = true.obs;
  final serverAvailable = true.obs;
  final errorMessage = ''.obs;
  final selectedReceiverId = ''.obs;
  final isLoadingUsers = false.obs;
  final isLoadingMessages = false.obs;
  final searchController = TextEditingController();
  final unseenNotifications = <String, List<Map<String, dynamic>>>{}.obs;

  Timer? _searchDebounceTimer;
  Timer? _connectivityCheckTimer;
  bool _isConnecting = false;
  bool _disposed = false;
  static const _maxRetries = 3;
  static const _baseRetryDelay = Duration(seconds: 2);
  static const _connectivityCheckInterval = Duration(seconds: 5);
  static const _reconnectDelay = Duration(seconds: 10);

  @override
  void onInit() {
    super.onInit();
    ever(storageService.user, (_) => _handleUserChange());
    searchController.addListener(debounceSearch);
    _initialize();
    _startConnectivityCheck();
  }

  @override
  void onClose() {
    _disposed = true;
    socketClient.disconnect();
    _searchDebounceTimer?.cancel();
    _connectivityCheckTimer?.cancel();
    _searchDebounceTimer = null;
    _connectivityCheckTimer = null;
    searchController.removeListener(debounceSearch);
    searchController.dispose();
    super.onClose();
    print('ChatController: Closed');
  }

  // Compute total unseen message count for chat tab badge
  int get totalUnseenMessageCount {
    return unseenNotifications.entries.fold(0, (sum, entry) => sum + entry.value.length);
  }

  Future<void> _initialize() async {
    try {
      final user = storageService.getUser();
      final token = storageService.getToken();
      if (user == null || token == null || user['email']?.toString().isEmpty == true) {
        print('ChatController: No user or token, redirecting to login');
        errorMessage.value = 'not_logged_in'.tr;
        Get.offAllNamed(AppRoutes.getSignInPage());
        return;
      }
      currentUserId.value = user['email']?.toString();
      print('ChatController: Initialized with userId: ${currentUserId.value}');
      await loadLocalData();
      await fetchUsers();
      await connect();
    } catch (e) {
      print('ChatController: Initialize error: $e');
      errorMessage.value = 'failed_to_initialize'.tr;
    }
  }

  Future<void> _startConnectivityCheck() async {
    _connectivityCheckTimer = Timer.periodic(_connectivityCheckInterval, (timer) async {
      if (_disposed) {
        timer.cancel();
        return;
      }
      await _checkConnectivity();
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      await apiService.user.getUsers();
      if (!hasInternet.value || !serverAvailable.value) {
        hasInternet.value = true;
        serverAvailable.value = true;
        print('ChatController: Internet and server restored');
        if (!isConnected.value) {
          await connect();
        }
        await fetchUsers();
      }
    } catch (e) {
      if (e.toString().contains('DioError') || e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        if (hasInternet.value) {
          hasInternet.value = false;
          serverAvailable.value = false;
          print('ChatController: Network failure: $e');
        }
      } else if (e.toString().contains('Invalid token')) {
        print('ChatController: Invalid token: $e');
        await _handleInvalidToken();
      } else {
        if (serverAvailable.value) {
          serverAvailable.value = false;
          print('ChatController: Server error: $e');
        }
      }
    }
  }

  Future<void> _handleUserChange() async {
    final user = storageService.getUser();
    if (user == null) {
      print('ChatController: No user, logging out');
      await _resetState();
      errorMessage.value = 'no_user'.tr;
      Get.offAllNamed(AppRoutes.getSignInPage());
    } else if (currentUserId.value != user['email']) {
      print('ChatController: User changed to: ${user['email']}');
      await _resetState();
      await _initialize();
    }
  }

  Future<void> _resetState() async {
    currentUserId.value = null;
    await socketClient.disconnect();
    messages.clear();
    allUsers.clear();
    filteredUsers.clear();
    typingUsers.clear();
    unseenNotifications.clear();
    selectedReceiverId.value = '';
    errorMessage.value = '';
    isConnected.value = false;
    hasInternet.value = true;
    serverAvailable.value = true;
  }

  Future<void> loadLocalData() async {
    if (currentUserId.value == null) {
      print('ChatController: No userId for loading local data');
      return;
    }
    try {
      final storedUsers = storageService.getUsers(currentUserId.value!);
      if (storedUsers.isNotEmpty) {
        allUsers.assignAll(storedUsers);
        filteredUsers.assignAll(storedUsers);
        print('ChatController: Loaded ${allUsers.length} users from storage');
      }
      await _loadLocalMessages();
      _loadUnseenNotifications();
      _refreshUserList();
    } catch (e) {
      print('ChatController: loadLocalData error: $e');
      errorMessage.value = 'failed_to_load_local_data'.tr;
    }
  }

  Future<void> _loadLocalMessages() async {
    final uniqueReceivers = allUsers.map((u) => u['email'] as String?).whereType<String>().toSet();
    final loadedMessages = <String, Map<String, dynamic>>{};
    for (var receiverId in uniqueReceivers) {
      final userMessages = storageService.getMessagesForUser(currentUserId.value!, receiverId);
      for (var msg in userMessages) {
        if (_isValidMessage(msg)) {
          loadedMessages[msg['messageId']] = _normalizeMessage(msg);
        }
      }
    }
    messages.assignAll(loadedMessages);
    _updateAllUsersLastMessageTime();
    print('ChatController: Loaded ${loadedMessages.length} messages from storage');
  }

  void _loadUnseenNotifications() {
    final notificationsKey = 'unseen_notifications_${currentUserId.value}';
    final storedNotifications = storageService.box.read(notificationsKey) ?? <String, List<dynamic>>{};
    unseenNotifications.clear();
    storedNotifications.forEach((receiverId, messages) {
      unseenNotifications[receiverId] = (messages as List).cast<Map<String, dynamic>>().map(_normalizeMessage).toList();
    });
    print('ChatController: Loaded unseen notifications for ${unseenNotifications.length} users');
    _refreshUserList();
  }

  Future<void> saveUnseenNotifications() async {
    final notificationsKey = 'unseen_notifications_${currentUserId.value}';
    await storageService.box.write(notificationsKey, unseenNotifications);
    print('ChatController: Saved unseen notifications for ${unseenNotifications.length} users');
    _refreshUserList();
  }

  Future<void> fetchUsers({int retryCount = 0}) async {
    if (isLoadingUsers.value || currentUserId.value == null) {
      print('ChatController: Skipping fetchUsers: loading=${isLoadingUsers.value}, userId=${currentUserId.value}');
      return;
    }
    if (!hasInternet.value || !serverAvailable.value) {
      print('ChatController: No internet or server unavailable, skipping fetchUsers');
      return;
    }
    isLoadingUsers.value = true;
    try {
      final response = await apiService.user.getUsers();
      final newUsers = response
          .cast<Map<String, dynamic>>()
          .where((u) => u['email']?.toString() != currentUserId.value && u['email']?.toString().isNotEmpty == true)
          .map((u) => _normalizeUser(u))
          .toList();

      final updatedUsers = <Map<String, dynamic>>[];
      for (var newUser in newUsers) {
        final existingUser = allUsers.firstWhereOrNull((u) => u['email'] == newUser['email']);
        if (existingUser != null) {
          updatedUsers.add({
            ...newUser,
            'lastMessageTime': existingUser['lastMessageTime'] ?? newUser['lastMessageTime'],
          });
        } else {
          updatedUsers.add(newUser);
        }
      }
      allUsers.assignAll(updatedUsers);
      _updateFilteredUsers();
      await storageService.saveUsers(currentUserId.value!, allUsers);
      print('ChatController: Fetched and saved ${allUsers.length} users');

      for (var user in allUsers) {
        final receiverId = user['email'] as String;
        await fetchMessagesFromBackend(receiverId);
      }
      errorMessage.value = '';
    } catch (e) {
      await _handleFetchError(e, retryCount, () => fetchUsers(retryCount: retryCount + 1));
    } finally {
      isLoadingUsers.value = false;
    }
  }

  Future<void> connect() async {
    if (_isConnecting || isConnected.value || currentUserId.value == null) {
      return _logSkipConnect();
    }
    final token = storageService.getToken();
    if (token == null || token.isEmpty) {
      print('ChatController: No token, redirecting to login');
      errorMessage.value = 'not_logged_in'.tr;
      Get.offAllNamed(AppRoutes.getSignInPage());
      return;
    }
    if (!hasInternet.value || !serverAvailable.value) {
      print('ChatController: No internet or server unavailable, skipping socket connect');
      return;
    }
    _isConnecting = true;
    try {
      await socketClient.disconnect();
      socketClient.connect(
        currentUserId.value!,
        token,
        () {
          isConnected.value = true;
          errorMessage.value = '';
          syncLocalMessages();
          fetchUsers();
          print('ChatController: Socket connected');
        },
        _handleReceivedMessage,
        _handleSentMessage,
        (senderId) => _handleTyping(senderId, true),
        (senderId) => _handleTyping(senderId, false),
        _handleSocketError,
        _handleNewUser,
        (email) => _updateUserStatus(email, true),
        (email) => _updateUserStatus(email, false),
        onMessageDelivered: _handleMessageDelivered,
        onMessageRead: _handleMessageRead,
      );
    } catch (e) {
      await _handleSocketConnectError(e);
    } finally {
      _isConnecting = false;
    }
  }

  void _logSkipConnect() {
    print(
        'ChatController: Skipping connect: connecting=$_isConnecting, connected=${isConnected.value}, userId=${currentUserId.value}');
  }

  Future<void> send(String text, String receiverId) async {
    if (text.trim().isEmpty || currentUserId.value == null) {
      print('ChatController: Empty text or no userId');
      return;
    }
    if (!_isValidReceiver(receiverId)) {
      print('ChatController: Invalid receiverId: $receiverId');
      Get.snackbar(
        'error'.tr,
        'invalid_receiver'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    final message = _createMessage(text, receiverId);
    await _addMessage(message);
    if (isConnected.value && socketClient.socket?.connected == true) {
      socketClient.sendMessage(currentUserId.value!, receiverId, text, message['messageId']);
    } else {
      await storeOfflineMessage(message);
    }
  }

  Future<void> fetchMessagesFromBackend(String receiverId, {int retryCount = 0}) async {
    if (currentUserId.value == null || receiverId.isEmpty || !_isValidReceiver(receiverId)) {
      print('ChatController: Invalid fetch params: userId=${currentUserId.value}, receiverId=$receiverId');
      errorMessage.value = 'invalid_receiver'.tr;
      Get.snackbar(
        'error'.tr,
        'invalid_receiver'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    if (!hasInternet.value || !serverAvailable.value) {
      print('ChatController: No internet or server unavailable, skipping fetchMessagesFromBackend');
      return;
    }
    isLoadingMessages.value = true;
    try {
      final backendMessages = await apiService.message.getMessages(currentUserId.value!, receiverId);
      final newMessages = backendMessages.map(_normalizeMessage).toList();
      await _mergeMessages(newMessages, receiverId);
      errorMessage.value = '';
      print('ChatController: Fetched and merged ${newMessages.length} messages for $receiverId');
    } catch (e) {
      await _handleFetchError(e, retryCount, () => fetchMessagesFromBackend(receiverId, retryCount: retryCount + 1));
    } finally {
      isLoadingMessages.value = false;
    }
  }

  Future<void> storeOfflineMessage(Map<String, dynamic> msg) async {
    if (currentUserId.value == null) {
      print('ChatController: No userId, cannot store offline message');
      return;
    }
    final offlineKey = 'offline_${currentUserId.value}';
    final stored = storageService.box.read(offlineKey) ?? <String>[];
    if (!stored.any((s) => jsonDecode(s)['messageId'] == msg['messageId'])) {
      stored.add(jsonEncode(msg));
      await storageService.box.write(offlineKey, stored);
      print('ChatController: Stored offline message: ${msg['messageId']}');
    }
  }

  Future<void> syncLocalMessages() async {
    if (currentUserId.value == null || !isConnected.value) {
      print('ChatController: Cannot sync messages, not connected');
      return;
    }
    final offlineKey = 'offline_${currentUserId.value}';
    final stored = List<String>.from(storageService.box.read(offlineKey) ?? []);
    for (var msgStr in stored) {
      try {
        final msg = jsonDecode(msgStr) as Map<String, dynamic>;
        if (!_isValidMessage(msg) || messages.containsKey(msg['messageId']) && messages[msg['messageId']]!['delivered'] == true) {
          continue;
        }
        socketClient.sendMessage(msg['senderId'], msg['receiverId'], msg['message'], msg['messageId']);
        print('ChatController: Sent offline message: ${msg['messageId']}');
      } catch (e) {
        print('ChatController: Error syncing message: $msgStr, error: $e');
      }
    }
    await storageService.box.write(offlineKey, []);
    print('ChatController: Synced ${stored.length} offline messages');
  }

  Future<void> saveMessagesForUser(String receiverId) async {
    final relatedMessages = messages.values
        .where((m) =>
            (m['senderId'] == currentUserId.value && m['receiverId'] == receiverId) ||
            (m['senderId'] == receiverId && m['receiverId'] == currentUserId.value))
        .toList();
    await storageService.saveMessagesForUser(currentUserId.value!, receiverId, relatedMessages);
    print('ChatController: Saved ${relatedMessages.length} messages for $receiverId');
  }

  void selectReceiver(String receiverId) async {
    if (receiverId.isEmpty || currentUserId.value == null) {
      print('ChatController: Invalid selectReceiver: receiverId=$receiverId, userId=${currentUserId.value}');
      return;
    }
    selectedReceiverId.value = receiverId;
    await fetchMessagesFromBackend(receiverId);
    // Mark unseen messages as read when viewing the chat
    if (unseenNotifications.containsKey(receiverId)) {
      for (var msg in unseenNotifications[receiverId]!) {
        if (msg['receiverId'] == currentUserId.value && !msg['read']) {
          socketClient.markAsRead(msg['messageId']);
          messages[msg['messageId']] = {
            ...messages[msg['messageId']]!,
            'delivered': true,
            'read': true,
          };
        }
      }
      unseenNotifications.remove(receiverId);
      await saveUnseenNotifications();
      await saveMessagesForUser(receiverId);
      _refreshUserList();
    }
    print('ChatController: Selected receiver: $receiverId, messages: ${messages.length}');
  }

  void clearReceiver() {
    selectedReceiverId.value = '';
    typingUsers.clear();
    print('ChatController: Cleared receiver');
  }

  void onTyping(String receiverId) {
    if (isConnected.value && _isValidReceiver(receiverId) && _isUserOnline(receiverId)) {
      socketClient.sendTyping(currentUserId.value!, receiverId);
    }
  }

  void onStopTyping(String receiverId) {
    if (isConnected.value && _isValidReceiver(receiverId) && _isUserOnline(receiverId)) {
      socketClient.sendStopTyping(currentUserId.value!, receiverId);
    }
  }

  int getUnseenMessageCount(String receiverId) {
    return unseenNotifications[receiverId]?.length ?? 0;
  }

  List<Map<String, dynamic>> get userListItems {
    return filteredUsers.map((user) {
      final email = user['email'] as String;
      final lastMessageData = _getLastMessageData(email);
      print('ChatController: userListItems for $email, timestamp: ${lastMessageData['timestamp']}');
      return {
        'user': user,
        'unseenCount': getUnseenMessageCount(email),
        'isTyping': typingUsers.contains(email),
        'lastMessage': lastMessageData['message'] ?? '',
        'timestamp': lastMessageData['timestamp'] ?? '',
        'isSentByUser': lastMessageData['senderId'] == currentUserId.value,
        'isDelivered': lastMessageData['delivered'] == true,
        'isRead': lastMessageData['read'] == true,
      };
    }).toList();
  }
  
  Map<String, dynamic> _normalizeUser(Map<String, dynamic> u) {
    return {
      'email': u['email']?.toString() ?? '',
      'username': u['username']?.toString() ?? 'Unknown',
      'online': u['online'] as bool? ?? false,
      'profilePicture': u['profilePicture']?.toString() ?? '',
      'lastMessageTime': u['lastMessageTime']?.toString() ?? '',
    };
  }

  Map<String, dynamic> _normalizeMessage(Map<String, dynamic> msg) {
    return {
      'senderId': msg['senderId']?.toString() ?? '',
      'receiverId': msg['receiverId']?.toString() ?? '',
      'message': msg['message']?.toString() ?? '',
      'messageId': msg['messageId']?.toString() ?? Uuid().v4(),
      'timestamp': _validateTimestamp(msg['timestamp']),
      'delivered': msg['delivered'] as bool? ?? false,
      'read': msg['read'] as bool? ?? false,
    };
  }

  Map<String, dynamic> _createMessage(String text, String receiverId) {
    return {
      'senderId': currentUserId.value!,
      'receiverId': receiverId,
      'message': text,
      'messageId': Uuid().v4(),
      'timestamp': DateTime.now().toIso8601String(),
      'delivered': false,
      'read': false,
    };
  }

  bool _isValidMessage(Map<String, dynamic> msg) {
    return msg['messageId'] != null &&
        msg['messageId'].toString().isNotEmpty &&
        msg['senderId'] != null &&
        msg['receiverId'] != null;
  }

  String _validateTimestamp(dynamic timestamp) {
    if (timestamp == null || timestamp.toString().isEmpty) {
      print('ChatController: Invalid or null timestamp, using current time');
      return DateTime.now().toIso8601String();
    }
    try {
      final parsed = DateTime.parse(timestamp.toString());
      print('ChatController: Validated timestamp: ${parsed.toIso8601String()}');
      return parsed.toIso8601String();
    } catch (e) {
      print('ChatController: Failed to parse timestamp: $timestamp, error: $e, using current time');
      return DateTime.now().toIso8601String();
    }
  }

  bool _isValidReceiver(String receiverId) {
    return allUsers.any((u) => u['email'] == receiverId);
  }

  bool _isUserOnline(String email) {
    return allUsers.any((u) => u['email'] == email && (u['online'] as bool? ?? false));
  }

  Future<void> _addMessage(Map<String, dynamic> message) async {
    if (!_isValidMessage(message)) {
      print('ChatController: Invalid message: $message');
      return;
    }
    messages[message['messageId']] = message;
    final receiverId = message['senderId'] == currentUserId.value ? message['receiverId'] : message['senderId'];
    await saveMessagesForUser(receiverId);
    _updateUserLastMessageTime(message);
    _updateFilteredUsers();
    print('ChatController: Added message: ${message['messageId']} for receiver: $receiverId');
  }

  Future<void> _mergeMessages(List<Map<String, dynamic>> newMessages, String receiverId) async {
    for (var newMsg in newMessages) {
      if (_isValidMessage(newMsg)) {
        final existingMsg = messages[newMsg['messageId']];
        if (existingMsg == null) {
          messages[newMsg['messageId']] = newMsg;
          print('ChatController: Added new message: ${newMsg['messageId']}');
        } else {
          final existingTime = DateTime.parse(existingMsg['timestamp']);
          final newTime = DateTime.parse(newMsg['timestamp']);
          if (newTime.isAfter(existingTime)) {
            messages[newMsg['messageId']] = newMsg;
            print('ChatController: Updated message: ${newMsg['messageId']} with newer timestamp');
          } else {
            existingMsg['delivered'] = newMsg['delivered'] ?? existingMsg['delivered'];
            existingMsg['read'] = newMsg['read'] ?? existingMsg['read'];
            print('ChatController: Updated message status: ${newMsg['messageId']}, delivered: ${existingMsg['delivered']}, read: ${existingMsg['read']}');
          }
        }
      }
    }
    await saveMessagesForUser(receiverId);
    final latestMessage = newMessages.isNotEmpty
        ? newMessages.reduce((a, b) => DateTime.parse(a['timestamp']).isAfter(DateTime.parse(b['timestamp'])) ? a : b)
        : {'receiverId': receiverId, 'timestamp': ''};
    _updateUserLastMessageTime(latestMessage);
    _updateFilteredUsers();
  }

  void _updateFilteredUsers() {
    if (_disposed) return;
    final query = searchController.text.trim().toLowerCase();
    filteredUsers.value = query.isEmpty
        ? allUsers
        : allUsers.where((user) => user['username'].toString().toLowerCase().contains(query)).toList();
    filteredUsers.sort((a, b) {
      final aTime = DateTime.tryParse(a['lastMessageTime'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = DateTime.tryParse(b['lastMessageTime'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    filteredUsers.refresh();
    print('ChatController: Updated filtered users: ${filteredUsers.length}');
  }

  void _refreshUserList() {
    _updateFilteredUsers();
    filteredUsers.refresh();
    unseenNotifications.refresh();
    messages.refresh(); // Ensure UI reflects message status changes
    print('ChatController: Refreshed user list with ${filteredUsers.length} users, notifications: ${unseenNotifications.length}');
  }

  void debounceSearch() {
    if (_disposed) return;
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!_disposed) {
        _updateFilteredUsers();
      }
    });
  }

  bool _hasUserChanges(List<Map<String, dynamic>> newUsers) {
    if (newUsers.length != allUsers.length) return true;
    for (int i = 0; i < newUsers.length; i++) {
      final newUser = newUsers[i];
      final oldUser = allUsers[i];
      if (newUser['email'] != oldUser['email'] ||
          newUser['username'] != oldUser['username'] ||
          newUser['online'] != oldUser['online'] ||
          newUser['profilePicture'] != oldUser['profilePicture']) {
        return true;
      }
    }
    return false;
  }

  void _handleReceivedMessage(Map<String, dynamic> data) {
    if (data['receiverId'] == currentUserId.value || data['senderId'] == currentUserId.value) {
      if (_isValidMessage(data) && !messages.containsKey(data['messageId'])) {
        final normalizedMessage = _normalizeMessage({...data, 'read': false});
        print('ChatController: Received message: ${data['messageId']}, read: ${normalizedMessage['read']}, sender: ${data['senderId']}');
        _addMessage(normalizedMessage);

        final senderId = data['senderId'];
        final isViewingChat = senderId != currentUserId.value &&
            selectedReceiverId.value == senderId &&
            Get.currentRoute.contains(AppRoutes.getChatPage(senderId, ''));

        if (!isViewingChat) {
          unseenNotifications[senderId] ??= [];
          if (!unseenNotifications[senderId]!.any((msg) => msg['messageId'] == data['messageId'])) {
            unseenNotifications[senderId]!.add(normalizedMessage);
            saveUnseenNotifications();
            print('ChatController: Added to unseen notifications for $senderId: ${data['messageId']}, total: ${unseenNotifications[senderId]!.length}');
            _refreshUserList();

            final senderUser = allUsers.firstWhere(
              (u) => u['email'] == senderId,
              orElse: () => {'username': senderId, 'email': senderId},
            );
            final senderName = senderUser['username']?.toString() ?? senderId;

            Get.snackbar(
              'New message: $senderName',
              data['message'],
              snackPosition: SnackPosition.TOP,
              backgroundColor: Get.theme.colorScheme.secondary,
              colorText: Get.theme.colorScheme.onSecondary,
              margin: const EdgeInsets.all(16),
              borderRadius: 8,
              duration: const Duration(seconds: 3),
              onTap: (snack) {
                Get.toNamed(AppRoutes.getChatPage(senderId, allUsers.firstWhere((u) => u['email'] == senderId, orElse: () => {'username': 'Unknown'})['username']));
              },
            );
          } else {
            print('ChatController: Skipped duplicate notification for message: ${data['messageId']}');
          }
        } else {
          socketClient.markAsRead(data['messageId']);
          messages[data['messageId']] = {
            ...messages[data['messageId']]!,
            'delivered': true,
            'read': true,
          };
          saveMessagesForUser(senderId);
          unseenNotifications.remove(senderId);
          saveUnseenNotifications();
          _refreshUserList();
          print('ChatController: Marked message as read: ${data['messageId']}');
        }
      } else {
        print('ChatController: Skipped message: ${data['messageId']}, exists: ${messages.containsKey(data['messageId'])}');
      }
    }
  }

  void _handleSentMessage(Map<String, dynamic> data) {
    if (data['senderId'] == currentUserId.value && _isValidMessage(data)) {
      messages[data['messageId']] = _normalizeMessage(data);
      final receiverId = data['receiverId'];
      saveMessagesForUser(receiverId);
      _updateUserLastMessageTime(data);
      _updateFilteredUsers();
      print('ChatController: Message sent: ${data['messageId']}');
    }
  }

  void _handleMessageDelivered(String messageId) {
    if (messages.containsKey(messageId)) {
      messages[messageId] = {
        ...messages[messageId]!,
        'delivered': true,
      };
      final receiverId = messages[messageId]!['receiverId'];
      saveMessagesForUser(receiverId);
      _refreshUserList();
      print('ChatController: Message delivered: $messageId');
    }
  }

  void _handleMessageRead(String messageId) {
    if (messages.containsKey(messageId)) {
      messages[messageId] = {
        ...messages[messageId]!,
        'delivered': true,
        'read': true,
      };
      final receiverId = messages[messageId]!['receiverId'];
      saveMessagesForUser(receiverId);
      _refreshUserList();
      print('ChatController: Message read: $messageId');
    }
  }

  void _handleTyping(String senderId, bool isTyping) {
    if (senderId != currentUserId.value) {
      if (isTyping) {
        typingUsers.add(senderId);
        print('ChatController: Typing: $senderId');
      } else {
        typingUsers.remove(senderId);
        print('ChatController: Stopped typing: $senderId');
      }
      typingUsers.refresh();
    }
  }

  void _updateUserStatus(String email, bool online) {
    final user = allUsers.firstWhereOrNull((u) => u['email'] == email);
    if (user != null && user['online'] != online) {
      user['online'] = online;
      allUsers.refresh();
      storageService.saveUsers(currentUserId.value!, allUsers);
      print('ChatController: User ${online ? 'online' : 'offline'}: $email');
    }
  }

  Future<void> _handleSocketError(String error) async {
    errorMessage.value = error;
    isConnected.value = false;
    print('ChatController: Socket error: $error');
    if (error.contains('Invalid token') || error.contains('User ID mismatch')) {
      await _handleInvalidToken();
    } else {
      await Future.delayed(_reconnectDelay);
      if (!isConnected.value && hasInternet.value && serverAvailable.value) {
        print('ChatController: Retrying socket connection after delay');
        await connect();
      }
    }
  }

  void _handleNewUser(Map<String, dynamic> newUser) {
    if (newUser['email'] != currentUserId.value &&
        newUser['email']?.toString().isNotEmpty == true &&
        !allUsers.any((u) => u['email'] == newUser['email'])) {
      final normalizedUser = _normalizeUser(newUser);
      allUsers.add(normalizedUser);
      storageService.saveUsers(currentUserId.value!, allUsers);
      _updateFilteredUsers();
      print('ChatController: Added new user: ${newUser['email']}');
    }
  }

  Future<void> _handleInvalidToken() async {
    print('ChatController: Handling invalid token');
    storageService.clear();
    errorMessage.value = 'session_expired'.tr;
    Get.offAllNamed(AppRoutes.getSignInPage());
  }

  Future<void> _handleFetchError(dynamic e, int retryCount, Future<void> Function() retry) async {
    print('ChatController: Fetch error: $e');
    if (e.toString().contains('Invalid token') && retryCount < _maxRetries) {
      print('ChatController: Invalid token detected, redirecting to login');
      storageService.clear();
      errorMessage.value = 'session_expired'.tr;
      Get.offAllNamed(AppRoutes.getSignInPage());
    } else if (retryCount < _maxRetries) {
      print('ChatController: Retrying ${retryCount + 1}/$_maxRetries');
      await Future.delayed(_baseRetryDelay * (retryCount + 1));
      await retry();
    } else {
      errorMessage.value = 'failed_to_load_data'.tr;
      Get.snackbar(
        'error'.tr,
        'failed_to_load_data'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> _handleSocketConnectError(dynamic e) async {
    print('ChatController: Connect error: $e');
    errorMessage.value = 'socket_connect_failed'.tr;
    await Future.delayed(_reconnectDelay);
    if (!isConnected.value && hasInternet.value && serverAvailable.value) {
      print('ChatController: Retrying socket connection after delay');
      await connect();
    }
  }

  Map<String, dynamic> _getLastMessageData(String userEmail) {
    final relatedMessages = messages.values
        .where(
          (msg) =>
              (msg['senderId'] == currentUserId.value && msg['receiverId'] == userEmail) ||
              (msg['senderId'] == userEmail && msg['receiverId'] == currentUserId.value),
        )
        .toList();

    if (relatedMessages.isEmpty) {
      return {'message': '', 'timestamp': '', 'senderId': '', 'delivered': false, 'read': false};
    }

    final latestMessage = relatedMessages.reduce((a, b) {
      final aTime = DateTime.parse(a['timestamp']);
      final bTime = DateTime.parse(b['timestamp']);
      return aTime.isAfter(bTime) ? a : b;
    });

    return {
      'message': latestMessage['message'],
      'timestamp': latestMessage['timestamp'],
      'senderId': latestMessage['senderId'],
      'delivered': latestMessage['delivered'],
      'read': latestMessage['read'],
    };
  }

  String _getLatestMessageTime(String userId) {
    final relatedMessages = messages.values
        .where(
          (msg) =>
              (msg['senderId'] == currentUserId.value && msg['receiverId'] == userId) ||
              (msg['senderId'] == userId && msg['receiverId'] == currentUserId.value),
        )
        .toList();

    if (relatedMessages.isEmpty) return '';

    final latestMessage = relatedMessages.reduce((a, b) {
      final aTime = DateTime.parse(a['timestamp']);
      final bTime = DateTime.parse(b['timestamp']);
      return aTime.isAfter(bTime) ? a : b;
    });

    return latestMessage['timestamp'];
  }

  void _updateUserLastMessageTime(Map<String, dynamic> message) {
    final userId = message['senderId'] == currentUserId.value ? message['receiverId'] : message['senderId'];
    final user = allUsers.firstWhereOrNull((u) => u['email'] == userId);
    if (user != null) {
      final currentTime = DateTime.tryParse(user['lastMessageTime'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final messageTime = DateTime.parse(message['timestamp']);
      if (messageTime.isAfter(currentTime)) {
        user['lastMessageTime'] = message['timestamp'];
        allUsers.sort((a, b) {
          final aTime = DateTime.tryParse(a['lastMessageTime'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = DateTime.tryParse(b['lastMessageTime'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
        storageService.saveUsers(currentUserId.value!, allUsers);
        print('ChatController: Updated last message time for $userId: ${user['lastMessageTime']}');
      }
    }
  }
  
  void _updateAllUsersLastMessageTime() {
    for (var user in allUsers) {
      final latestTime = _getLatestMessageTime(user['email']);
      user['lastMessageTime'] = latestTime;
    }
    allUsers.sort((a, b) {
      final aTime = DateTime.tryParse(a['lastMessageTime'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = DateTime.tryParse(b['lastMessageTime'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    if (currentUserId.value != null) {
      storageService.saveUsers(currentUserId.value!, allUsers);
    }
    print('ChatController: Updated all users last message times');
  }
}


