import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService {
  final _box = GetStorage();
  final user = Rx<Map<String, dynamic>?>(null); // Reactive user data

  StorageService() {
    user.value = getUser(); // Initialize reactive user
  }

  // Save user data
  Future<void> saveUser(Map<String, dynamic> userData) async {
    print('Saving user: $userData');
    await _box.write('user', userData);
    user.value = Map<String, dynamic>.from(userData); // Update reactive user
  }

  // Get user data
  Map<String, dynamic>? getUser() {
    final data = _box.read('user');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // Save token
  Future<void> saveToken(String token) async {
    await _box.write('token', token);
  }

Future<void> saveLocale(String locale) async {
    await _box.write('locale', locale);
  }
  // Get token
  String? getToken() {
    return _box.read('token');
  }

  // Save selected tab index
  Future<void> saveTabIndex(int index) async {
    await _box.write('tabIndex', index);
  }

  // Get selected tab index
  int getTabIndex() {
    return _box.read('tabIndex') ?? 0;
  }

  // Save theme mode
  Future<void> saveThemeMode(bool isDark) async {
    await _box.write('isDarkMode', isDark);
  }

  // Get theme mode
  bool getThemeMode() {
    return _box.read('isDarkMode') ?? false;
  }

  // Clear storage
  Future<void> clear() async {
    await _box.erase();
    user.value = null;
  }
}