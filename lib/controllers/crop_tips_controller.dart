import 'dart:convert';
import 'package:digital_farmers/services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import '../../../../utils/crop_data.dart';
import '../services/location_service.dart';

class CropTipsController extends GetxController {
  // For search functionality
  final TextEditingController searchController = TextEditingController();
  var searchQuery = ''.obs;

  // For category filtering
  var selectedCategory = 'All'.obs;
  RxInt currentTabIndex = 0.obs;

  // For Crop Info section
  var selectedCrop = 'select_crop'.obs; // Default to 'select_crop'
  var isCropInfoLoading = false.obs;
  var cropInfo = Rxn<String>();

  // Location service for handling location data
  final LocationService locationService = LocationService();

  static const String aiBaseUrl = BaseApi.aiBaseUrl;

  final Logger _logger = Logger();

  @override
  void onInit() async {
    super.onInit();
    // Load environment variables
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print('Failed to load .env file: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to load configuration. Using cached location.'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    // Do NOT fetch crop info automatically
  }

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
    // Prevent fetching if cropType is 'select_crop'
    if (cropType == 'select_crop') {
      isCropInfoLoading.value = false;
      cropInfo.value = null;
      return;
    }

    print('Fetching crop info for: $cropType');
    isCropInfoLoading.value = true;
    cropInfo.value = null;

    double latitude = 11.7833; // Default fallback
    double longitude = 39.6;
    String city = 'weldiya';

    // Check for cached location
    final location = await locationService.getStoredLocation();
    if (location != null) {
      latitude = location['latitude'];
      longitude = location['longitude'];
      city = location['city'];
      print('Loaded cached location: $city ($latitude, $longitude)');
    } else {
      // Fetch and store new location
      await locationService.storeUserLocation();
      final newLocation = await locationService.getStoredLocation();
      if (newLocation != null) {
        latitude = newLocation['latitude'];
        longitude = newLocation['longitude'];
        city = newLocation['city'];
        print('Using newly fetched location: $city ($latitude, $longitude)');
      } else {
        print('No location fetched, using default: $city ($latitude, $longitude)');
      }
    }

    try {
      final url = '$aiBaseUrl/ask/agriculture/$cropType';
      print('Request URL: $url');
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'city': city,
          'language': Get.locale?.languageCode ?? 'en',
        }),
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(decodedBody);
        String answer = data['answer']?.toString() ?? '';
        print('Parsed answer: $answer');
        if (answer.isEmpty) {
          throw Exception('Empty response from server');
        }
        containsAmharic(answer);
        cropInfo.value = answer;
      } else {
        throw Exception('Error Fetching Crop Info: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in fetchCropInfo: $e');
      Get.snackbar(
        'Error'.tr,
        'An error occurred. Please try again.'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isCropInfoLoading.value = false;
    }
  }
}