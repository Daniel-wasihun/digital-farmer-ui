import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/storage_service.dart';

class HomeController extends GetxController {
  final StorageService storageService = Get.find<StorageService>();
  final RxInt currentIndex = 0.obs;

  // Tab keys for navigation and translation
  final List<String> tabKeys = [
    'cropTips',
    'weather',
    'market',
    'chat',
    'settings',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeTabIndex();
  }

  void _initializeTabIndex() {
    try {
      final savedIndex = storageService.getTabIndex();
      if (savedIndex >= 0 && savedIndex < tabKeys.length) {
        currentIndex.value = savedIndex;
      } else {
        currentIndex.value = 0;
        storageService.saveTabIndex(0);
      }
    } catch (e) {
      // Snackbar removed: previously showed 'Failed to load tab index'
      currentIndex.value = 0;
    }
  }

  void setTabIndex(int index) {
    if (index >= 0 && index < tabKeys.length) {
      currentIndex.value = index;
      try {
        storageService.saveTabIndex(index);
      } catch (e) {
        Get.snackbar('Error', 'Failed to save tab index: $e',
            backgroundColor: Colors.red.shade100);
      }
    }
  }
}