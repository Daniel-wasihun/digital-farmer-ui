import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CropTipsController extends GetxController {
  // For search functionality
  final TextEditingController searchController = TextEditingController();
  var searchQuery = ''.obs;

  // For Crop Info section
  var selectedCrop = 'teff'.obs;
  var isCropInfoLoading = false.obs;
  var cropInfo = Rxn<String>();

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  // Check if the text contains Amharic characters (Unicode range U+1200 to U+137F)
  bool containsAmharic(String text) {
    print('Checking for Amharic in: $text');
    bool hasAmharic = RegExp(r'[\u1200-\u137F]').hasMatch(text);
    print('Contains Amharic: $hasAmharic');
    return hasAmharic;
  }

  Future<void> fetchCropInfo(String cropType) async {
    isCropInfoLoading.value = true;
    cropInfo.value = null;
    try {
      // Request with the current locale
      var response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/ask/$cropType'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'latitude': 11.7833,
          'longitude': 39.6,
          'city': 'weldiya',
          'language': Get.locale?.languageCode ?? 'en',
        }),
      );

      if (response.statusCode == 200) {
        // Explicitly decode the response as UTF-8
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        String answer = data['answer'];

        // Log the response to confirm it matches the console output
        print('Initial Response: $answer');

        // Check for Amharic characters (for logging purposes only)
        containsAmharic(answer);

        // Assign the Amharic response directly to cropInfo
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