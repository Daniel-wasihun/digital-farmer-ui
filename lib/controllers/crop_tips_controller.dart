import 'dart:convert';
import 'package:agri/services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../../utils/crop_data.dart';

class CropTipsController extends GetxController {
  // For search functionality
  final TextEditingController searchController = TextEditingController();
  var searchQuery = ''.obs;

  // For category filtering
  var selectedCategory = 'All'.obs;
  RxInt currentTabIndex = 0.obs;

  // For Crop Info section
  var selectedCrop = 'teff'.obs;
  var isCropInfoLoading = false.obs;
  var cropInfo = Rxn<String>();

  static const String aiBaseUrl = BaseApi.aiBaseUrl;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // Get list of unique categories including "All"
  List<String> getCategories() {
    final categories = <String>{'All'};
    for (var entry in cropData.entries) {
      categories.add(entry.value['category'] as String);
    }
    return categories.toList()..sort();
  }

  // Filter crops based on search query and selected category
  List<MapEntry<String, Map<String, dynamic>>> getFilteredCrops() {
    var filtered = cropData.entries;

    // Apply category filter
    if (selectedCategory.value != 'All') {
      filtered = filtered.where((entry) => entry.value['category'] == selectedCategory.value);
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((entry) {
        final translatedCropName = entry.key.tr.toLowerCase();
        return translatedCropName.contains(searchQuery.value.toLowerCase());
      });
    }

    return filtered.toList();
  }

  // Check if the text contains Amharic characters (Unicode range U+1200 to U+137F)
  bool containsAmharic(String text) {
    print('Checking for Amharic in: $text');
    bool hasAmharic = RegExp(r'[\u1200-\u137F]').hasMatch(text);
    print('Contains Amharic: $hasAmharic');
    return hasAmharic;
  }

  Future<void> fetchCropInfo(String cropType) async {
    print('Fetching crop info for: $cropType');
    isCropInfoLoading.value = true;
    cropInfo.value = null;
    try {
      var response = await http.post(
        Uri.parse('$aiBaseUrl/ask/agriculture/$cropType'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'latitude': 11.7833,
          'longitude': 39.6,
          'city': 'weldiya',
          'language': Get.locale?.languageCode ?? 'en',
        }),
      );

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        String answer = data['answer'];
        print('Initial Response: $answer');
        containsAmharic(answer);
        cropInfo.value = answer;
      } else {
        Get.snackbar('Error'.tr, 'Error Fetching Crop Info: ${response.statusCode}'.tr);
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Error Fetching Crop Info: $e'.tr);
    } finally {
      isCropInfoLoading.value = false;
    }
  }
}