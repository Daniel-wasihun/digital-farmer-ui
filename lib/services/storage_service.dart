import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  final box = GetStorage('AppContainer');
  final user = Rx<Map<String, dynamic>?>(null);

  StorageService() {
    try {
      user.value = getUser();
      print('StorageService: Initialized with user: ${user.value}');
    } catch (e) {
      print('StorageService: Init error: $e');
    }
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await box.write('user', userData);
      user.value = Map<String, dynamic>.from(userData);
      print('StorageService: Saved user: $userData');
    } catch (e) {
      print('StorageService: saveUser error: $e');
    }
  }

  Map<String, dynamic>? getUser() {
    try {
      final data = box.read('user');
      return data != null ? Map<String, dynamic>.from(data) : null;
    } catch (e) {
      print('StorageService: getUser error: $e');
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      await box.write('token', token);
      print('StorageService: Saved token');
    } catch (e) {
      print('StorageService: saveToken error: $e');
    }
  }

  String? getToken() {
    try {
      return box.read('token');
    } catch (e) {
      print('StorageService: getToken error: $e');
      return null;
    }
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await box.write('refreshToken', refreshToken);
      print('StorageService: Saved refresh token');
    } catch (e) {
      print('StorageService: saveRefreshToken error: $e');
    }
  }

  String? getRefreshToken() {
    try {
      return box.read('refreshToken');
    } catch (e) {
      print('StorageService: getRefreshToken error: $e');
      return null;
    }
  }

  Future<void> saveLocale(String locale) async {
    try {
      await box.write('locale', locale);
      print('StorageService: Saved locale: $locale');
    } catch (e) {
      print('StorageService: saveLocale error: $e');
    }
  }

  Future<void> saveTabIndex(int index) async {
    try {
      await box.write('tabIndex', index);
      print('StorageService: Saved tabIndex: $index');
    } catch (e) {
      print('StorageService: saveTabIndex error: $e');
    }
  }

  int getTabIndex() {
    try {
      return box.read('tabIndex') ?? 0;
    } catch (e) {
      print('StorageService: getTabIndex error: $e');
      return 0;
    }
  }

  Future<void> saveThemeMode(bool isDark) async {
    try {
      await box.write('isDarkMode', isDark);
      print('StorageService: Saved themeMode: $isDark');
    } catch (e) {
      print('StorageService: saveThemeMode error: $e');
    }
  }

  bool getThemeMode() {
    try {
      return box.read('isDarkMode') ?? false;
    } catch (e) {
      print('StorageService: getThemeMode error: $e');
      return false;
    }
  }

  Future<void> saveUsers(String currentUserId, List<Map<String, dynamic>> users) async {
    try {
      final key = 'users_$currentUserId';
      final encodedUsers = users.map((user) => jsonEncode(user)).toList();
      await box.write(key, encodedUsers);
      print('StorageService: Saved ${users.length} users for $currentUserId');
    } catch (e) {
      print('StorageService: saveUsers error: $e');
    }
  }

  List<Map<String, dynamic>> getUsers(String currentUserId) {
    try {
      final key = 'users_$currentUserId';
      final stored = box.read(key) as List<dynamic>? ?? [];
      final users = stored
          .map((s) {
            try {
              final decoded = jsonDecode(s as String);
              return decoded is Map<String, dynamic> ? decoded : null;
            } catch (e) {
              print('StorageService: Invalid user data: $s, error: $e');
              return null;
            }
          })
          .where((u) => u != null)
          .cast<Map<String, dynamic>>()
          .toList();
      print('StorageService: Loaded ${users.length} users for $currentUserId');
      return users;
    } catch (e) {
      print('StorageService: getUsers error: $e');
      return [];
    }
  }

  Future<void> saveMessagesForUser(String currentUserId, String receiverId, List<Map<String, dynamic>> messages) async {
    try {
      final key = 'messages_${currentUserId}_$receiverId';
      final encodedMessages = messages.map((msg) => jsonEncode(msg)).toList();
      // Deduplicate by messageId
      final uniqueMessages = <String, String>{};
      for (var msgStr in encodedMessages) {
        try {
          final msg = jsonDecode(msgStr);
          if (msg['messageId'] != null) {
            uniqueMessages[msg['messageId']] = msgStr;
          }
        } catch (e) {
          print('StorageService: Invalid message data: $msgStr, error: $e');
        }
      }
      await box.write(key, uniqueMessages.values.toList());
      print('StorageService: Saved ${uniqueMessages.length} messages for $currentUserId and $receiverId');
    } catch (e) {
      print('StorageService: saveMessagesForUser error: $e');
    }
  }

  List<Map<String, dynamic>> getMessagesForUser(String currentUserId, String receiverId) {
    try {
      final key = 'messages_${currentUserId}_$receiverId';
      final stored = box.read(key) as List<dynamic>? ?? [];
      final messages = stored
          .map((s) {
            try {
              final decoded = jsonDecode(s as String);
              return decoded is Map<String, dynamic> &&
                      decoded['messageId'] != null &&
                      decoded['senderId'] != null &&
                      decoded['receiverId'] != null &&
                      decoded['message'] != null &&
                      decoded['timestamp'] != null
                  ? decoded
                  : null;
            } catch (e) {
              print('StorageService: Invalid message data: $s, error: $e');
              return null;
            }
          })
          .where((m) => m != null)
          .cast<Map<String, dynamic>>()
          .toList();
      print('StorageService: Loaded ${messages.length} messages for $currentUserId and $receiverId');
      return messages;
    } catch (e) {
      print('StorageService: getMessagesForUser error: $e');
      return [];
    }
  }

  Future<void> clear() async {
    try {
      await box.erase();
      user.value = null;
      print('StorageService: Cleared storage');
    } catch (e) {
      print('StorageService: clear error: $e');
    }
  }
}