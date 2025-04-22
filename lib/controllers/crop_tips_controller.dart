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

  Future<void> fetchCropInfo(String cropType) async {
    isCropInfoLoading.value = true;
    cropInfo.value = null;
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/ask/$cropType'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'latitude': 11.7833,
          'longitude': 39.6,
          'city': 'weldiya',
          'language': Get.locale?.languageCode ?? 'en', // Include current language
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        cropInfo.value = data['answer'];
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