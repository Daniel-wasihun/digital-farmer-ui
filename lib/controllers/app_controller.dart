import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../views/screens/Tabs/chat_tab.dart';
import '../views/screens/Tabs/crop_tips_tab.dart';
import '../views/screens/Tabs/market_tab.dart';
import '../views/screens/Tabs/weather_tab.dart';
import '../views/screens/tabs/settings_tab.dart';
import 'auth_controller.dart';
import 'theme_controller.dart';

class AppController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();
  final StorageService storageService = Get.find<StorageService>();

  var selectedIndex = 0.obs;
  var currentPage = Rx<Widget>(const CropTipsTab());
  final pageTitles = ['cropTips', 'weather', 'market', 'chat', 'settings'];

  // Factory functions for pages
  final List<Widget Function()> pageFactories = [
    () => const CropTipsTab(),
    () => const WeatherTab(),
    () => const MarketTab(),
    () => const ChatTab(),
    () => const SettingsTab(),
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeTabIndex();
  }

  void _initializeTabIndex() {
    try {
      final savedIndex = storageService.getTabIndex();
      if (savedIndex >= 0 && savedIndex < pageTitles.length) {
        selectedIndex.value = savedIndex;
        currentPage.value = pageFactories[savedIndex]();
      } else {
        selectedIndex.value = 0;
        storageService.saveTabIndex(0);
        currentPage.value = pageFactories[0]();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load tab index: $e',
          backgroundColor: Colors.red.shade300);
      selectedIndex.value = 0;
      currentPage.value = pageFactories[0]();
    }
  }

  void changePage(int index) {
    if (index >= 0 && index < pageTitles.length) {
      selectedIndex.value = index;
      currentPage.value = pageFactories[index]();
      try {
        storageService.saveTabIndex(index);
      } catch (e) {
        Get.snackbar('Error', 'Failed to save tab index: $e',
            backgroundColor: Colors.red.shade300);
      }
      print('Switched to: ${pageTitles[index]}');
    } else {
      print('Invalid page index: $index');
    }
  }

  void toggleLanguage() {
    authController.toggleLanguage();
  }

  void toggleTheme() {
    themeController.toggleTheme();
  }

  void logout() {
    try {
      authController.logout();
    } catch (e) {
      Get.snackbar('Error', 'Logout failed: $e',
          backgroundColor: Colors.red.shade300);
    }
  }
}