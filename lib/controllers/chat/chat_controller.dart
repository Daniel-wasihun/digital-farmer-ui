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
  // Dependencies
  final SocketClient socketClient = SocketClient();
  final StorageService storageService = Get.find<StorageService>();
  final ApiService apiService = Get.find<ApiService>();

  // State
  final currentUserId = RxnString();
  final messages = <String, Map<String, dynamic>>{}.obs; // Keyed by messageId
  final allUsers = <Map<String, dynamic>>[].obs;
  final filteredUsers = <Map<String, dynamic>>[].obs;
  final typingUsers = <String>{}.obs;
  final isConnected = false.obs;
  final errorMessage = ''.obs;
  final selectedReceiverId = ''.obs;
  final isLoadingUsers = false.obs;
  final isLoadingMessages = false.obs;
  final searchController = TextEditingController();

  // Internal
  Timer? _searchDebounceTimer;
  bool _isConnecting = false;
  static const _maxRetries = 3;
  static const _baseRetryDelay = Duration(seconds: 2);

  @override
  void onInit() {
    super.onInit();
    ever(storageService.user, (_) => _handleUserChange());
    searchController.addListener(debounceSearch);
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

  // Initialization
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
      Get.snackbar('Error', 'failed_to_initialize'.tr, snackPosition: SnackPosition.BOTTOM);
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
    selectedReceiverId.value = '';
    searchController.clear();
    errorMessage.value = '';
    isConnected.value = false;
  }

  // Data Loading
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

  // User Fetching
  Future<void> fetchUsers({int retryCount = 0}) async {
    if (isLoadingUsers.value || currentUserId.value == null) {
      print('ChatController: Skipping fetchUsers: loading=${isLoadingUsers.value}, userId=${currentUserId.value}');
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

      if (_hasUserChanges(newUsers)) {
        allUsers.assignAll(newUsers);
        _updateFilteredUsers();
        await storageService.saveUsers(currentUserId.value!, newUsers);
        print('ChatController: Fetched and saved ${allUsers.length} users');
      } else {
        print('ChatController: No changes in users, skipping update');
      }
      errorMessage.value = '';
    } catch (e) {
      await _handleFetchError(e, retryCount, () => fetchUsers(retryCount: retryCount + 1));
    } finally {
      isLoadingUsers.value = false;
    }
  }

  // Socket Connection
  Future<void> connect() async {
    if (_isConnecting || isConnected.value || currentUserId.value == null) {
      print('ChatController: Skipping connect: connecting=$_isConnecting, connected=${isConnected.value}, userId=${currentUserId.value}');
      return;
    }
    final token = storageService.getToken();
    if (token == null) {
      print('ChatController: No token, redirecting to login');
      errorMessage.value = 'not_logged_in'.tr;
      Get.offAllNamed(AppRoutes.getSignInPage());
      return;
    }
    _isConnecting = true;
    try {
      await apiService.user.getUsers(); // Verify token
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
      );
    } catch (e) {
      await _handleSocketConnectError(e);
    } finally {
      _isConnecting = false;
    }
  }

  // Message Handling
  Future<void> send(String text, String receiverId) async {
    if (text.trim().isEmpty || currentUserId.value == null) {
      print('ChatController: Empty text or no userId');
      return;
    }
    if (!_isValidReceiver(receiverId)) {
      print('ChatController: Invalid receiverId: $receiverId');
      Get.snackbar('Error', 'invalid_receiver'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    final message = _createMessage(text, receiverId);
    await _addMessage(message);
    if (isConnected.value && socketClient.socket?.connected == true) {
      socketClient.sendMessage(currentUserId.value!, receiverId, text, message['messageId']);
    } else {
      await storeOfflineMessage(message);
      Get.snackbar('offline'.tr, 'message_stored_locally'.tr, backgroundColor: Colors.grey, colorText: Colors.white);
    }
  }

  Future<void> fetchMessagesFromBackend(String receiverId, {int retryCount = 0}) async {
    if (currentUserId.value == null || receiverId.isEmpty || !_isValidReceiver(receiverId)) {
      print('ChatController: Invalid fetch params: userId=${currentUserId.value}, receiverId=$receiverId');
      errorMessage.value = 'invalid_receiver'.tr;
      Get.snackbar('Error', 'invalid_receiver'.tr, snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoadingMessages.value = true;
    try {
      final backendMessages = await apiService.message.getMessages(currentUserId.value!, receiverId);
      final newMessages = backendMessages.map(_normalizeMessage).toList();
      await _mergeMessages(newMessages, receiverId);
      errorMessage.value = '';
      print('ChatController: Fetched and saved ${newMessages.length} messages for $receiverId');
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
    await storageService.box.write(offlineKey, []); // Clear after sync
    print('ChatController: Synced ${stored.length} offline messages');
  }

  // Public method to save messages for a user
  Future<void> saveMessagesForUser(String receiverId) async {
    final relatedMessages = messages.values
        .where((m) =>
            (m['senderId'] == currentUserId.value && m['receiverId'] == receiverId) ||
            (m['senderId'] == receiverId && m['receiverId'] == currentUserId.value))
        .toList();
    await storageService.saveMessagesForUser(currentUserId.value!, receiverId, relatedMessages);
    print('ChatController: Saved ${relatedMessages.length} messages for $receiverId');
  }

  // UI State
  void selectReceiver(String receiverId) async {
    if (receiverId.isEmpty || currentUserId.value == null) {
      print('ChatController: Invalid selectReceiver: receiverId=$receiverId, userId=${currentUserId.value}');
      return;
    }
    selectedReceiverId.value = receiverId;
    await fetchMessagesFromBackend(receiverId);
    final unreadMessages = messages.values
        .where((msg) => msg['senderId'] == receiverId && msg['receiverId'] == currentUserId.value && !msg['read'])
        .toList();
    for (var msg in unreadMessages) {
      socketClient.markAsRead(msg['messageId']);
      msg['read'] = true;
      await saveMessagesForUser(msg['senderId']);
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
    return messages.values
        .where((msg) => msg['senderId'] == receiverId && msg['receiverId'] == currentUserId.value && !msg['read'])
        .length;
  }

  List<Map<String, dynamic>> get userListItems {
    return filteredUsers.map((user) {
      final email = user['email'] as String;
      final lastMessage = _getLastMessageData(email);
      return {
        'user': user,
        'unseenCount': getUnseenMessageCount(email),
        'isTyping': typingUsers.contains(email),
        'lastMessage': lastMessage['message'] ?? '',
        'timestamp': lastMessage['timestamp'] ?? '',
        'isSentByUser': lastMessage['senderId'] == currentUserId.value,
        'isDelivered': lastMessage['delivered'] == true,
        'isRead': lastMessage['read'] == true,
      };
    }).toList();
  }

  // Helpers
  Map<String, dynamic> _normalizeUser(Map<String, dynamic> u) {
    return {
      'email': u['email']?.toString() ?? '',
      'username': u['username']?.toString() ?? 'Unknown',
      'online': u['online'] as bool? ?? false,
      'profilePicture': u['profilePicture']?.toString() ?? '',
      'lastMessageTime': _getLatestMessageTime(u['email']?.toString() ?? ''),
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
      return DateTime.now().toIso8601String();
    }
    try {
      DateTime.parse(timestamp.toString());
      return timestamp.toString();
    } catch (e) {
      print('ChatController: Invalid timestamp: $timestamp, using current time');
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
    await saveMessagesForUser(message['senderId'] == currentUserId.value ? message['receiverId'] : message['senderId']);
    _updateUserLastMessageTime(message);
  }

  Future<void> _mergeMessages(List<Map<String, dynamic>> newMessages, String receiverId) async {
    for (var msg in newMessages) {
      if (_isValidMessage(msg)) {
        messages[msg['messageId']] = msg;
      }
    }
    await saveMessagesForUser(receiverId);
    _updateUserLastMessageTime(newMessages.isNotEmpty ? newMessages.last : {'receiverId': receiverId});
  }
  

  void _updateFilteredUsers() {
    final query = searchController.text.trim().toLowerCase();
    filteredUsers.value = query.isEmpty
        ? allUsers
        : allUsers.where((user) => user['username'].toString().toLowerCase().contains(query)).toList();
  }

  void debounceSearch() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), _updateFilteredUsers);
  }

  bool _hasUserChanges(List<Map<String, dynamic>> newUsers) {
    if (newUsers.length != allUsers.length) return true;
    for (int i = 0; i < newUsers.length; i++) {
      final newUser = newUsers[i];
      final oldUser = allUsers[i];
      if (newUser['email'] != oldUser['email'] ||
          newUser['username'] != oldUser['username'] ||
          newUser['online'] != oldUser['online'] ||
          newUser['profilePicture'] != oldUser['profilePicture'] ||
          newUser['lastMessageTime'] != oldUser['lastMessageTime']) {
        return true;
      }
    }
    return false;
  }

  void _handleReceivedMessage(Map<String, dynamic> data) {
    if (data['receiverId'] == currentUserId.value || data['senderId'] == currentUserId.value) {
      if (_isValidMessage(data) && !messages.containsKey(data['messageId'])) {
        _addMessage(_normalizeMessage(data));
        print('ChatController: Received message: ${data['messageId']}');
      }
    }
  }

  void _handleSentMessage(Map<String, dynamic> data) {
    if (data['senderId'] == currentUserId.value && _isValidMessage(data) && !messages.containsKey(data['messageId'])) {
      _addMessage(_normalizeMessage(data));
      print('ChatController: Message sent: ${data['messageId']}');
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
    }
  }

  Future<void> _handleSocketError(String error) async {
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

  void _updateUserStatus(String email, bool online) {
    final user = allUsers.firstWhereOrNull((u) => u['email'] == email);
    if (user != null && user['online'] != online) {
      user['online'] = online;
      allUsers.refresh();
      storageService.saveUsers(currentUserId.value!, allUsers);
      print('ChatController: User ${online ? 'online' : 'offline'}: $email');
    }
  }

  Future<void> _handleInvalidToken() async {
    print('ChatController: Handling invalid token');
    final refreshed = await apiService.auth.refreshToken();
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

  Future<void> _handleFetchError(dynamic e, int retryCount, Future<void> Function() retry) async {
    print('ChatController: Fetch error: $e');
    if (e.toString().contains('Invalid token') && retryCount < _maxRetries) {
      print('ChatController: Attempting token refresh');
      final refreshed = await apiService.auth.refreshToken();
      if (refreshed) {
        await retry();
      } else {
        print('ChatController: Token refresh failed, redirecting to login');
        storageService.clear();
        errorMessage.value = 'session_expired'.tr;
        Get.offAllNamed(AppRoutes.getSignInPage());
      }
    } else if (retryCount < _maxRetries) {
      print('ChatController: Retrying ${retryCount + 1}/$_maxRetries');
      await Future.delayed(_baseRetryDelay * (retryCount + 1));
      await retry();
    } else {
      errorMessage.value = 'failed_to_load_data'.tr;
      Get.snackbar('Error', 'failed_to_load_data'.tr, snackPosition: SnackPosition.BOTTOM);
      final storedUsers = storageService.getUsers(currentUserId.value!);
      if (storedUsers.isNotEmpty) {
        allUsers.assignAll(storedUsers);
        filteredUsers.assignAll(storedUsers);
        print('ChatController: Loaded ${allUsers.length} users from storage as fallback');
      }
    }
  }

  Future<void> _handleSocketConnectError(dynamic e) async {
    print('ChatController: Connect error: $e');
    errorMessage.value = 'socket_connect_failed'.tr;
    Get.snackbar('Error', 'socket_connect_failed'.tr, snackPosition: SnackPosition.BOTTOM);
    await Future.delayed(Duration(seconds: 5));
    if (!isConnected.value) {
      print('ChatController: Retrying socket connection');
      await connect();
    }
  }

  Map<String, dynamic> _getLastMessageData(String userEmail) {
    final relatedMessages = messages.values.where(
      (msg) =>
          (msg['senderId'] == currentUserId.value && msg['receiverId'] == userEmail) ||
          (msg['senderId'] == userEmail && msg['receiverId'] == currentUserId.value),
    );
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
    final relatedMessages = messages.values.where(
      (msg) =>
          (msg['senderId'] == currentUserId.value && msg['receiverId'] == userId) ||
          (msg['senderId'] == userId && msg['receiverId'] == currentUserId.value),
    );
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
      }
    }
  }

  void _updateAllUsersLastMessageTime() {
    for (var user in allUsers) {
      user['lastMessageTime'] = _getLatestMessageTime(user['email']);
    }
    allUsers.sort((a, b) {
      final aTime = DateTime.tryParse(a['lastMessageTime'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = DateTime.tryParse(b['lastMessageTime'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    if (currentUserId.value != null) {
      storageService.saveUsers(currentUserId.value!, allUsers);
    }
  }
}