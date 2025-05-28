import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

class StorageService {
  static const String _container = 'AppContainer';
  final GetStorage box;
  final user = Rx<Map<String, dynamic>?>(null);
  final logger = Logger();

  StorageService() : box = GetStorage(_container) {
    user.value = getUser();
  }

  T? read<T>(String key) {
    try {
      return box.read<T>(key);
    } catch (e) {
      logger.e('StorageService: Error reading from storage for key $key: $e');
      return null;
    }
  }

  Future<void> write<T>(String key, T value) async {
    try {
      await box.write(key, value);
    } catch (e) {
      logger.e('StorageService: Error writing to storage for key $key: $e');
    }
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    // Validate user data
    if (!userData.containsKey('username') || userData['username'] == null || userData['username'].toString().isEmpty) {
      logger.w('StorageService: User data missing or invalid username: $userData');
      Get.snackbar(
        'Warning'.tr,
        'User data is incomplete. Username is required.'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 2000),
      );
      return;
    }

    // Validate role field
    if (!userData.containsKey('role') || userData['role'] == null || !['admin', 'user'].contains(userData['role'])) {
      logger.w('StorageService: User data missing or invalid role: ${userData['role']}. Defaulting to "user".');
      userData['role'] = 'user';
      Get.snackbar(
        'Warning'.tr,
        'User role is missing or invalid. Defaulting to user role.'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 2000),
      );
    }

    await write('user', Map<String, dynamic>.from(userData));
    user.value = Map<String, dynamic>.from(userData);
    logger.i('StorageService: User data saved: ${user.value}, role: ${userData['role']}');
  }

  Map<String, dynamic>? getUser() {
    final stored = read<Map<String, dynamic>>('user');
    if (stored == null) {
      logger.w('StorageService: No user data found in storage');
      return null;
    }
    if (!stored.containsKey('username')) {
      logger.w('StorageService: Stored user data missing username: $stored');
    }
    if (!stored.containsKey('role')) {
      logger.w('StorageService: Stored user data missing role: $stored');
      stored['role'] = 'user';
    }
    logger.i('StorageService: Retrieved user data: $stored, role: ${stored['role']}');
    return stored;
  }

  Future<void> saveToken(String token) async {
    await write('token', token);
    logger.i('StorageService: Token saved');
  }

  String? getToken() {
    final token = read<String>('token');
    if (token == null) {
      logger.w('StorageService: No token found in storage');
    }
    logger.i('StorageService: Retrieved token: ${token != null ? '[present]' : 'null'}');
    return token;
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await write('refreshToken', refreshToken);
    logger.i('StorageService: Refresh token saved');
  }

  String? getRefreshToken() {
    final refreshToken = read<String>('refreshToken');
    if (refreshToken == null) {
      logger.w('StorageService: No refresh token found in storage');
    }
    logger.i('StorageService: Retrieved refresh token: ${refreshToken != null ? '[present]' : 'null'}');
    return refreshToken;
  }

  Future<void> saveLocale(String locale) async {
    await write('locale', locale);
    logger.i('StorageService: Locale saved: $locale');
  }

  String? getLocale() {
    final locale = read<String>('locale');
    if (locale == null) {
      logger.w('StorageService: No locale found in storage');
    }
    logger.i('StorageService: Retrieved locale: $locale');
    return locale;
  }

  Future<void> saveTabIndex(int index) async {
    await write('tabIndex', index);
    logger.i('StorageService: Tab index saved: $index');
  }

  int getTabIndex() {
    final index = read<int>('tabIndex') ?? 0;
    logger.i('StorageService: Tab index retrieved: $index');
    return index;
  }

  Future<void> saveThemeMode(bool isDark) async {
    await write('isDarkMode', isDark);
    logger.i('StorageService: Theme mode saved: $isDark');
  }

  bool getThemeMode() {
    final isDark = read<bool>('isDarkMode') ?? false;
    logger.i('StorageService: Theme mode retrieved: $isDark');
    return isDark;
  }

  Future<void> saveIsAdmin(bool isAdmin) async {
    await write('isAdmin', isAdmin);
    logger.i('StorageService: Admin status saved: $isAdmin');
  }

  bool getIsAdmin() {
    final isAdmin = read<bool>('isAdmin') ?? false;
    logger.i('StorageService: Admin status retrieved: $isAdmin');
    return isAdmin;
  }

  Future<void> saveUsers(String currentUserId, List<Map<String, dynamic>> users) async {
    final key = 'users_$currentUserId';
    final validUsers = users
        .where((user) => user.containsKey('id') && user['id'] != null)
        .toList();
    final encodedUsers = validUsers.map((user) => jsonEncode(user)).toList();
    await write(key, encodedUsers);
    logger.i('StorageService: Users saved for userId $currentUserId: ${validUsers.length} users');
  }

  List<Map<String, dynamic>> getUsers(String currentUserId) {
    final key = 'users_$currentUserId';
    final stored = read<List<dynamic>>(key) ?? [];
    final users = stored
        .map((item) {
          try {
            final decoded = jsonDecode(item as String) as Map<String, dynamic>;
            return decoded.containsKey('id') ? decoded : null;
          } catch (e) {
            logger.e('StorageService: Error decoding user data: $e');
            return null;
          }
        })
        .whereType<Map<String, dynamic>>()
        .toList();
    logger.i('StorageService: Retrieved ${users.length} users for userId $currentUserId');
    return users;
  }

  Future<void> saveMessagesForUser(
      String currentUserId, String receiverId, List<Map<String, dynamic>> messages) async {
    final key = 'messages_${currentUserId}_$receiverId';
    final uniqueMessages = <String, String>{};
    for (var msg in messages) {
      final messageId = msg['messageId']?.toString();
      if (messageId != null &&
          msg.containsKey('senderId') &&
          msg.containsKey('receiverId') &&
          msg.containsKey('message') &&
          msg.containsKey('timestamp')) {
        uniqueMessages[messageId] = jsonEncode(msg);
      } else {
        logger.w('StorageService: Invalid message format: $msg');
      }
    }
    await write(key, uniqueMessages.values.toList());
    logger.i('StorageService: Saved ${uniqueMessages.length} messages for userId $currentUserId and receiverId $receiverId');
  }

  List<Map<String, dynamic>> getMessagesForUser(String currentUserId, String receiverId) {
    final key = 'messages_${currentUserId}_$receiverId';
    final stored = read<List<dynamic>>(key) ?? [];
    final messages = stored
        .map((item) {
          try {
            final decoded = jsonDecode(item as String) as Map<String, dynamic>;
            if (decoded['messageId'] != null &&
                decoded['senderId'] != null &&
                decoded['receiverId'] != null &&
                decoded['message'] != null &&
                decoded['timestamp'] != null) {
              return decoded;
            }
            logger.w('StorageService: Invalid message format in storage: $decoded');
            return null;
          } catch (e) {
            logger.e('StorageService: Error decoding message: $e');
            return null;
          }
        })
        .whereType<Map<String, dynamic>>()
        .toList();
    logger.i('StorageService: Retrieved ${messages.length} messages for userId $currentUserId and receiverId $receiverId');
    return messages;
  }

  Future<void> clear() async {
    try {
      // Explicitly remove all known keys
      await box.remove('user');
      await box.remove('token');
      await box.remove('refreshToken');
      await box.remove('isAdmin');
      await box.remove('locale');
      await box.remove('tabIndex');
      await box.remove('isDarkMode');
      
      // Remove any user-specific keys (e.g., users_, messages_)
      final allKeys = box.getKeys();
      for (var key in allKeys) {
        if (key.toString().startsWith('users_') || key.toString().startsWith('messages_')) {
          await box.remove(key);
        }
      }

      // Clear entire storage as a fallback
      await box.erase();

      // Reset reactive state
      user.value = null;

      logger.i('StorageService: Cleared all storage data. User: ${user.value}, Token: ${getToken()}, IsAdmin: ${getIsAdmin()}');
    } catch (e) {
      logger.e('StorageService: Error clearing storage: $e');
    }
  }
}