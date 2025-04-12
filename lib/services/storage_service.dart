import 'package:get_storage/get_storage.dart';

class StorageService {
  final _box = GetStorage();

  // Save user data
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _box.write('user', user);
  }

  // Get user data
  Map<String, dynamic>? getUser() {
    return _box.read('user');
  }

  // Save token
  Future<void> saveToken(String token) async {
    await _box.write('token', token);
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
    return _box.read('tabIndex') ?? 0; // Default to 0 if not set
  }

  // Clear storage
  Future<void> clear() async {
    await _box.erase();
  }
}