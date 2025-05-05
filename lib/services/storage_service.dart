import 'dart:convert';
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
    // Check if user data is stored in the old format (Map) or new format (JSON string)
    final existingData = box.read('user');
    if (existingData is String) {
      // Migrate from JSON string to Map
      try {
        final decoded = jsonDecode(existingData) as Map<String, dynamic>;
        await _write('user', decoded);
      } catch (e) {
        logger.e('Error migrating user data: $e');
        await _write('user', userData);
      }
    } else {
      await _write('user', userData);
    }
    user.value = Map<String, dynamic>.from(userData);
  }

  Map<String, dynamic>? getUser() {
    final stored = box.read('user');
    if (stored is String) {
      // Migrate JSON string back to Map
      try {
        final decoded = jsonDecode(stored) as Map<String, dynamic>;
        _write('user', decoded); // Save back as Map for future consistency
        return decoded;
      } catch (e) {
        logger.e('Error decoding user data: $e');
        return null;
      }
    }
    return stored is Map<String, dynamic> ? stored : null;
  }

  Future<void> saveToken(String token) async => await _write('token', token);

  String? getToken() => _read<String>('token');

  Future<void> saveRefreshToken(String refreshToken) async => await _write('refreshToken', refreshToken);

  String? getRefreshToken() => _read<String>('refreshToken');

  Future<void> saveLocale(String locale) async => await _write('locale', locale);

  String? getLocale() => _read<String>('locale');

  Future<void> saveTabIndex(int index) async => await _write('tabIndex', index);

  int getTabIndex() => _read<int>('tabIndex') ?? 0;

  Future<void> saveThemeMode(bool isDark) async => await _write('isDarkMode', isDark);

  bool getThemeMode() => _read<bool>('isDarkMode') ?? false;

  Future<void> saveUsers(String currentUserId, List<Map<String, dynamic>> users) async {
    final key = 'users_$currentUserId';
    final encodedUsers = users.map((user) => jsonEncode(user)).toList();
    await _write(key, encodedUsers);
  }

  List<Map<String, dynamic>> getUsers(String currentUserId) {
    final key = 'users_$currentUserId';
    final stored = _read<List<dynamic>>(key) ?? [];
    return stored
        .map((item) {
          try {
            return jsonDecode(item as String) as Map<String, dynamic>;
          } catch (e) {
            logger.e('Error decoding user data: $e');
            return null;
          }
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<void> saveMessagesForUser(
      String currentUserId, String receiverId, List<Map<String, dynamic>> messages) async {
    final key = 'messages_${currentUserId}_$receiverId';
    final uniqueMessages = <String, String>{};
    for (var msg in messages) {
      final messageId = msg['messageId']?.toString();
      if (messageId != null) {
        uniqueMessages[messageId] = jsonEncode(msg);
      }
    }
    await _write(key, uniqueMessages.values.toList());
  }

  List<Map<String, dynamic>> getMessagesForUser(String currentUserId, String receiverId) {
    final key = 'messages_${currentUserId}_$receiverId';
    final stored = _read<List<dynamic>>(key) ?? [];
    return stored
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
            return null;
          } catch (e) {
            logger.e('Error decoding message: $e');
            return null;
          }
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<void> clear() async {
    await box.erase();
    user.value = null;
  }
}