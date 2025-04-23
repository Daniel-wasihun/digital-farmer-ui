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


  void saveRefreshToken(String refreshToken) {
    box.write('refreshToken', refreshToken);
  }

  String? getRefreshToken() {
    return box.read('refreshToken');
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

  Future<void> saveLocale(String locale) async {
    try {
      await box.write('locale', locale);
      print('StorageService: Saved locale: $locale');
    } catch (e) {
      print('StorageService: saveLocale error: $e');
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