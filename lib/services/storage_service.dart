import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  static const String _container = 'AppContainer';
  final GetStorage box;
  final user = Rx<Map<String, dynamic>?>(null);

  StorageService() : box = GetStorage(_container) {
    user.value = getUser();
  }

  // Helper to safely read from storage
  T? _read<T>(String key) => box.read(key);

  // Helper to safely write to storage
  Future<void> _write<T>(String key, T value) async => await box.write(key, value);

  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _write('user', userData);
    user.value = Map<String, dynamic>.from(userData);
  }

  Map<String, dynamic>? getUser() => _read<Map<String, dynamic>>('user');

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
    final encodedUsers = users.map(jsonEncode).toList();
    await _write(key, encodedUsers);
  }

  List<Map<String, dynamic>> getUsers(String currentUserId) {
    final key = 'users_$currentUserId';
    final stored = _read<List<dynamic>>(key) ?? [];
    return stored
        .map((item) {
          try {
            final decoded = jsonDecode(item as String);
            return decoded is Map<String, dynamic> ? decoded : null;
          } catch (_) {
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
            final decoded = jsonDecode(item as String);
            return decoded is Map<String, dynamic> &&
                    decoded['messageId'] != null &&
                    decoded['senderId'] != null &&
                    decoded['receiverId'] != null &&
                    decoded['message'] != null &&
                    decoded['timestamp'] != null
                ? decoded
                : null;
          } catch (_) {
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