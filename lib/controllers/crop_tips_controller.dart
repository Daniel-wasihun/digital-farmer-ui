import 'dart:convert';
import 'package:agri/services/api/base_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../utils/crop_data.dart';

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

  // Storage for caching location
  final storage = GetStorage();

  static const String aiBaseUrl = BaseApi.aiBaseUrl;
  static const String openCageBaseUrl = 'https://api.opencagedata.com/geocode/v1/json';

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
      // Load cached location if available
      loadCachedLocation();
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

  // Load cached location data
  void loadCachedLocation() {
    final cachedLatitude = storage.read('latitude');
    final cachedLongitude = storage.read('longitude');
    final cachedCity = storage.read('city');
    if (cachedLatitude != null && cachedLongitude != null && cachedCity != null) {
      print('Loaded cached location: $cachedCity ($cachedLatitude, $cachedLongitude)');
    }
  }

  // Get device location
  Future<Position?> _getDeviceLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Error'.tr,
          'Location services are disabled.'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Error'.tr,
            'Location permissions are denied.'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Error'.tr,
          'Location permissions are permanently denied.'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      storage.write('latitude', position.latitude);
      storage.write('longitude', position.longitude);
      return position;
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to get device location.'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Location fetch exception: $e');
      return null;
    }
  }

  // Get city from coordinates using OpenCageData API
  Future<String?> _getCityFromCoordinates(double latitude, double longitude) async {
    try {
      final apiKey = dotenv.env['OPEN_CAGE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        Get.snackbar(
          'Error'.tr,
          'API key is missing or invalid.'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }

      final response = await http.get(
        Uri.parse('$openCageBaseUrl?q=$latitude,+$longitude&key=$apiKey'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          final components = results[0]['components'] as Map<String, dynamic>;
          final city = components['town']?.toString() ??
              components['_normalized_city']?.toString() ??
              'Unknown';
          storage.write('city', city);
          return city;
        } else {
          Get.snackbar(
            'Error'.tr,
            'No city found for the given coordinates.'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return null;
        }
      } else {
        Get.snackbar(
          'Error'.tr,
          'Failed to fetch city name.'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print('City fetch error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to fetch city name.'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('City fetch exception: $e');
      return null;
    }
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

    final cachedLatitude = storage.read('latitude');
    final cachedLongitude = storage.read('longitude');
    final cachedCity = storage.read('city');

    if (cachedLatitude != null && cachedLongitude != null && cachedCity != null) {
      latitude = cachedLatitude;
      longitude = cachedLongitude;
      city = cachedCity;
      print('Using cached location: $city ($latitude, $longitude)');
    } else {
      final position = await _getDeviceLocation();
      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
        final fetchedCity = await _getCityFromCoordinates(latitude, longitude);
        if (fetchedCity != null) {
          city = fetchedCity;
        }
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