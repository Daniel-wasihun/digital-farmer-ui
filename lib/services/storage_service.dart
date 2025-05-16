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

  T? _read<T>(String key) {
    try {
      return box.read<T>(key);
    } catch (e) {
      logger.e('Error reading from storage for key $key: $e');
      return null;
    }
  }

  Future<void> _write<T>(String key, T value) async {
    try {
      await box.write(key, value);
    } catch (e) {
      logger.e('Error writing to storage for key $key: $e');
    }
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    // Validate user data
    if (!userData.containsKey('username') || userData['username'] == null || userData['username'].toString().isEmpty) {
      logger.w('User data missing or invalid username: $userData');
      Get.snackbar(
        'Warning'.tr,
        'User data is incomplete. Username is required.'.tr,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        snackPosition: SnackPosition.TOP,
        margin:  EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(milliseconds: 2000),
      );
      return;
    }

    await _write('user', Map<String, dynamic>.from(userData));
    user.value = Map<String, dynamic>.from(userData);
    logger.i('User data saved: ${user.value}');
  }

  Map<String, dynamic>? getUser() {
    final stored = _read<Map<String, dynamic>>('user');
    if (stored == null) {
      logger.w('No user data found in storage');
      return null;
    }
    if (!stored.containsKey('username')) {
      logger.w('Stored user data missing username: $stored');
    }
    return stored;
  }

  Future<void> saveToken(String token) async {
    await _write('token', token);
    logger.i('Token saved');
  }

  String? getToken() {
    final token = _read<String>('token');
    if (token == null) {
      logger.w('No token found in storage');
    }
    return token;
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _write('refreshToken', refreshToken);
    logger.i('Refresh token saved');
  }

  String? getRefreshToken() {
    final refreshToken = _read<String>('refreshToken');
    if (refreshToken == null) {
      logger.w('No refresh token found in storage');
    }
    return refreshToken;
  }

  Future<void> saveLocale(String locale) async {
    await _write('locale', locale);
    logger.i('Locale saved: $locale');
  }

  String? getLocale() {
    final locale = _read<String>('locale');
    if (locale == null) {
      logger.w('No locale found in storage');
    }
    return locale;
  }

  Future<void> saveTabIndex(int index) async {
    await _write('tabIndex', index);
    logger.i('Tab index saved: $index');
  }

  int getTabIndex() {
    final index = _read<int>('tabIndex') ?? 0;
    logger.i('Tab index retrieved: $index');
    return index;
  }

  Future<void> saveThemeMode(bool isDark) async {
    await _write('isDarkMode', isDark);
    logger.i('Theme mode saved: $isDark');
  }

  bool getThemeMode() {
    final isDark = _read<bool>('isDarkMode') ?? false;
    logger.i('Theme mode retrieved: $isDark');
    return isDark;
  }

  Future<void> saveUsers(String currentUserId, List<Map<String, dynamic>> users) async {
    final key = 'users_$currentUserId';
    final validUsers = users
        .where((user) => user.containsKey('id') && user['id'] != null)
        .toList();
    final encodedUsers = validUsers.map((user) => jsonEncode(user)).toList();
    await _write(key, encodedUsers);
    logger.i('Users saved for userId $currentUserId: ${validUsers.length} users');
  }

  List<Map<String, dynamic>> getUsers(String currentUserId) {
    final key = 'users_$currentUserId';
    final stored = _read<List<dynamic>>(key) ?? [];
    final users = stored
        .map((item) {
          try {
            final decoded = jsonDecode(item as String) as Map<String, dynamic>;
            return decoded.containsKey('id') ? decoded : null;
          } catch (e) {
            logger.e('Error decoding user data: $e');
            return null;
          }
        })
        .whereType<Map<String, dynamic>>()
        .toList();
    logger.i('Retrieved ${users.length} users for userId $currentUserId');
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
        logger.w('Invalid message format: $msg');
      }
    }
    await _write(key, uniqueMessages.values.toList());
    logger.i('Saved ${uniqueMessages.length} messages for userId $currentUserId and receiverId $receiverId');
  }

  List<Map<String, dynamic>> getMessagesForUser(String currentUserId, String receiverId) {
    final key = 'messages_${currentUserId}_$receiverId';
    final stored = _read<List<dynamic>>(key) ?? [];
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
            logger.w('Invalid message format in storage: $decoded');
            return null;
          } catch (e) {
            logger.e('Error decoding message: $e');
            return null;
          }
        })
        .whereType<Map<String, dynamic>>()
        .toList();
    logger.i('Retrieved ${messages.length} messages for userId $currentUserId and receiverId $receiverId');
    return messages;
  }

  Future<void> clear() async {
    await box.erase();
    user.value = null;
    logger.i('Storage cleared');
  }
}